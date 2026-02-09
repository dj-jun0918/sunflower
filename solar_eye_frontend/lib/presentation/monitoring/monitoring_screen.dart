import 'dart:async';
import 'dart:convert'; // For jsonDecode
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';
import 'package:solar_eye_frontend/data/provider/dashboard_provider.dart';
import 'package:solar_eye_frontend/data/provider/panel_provider.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/presentation/widgets/buttons/primary_button.dart';

enum AnalysisStatus { normal, clean, repair }

enum MonitoringType { cctv, drone }

class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({super.key});

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MonitoringType _currentType = MonitoringType.cctv;

  XFile? _selectedFile;
  AnalysisStatus? _analysisResult;
  bool _isLoading = false;
  String? _loadingMessage;
  String? _errorMessage;
  Size? _imageSize; // 원본 이미지 사이즈

  // 분석 상세 결과
  int _totalPanels = 0;
  int _normalCount = 0;
  int _defectCount = 0;
  int _soilingCount = 0;
  Map<String, dynamic>? _analysisResultMeta; // 분석 결과 메타데이터 저장
  List<dynamic> _detections = []; // 바운딩 박스 데이터

  List<Panel> _panels = [];
  Panel? _selectedPanel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentType = _tabController.index == 0
            ? MonitoringType.cctv
            : MonitoringType.drone;

        // 탭 전환 시 상태 초기화
        _selectedFile = null;
        _imageSize = null;
        _analysisResult = null;
        _isLoading = false;
        _loadingMessage = null;
        _errorMessage = null;
        _detections = [];
        _totalPanels = 0;
        _normalCount = 0;
        _defectCount = 0;
        _soilingCount = 0;
        _analysisResult = null; // 탭 전환 시에는 초기화
      });
    });
    _fetchPanels();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPanels() async {
    debugPrint('🚀 [Monitoring] Fetching panels...');
    try {
      final repository = ref.read(dashboardRepositoryProvider);
      final panels = await repository.getPanels();
      debugPrint('✅ [Monitoring] Fetched ${panels.length} panels');

      if (mounted) {
        setState(() {
          _panels = panels;
          if (_panels.isNotEmpty) {
            _selectedPanel = _panels.first;
            debugPrint(
                '📍 [Monitoring] Selected first panel: ${_selectedPanel?.name}');
          } else {
            debugPrint('⚠️ [Monitoring] Panel list is EMPTY from server');
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [Monitoring] Failed to fetch panels: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // 이미지 사이즈 획득 - XFile.readAsBytes()는 웹에서도 작동
      final bytes = await image.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);

      setState(() {
        _selectedFile = image;
        _imageSize =
            Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
        _isLoading = true;
        // _analysisResult = null; // 결과 상태 초기화 제거 (누적 위해)
        _errorMessage = null;
        _detections = [];
        _loadingMessage = '이미지 업로드 중...';
      });

      await _startAnalysis(image);
    }
  }

  Future<void> _startAnalysis(XFile image) async {
    debugPrint('Step 1: _startAnalysis called');

    // Use selected panel OR 0 (backend will auto-assign/create)
    final int panelId = int.tryParse(_selectedPanel?.id ?? '') ?? 0;
    debugPrint('Step 2: Using Panel ID: $panelId (0 means auto-assign)');

    try {
      final dio = ref.read(apiClientProvider);

      debugPrint('Step 3: Reading bytes from file...');
      final bytes = await image.readAsBytes();
      debugPrint('Step 3-DONE: Read ${bytes.length} bytes');

      final file = MultipartFile.fromBytes(
        bytes,
        filename: image.name,
      );

      final formData = FormData.fromMap({
        'image': file,
      });

      final typeStr = _currentType == MonitoringType.cctv ? 'cctv' : 'drone';
      final url = '/api/v1/monitoring/$panelId/$typeStr';
      debugPrint('Step 4: Sending POST request to $url');

      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      debugPrint('Step 5: Response received: ${response.statusCode}');

      if (response.statusCode == 202) {
        final analysisId = response.data['id']; // Changed from analysis_id
        debugPrint('Step 5-SUCCESS: Analysis ID: $analysisId');
        _pollAnalysisResult(analysisId);
      } else {
        throw Exception('분석 요청 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Step 5-ERROR (Dio): ${e.message}');
      _handleError('네트워크 오류 (Upload): ${e.message}');
    } catch (e) {
      debugPrint('Step 5-ERROR (General): $e');
      _handleError('분석 요청 오류: $e');
    }
  }

  Future<void> _pollAnalysisResult(String analysisId) async {
    setState(() => _loadingMessage = 'AI 분석 진행 중...');

    // Polling Logic
    int retryCount = 0;
    const maxRetries = 20; // 20 * 1s = 20s

    final dio = ref.read(apiClientProvider);

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        final response =
            await dio.get('/api/v1/monitoring/results/$analysisId');

        if (response.statusCode == 200) {
          final status = response.data['status'];
          if (status == 'completed') {
            timer.cancel();
            _processAnalysisData(response.data);
          } else if (status == 'failed') {
            timer.cancel();
            _handleError('분석 실패: 서버에서 처리를 완료하지 못했습니다.');
          }
        }

        retryCount++;
        if (retryCount >= maxRetries) {
          timer.cancel();
          _handleError('분석 시간 초과');
        }
      } catch (e) {
        timer.cancel();
        _handleError('결과 조회 오류: $e');
      }
    });
  }

  void _processAnalysisData(Map<String, dynamic> data) {
    if (!mounted) return;

    // Direct access to detections from response
    List<dynamic> dets = data['detections'] ?? [];

    // Debug: Print what we received
    debugPrint('🔍 [Analysis] Received ${dets.length} detections');
    for (var d in dets) {
      debugPrint(
          '  → defectType: ${d['defectType'] ?? d['defect_type']}, confidence: ${d['confidence']}');
    }

    int total = dets.length;

    // Updated logic: Backend returns 'defect', 'soiling', 'normal' (lowercase)
    // Also handle 'Crack', 'Soiling', 'Normal' (uppercase from KerasClassifier)
    int soilings = dets.where((d) {
      final type =
          (d['defectType'] ?? d['defect_type'] ?? '').toString().toLowerCase();
      return type == 'soiling';
    }).length;

    int cracks = dets.where((d) {
      final type =
          (d['defectType'] ?? d['defect_type'] ?? '').toString().toLowerCase();
      return type == 'crack' || type == 'defect';
    }).length;

    int normals = total - cracks - soilings;

    debugPrint(
        '📊 [Analysis] Summary: Total=$total, Normal=$normals, Defect=$cracks, Soiling=$soilings');

    setState(() {
      _analysisResultMeta = data; // 메타데이터 저장
      _totalPanels += total > 0 ? total : 0;
      _normalCount += normals;
      _defectCount += cracks;
      _soilingCount += soilings;

      _detections = dets.map((d) {
        final bbox = d['bbox']; // {'x':..., 'y':..., 'width':..., 'height':...}
        return {
          'x': bbox['x'],
          'y': bbox['y'],
          'width': bbox['width'],
          'height': bbox['height'],
          'type': d['defectType'] ?? d['defect_type'] ?? 'unknown',
          'confidence': d['confidence'] ?? 0.0,
          'mask': d['mask'] != null
              ? jsonDecode(d['mask'])
              : null, // Decode mask JSON
        };
      }).toList();

      // 누적된 결과 중 가장 심각한 상태를 유지
      if (_defectCount > 0) {
        _analysisResult = AnalysisStatus.repair;
      } else if (_soilingCount > 0) {
        if (_analysisResult != AnalysisStatus.repair) {
          _analysisResult = AnalysisStatus.clean;
        }
      } else {
        if (_analysisResult == null) {
          _analysisResult = AnalysisStatus.normal;
        }
      }

      _isLoading = false;
      _loadingMessage = null;
    });
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _errorMessage = message;
        _analysisResult = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🏗️ [Monitoring] building screen: panel=${_selectedPanel?.id}, isLoading=$_isLoading, result=$_analysisResult');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('모니터링'),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.text3,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'CCTV 감지'),
            Tab(text: '드론 감지'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.space4),
            _buildPanelSelector(),
            const SizedBox(height: AppSpacing.space4),
            _buildImageSection(),
            const SizedBox(height: AppSpacing.space6),
            if (_analysisResult != null) _buildAnalysisResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelSelector() {
    if (_panels.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Panel>(
          value: _selectedPanel,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.text2),
          style: AppTypography.bodyM.copyWith(color: AppColors.text1),
          onChanged: (Panel? newValue) {
            setState(() {
              _selectedPanel = newValue;
              // Reset analysis when panel changes
              _selectedFile = null;
              _imageSize = null;
              _analysisResult = null;
              _detections = [];
              _totalPanels = 0;
              _normalCount = 0;
              _defectCount = 0;
              _soilingCount = 0;
              _errorMessage = null;
            });
          },
          items: _panels.map<DropdownMenuItem<Panel>>((Panel value) {
            return DropdownMenuItem<Panel>(
              value: value,
              child: Text(value.name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onTap: _analysisResult == null && !_isLoading ? _pickImage : null,
      child: Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_selectedFile != null)
              Image.network(
                _selectedFile!.path,
                fit: BoxFit.cover,
              ),
            if (_selectedFile != null &&
                _analysisResult != null &&
                _detections.isNotEmpty &&
                _imageSize != null)
              CustomPaint(
                painter:
                    BoundingBoxPainter(_detections, _imageSize!, BoxFit.cover),
              ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: AppSpacing.space4),
                      Text(
                        _loadingMessage ?? '처리 중...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_selectedFile == null && !_isLoading)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 48, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.space3),
                  Text(
                    _currentType == MonitoringType.cctv
                        ? 'CCTV 이미지를 선택하세요'
                        : '드론 촬영 이미지를 선택하세요',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyL.copyWith(color: AppColors.text2),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.space4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodyM
                            .copyWith(color: AppColors.danger),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            if (!_isLoading && _analysisResult != null)
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  onPressed: _pickImage,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  child: const Icon(Icons.refresh),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    String title;
    String description;
    Color color;
    IconData icon;
    Widget? actionButton;

    switch (_analysisResult!) {
      case AnalysisStatus.normal:
        title = '정상';
        description = '태양광 패널 상태가 양호합니다.';
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case AnalysisStatus.clean:
        title = '오염 감지';
        description = '패널 오염이 감지되었습니다.\n세척 서비스를 추천합니다.';
        color = AppColors.warning;
        icon = Icons.cleaning_services;
        actionButton = PrimaryButton(
          label: '청소 업체 알아보기',
          backgroundColor: AppColors.warning, // Match semantic color
          onPressed: () => _showServiceModal('cleaning'),
        );
        break;
      case AnalysisStatus.repair:
        title = '결함 발견';
        description = '패널 결함이 감지되었습니다.\n수리 견적을 받아보세요.';
        color = AppColors.danger;
        icon = Icons.warning;
        actionButton = Column(
          children: [
            PrimaryButton(
              label: '수리 견적 요청',
              backgroundColor: AppColors.danger,
              onPressed: () => _showServiceModal('repair'),
            ),
            const SizedBox(height: AppSpacing.space3),
            _buildSaveButton(),
          ],
        );
        break;
    }

    // Default save button for normal/clean if not repair
    if (_analysisResult != AnalysisStatus.repair) {
      final oldButton = actionButton;
      actionButton = Column(
        children: [
          if (oldButton != null) ...[
            oldButton,
            const SizedBox(height: AppSpacing.space3),
          ],
          _buildSaveButton(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineM.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style:
                          AppTypography.bodyM.copyWith(color: AppColors.text1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Action Button for Services
        if (actionButton != null) ...[
          const SizedBox(height: AppSpacing.space4),
          actionButton,
        ],

        const SizedBox(height: AppSpacing.space6),
        Text('탐지 요약', style: AppTypography.titleM),
        const SizedBox(height: AppSpacing.space3),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  '전체 패널', _totalPanels.toString(), AppColors.text1),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _buildStatCard(
                  '정상', _normalCount.toString(), AppColors.success),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  '결함', _defectCount.toString(), AppColors.danger),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _buildStatCard(
                  '오염', _soilingCount.toString(), AppColors.warning),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.labelM.copyWith(color: AppColors.text3)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headlineM.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceModal(String type) {
    debugPrint('🔘 [Monitoring] _showServiceModal clicked: $type');

    // Use selected panel ID or fallback to "1"
    final String panelId = _selectedPanel?.id ?? "1";
    final String panelName = _selectedPanel?.name ?? "기본 패널";

    debugPrint(
        '✅ [Monitoring] Opening Service Modal for Panel: $panelName($panelId)');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceListModal(
        type: type,
        panelId: panelId,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
      child: PrimaryButton(
        label: '서버에 저장하기',
        icon: Icons.save_outlined,
        onPressed: _isLoading ? null : () => _saveAnalysisResult(),
        isLoading: _isLoading,
      ),
    );
  }

  Future<void> _saveAnalysisResult() async {
    debugPrint('🔘 [Monitoring] _saveAnalysisResult clicked');

    // 서버에서 받은 panel_id가 있으면 우선 사용, 없으면 선택된 패널 ID 사용
    final String? resultPanelId =
        (_analysisResultMeta?['panel_id'] ?? _analysisResultMeta?['panelId'])
            ?.toString();
    final String panelId = resultPanelId ?? _selectedPanel?.id ?? "0";

    if (panelId == "0") {
      debugPrint('⚠️ [Monitoring] No valid panel ID to invalidate');
      return;
    }

    debugPrint('🚀 [Monitoring] Invalidating providers for panel: $panelId');
    try {
      // Refresh related providers to reflect changes in details/history screens
      ref.invalidate(panelListProvider);
      ref.invalidate(panelDetailProvider(panelId));
      ref.invalidate(panelHistoryProvider(panelId));

      debugPrint('✨ [Monitoring] Providers invalidated successfully');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('탐지 결과가 서버에 자동 저장되었습니다.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      debugPrint('❌ [Monitoring] ERROR during invalidation: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('결과 반영 실패: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

// Separate widget for Service Modal to keep code clean
class ServiceListModal extends ConsumerStatefulWidget {
  final String type; // 'cleaning' or 'repair'
  final String panelId;

  const ServiceListModal({
    super.key,
    required this.type,
    required this.panelId,
  });

  @override
  ConsumerState<ServiceListModal> createState() => _ServiceListModalState();
}

class _ServiceListModalState extends ConsumerState<ServiceListModal> {
  bool _isLoading = true;
  List<dynamic> _companies = [];

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response =
          await dio.get('/api/v1/services/${widget.type}/companies');

      if (mounted) {
        setState(() {
          _companies = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Error handling if needed
      }
    }
  }

  Future<void> _requestService(String companyId, String companyName) async {
    try {
      final dio = ref.read(apiClientProvider);

      // Call API: POST /services/{type}/request
      await dio.post(
        '/api/v1/services/${widget.type}/request',
        data: {
          'facility_id': widget.panelId,
          'company_id': companyId,
          'request_details': '앱에서 신청',
        },
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$companyName에 서비스 신청이 접수되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('서비스 신청 실패: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'cleaning' ? '청소 업체 목록' : '수리 업체 목록';

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(title, style: AppTypography.headlineM),
          const SizedBox(height: AppSpacing.space4),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_companies.isEmpty)
            const Center(child: Text("등록된 업체가 없습니다."))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _companies.length,
                itemBuilder: (context, index) {
                  final company = _companies[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.space3),
                    color: AppColors.card,
                    child: ListTile(
                      title: Text(company['name'], style: AppTypography.titleM),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(company['description'] ?? '',
                              style: AppTypography.bodyM),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star,
                                  size: 14, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text('${company['rating']}',
                                  style: AppTypography.labelM),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () =>
                            _requestService(company['id'], company['name']),
                        child: const Text('신청'),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> detections;
  final Size originalImageSize;
  final BoxFit fit;

  BoundingBoxPainter(this.detections, this.originalImageSize, this.fit);

  @override
  void paint(Canvas canvas, Size size) {
    // BoxFit.cover에 따른 스케일링 계산
    final double scaleX = size.width / originalImageSize.width;
    final double scaleY = size.height / originalImageSize.height;
    final double scale = fit == BoxFit.cover
        ? (scaleX > scaleY ? scaleX : scaleY)
        : (scaleX < scaleY ? scaleX : scaleY);

    final double offsetX = (size.width - originalImageSize.width * scale) / 2;
    final double offsetY = (size.height - originalImageSize.height * scale) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var detection in detections) {
      final type = detection['type'];
      final color = type == 'crack' || type == 'defect'
          ? AppColors.danger
          : (type == 'soiling' ? AppColors.warning : AppColors.success);

      paint.color = color;

      // 좌표 스케일링
      final double x = (detection['x'] as num).toDouble() * scale + offsetX;
      final double y = (detection['y'] as num).toDouble() * scale + offsetY;
      final double w = (detection['width'] as num).toDouble() * scale;
      final double h = (detection['height'] as num).toDouble() * scale;

      // 1. Draw Mask (Polygon) if available
      if (detection['mask'] != null) {
        final List<dynamic> polygons = detection['mask'];
        final maskPaint = Paint()
          ..color = color.withValues(alpha: 0.4) // Semi-transparent fill
          ..style = PaintingStyle.fill;

        for (var polygon in polygons) {
          final path = Path();
          bool isFirst = true;

          // Polygon points are relative to the BBOX (0,0 is top-left of bbox)
          // If backend sends absolute points, we need to adjust, but let's assume relative based on previous step
          // Actually, analysis_service.py: "Points are relative to the BBOX top-left" -> Confirmed.
          for (var point in polygon) {
            final double px = (point[0] as num).toDouble();
            final double py = (point[1] as num).toDouble();

            // Scale point relative to BBox size scaling?
            // Need to be careful. The mask was generated from the crop.
            // Crop size was bbox width/height.
            // So we map pixel in crop -> pixel on screen.
            // Screen X = (BBox X + Point X) * scale + offsetX
            // Wait, BBox X is in original coordinates.

            final double screenX = (detection['x'] as num).toDouble() + px;
            final double screenY = (detection['y'] as num).toDouble() + py;

            final double drawX = screenX * scale + offsetX;
            final double drawY = screenY * scale + offsetY;

            if (isFirst) {
              path.moveTo(drawX, drawY);
              isFirst = false;
            } else {
              path.lineTo(drawX, drawY);
            }
          }
          path.close();
          canvas.drawPath(path, maskPaint);

          // Draw outline
          canvas.drawPath(
              path,
              paint
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5);
        }
      } else {
        // Fallback: Draw Rectangle Only
        final rect = Rect.fromLTWH(x, y, w, h);
        canvas.drawRect(
            rect,
            paint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0);
      }

      // 2. Draw Label
      // ... (existing code for label)

      // 라벨 표시
      final textSpan = TextSpan(
        text: type.toString().toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          backgroundColor: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
