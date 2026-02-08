import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/panel_provider.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 패널 추가/수정 폼 화면
class PanelFormScreen extends ConsumerStatefulWidget {
  final Panel? panel; // null이면 추가, 있으면 수정

  const PanelFormScreen({super.key, this.panel});

  @override
  ConsumerState<PanelFormScreen> createState() => _PanelFormScreenState();
}

class _PanelFormScreenState extends ConsumerState<PanelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _rtspUrlController;

  bool get isEdit => widget.panel != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.panel?.name ?? '');
    _locationController =
        TextEditingController(text: widget.panel?.location ?? '');
    _latitudeController = TextEditingController(
      text: widget.panel?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.panel?.longitude?.toString() ?? '',
    );
    _rtspUrlController =
        TextEditingController(text: widget.panel?.rtspUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _rtspUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actionsState = ref.watch(panelActionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? '패널 수정' : '패널 추가',
          style: AppTypography.titleL.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
              children: [
                // 패널 이름
                _buildTextField(
                  controller: _nameController,
                  label: '패널 이름',
                  hint: '예: 패널 A-01',
                  icon: Icons.solar_power_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '패널 이름을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space4),

                // 위치 설명
                _buildTextField(
                  controller: _locationController,
                  label: '위치 설명',
                  hint: '예: 서울시 강남구 삼성동',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '위치를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.space4),

                // 위도/경도
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _latitudeController,
                        label: '위도',
                        hint: '37.5085',
                        icon: Icons.my_location,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '위도 입력';
                          }
                          final lat = double.tryParse(value);
                          if (lat == null || lat < -90 || lat > 90) {
                            return '유효하지 않음';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: _buildTextField(
                        controller: _longitudeController,
                        label: '경도',
                        hint: '127.0632',
                        icon: Icons.my_location,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '경도 입력';
                          }
                          final lng = double.tryParse(value);
                          if (lng == null || lng < -180 || lng > 180) {
                            return '유효하지 않음';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space4),

                // RTSP URL
                _buildTextField(
                  controller: _rtspUrlController,
                  label: 'RTSP URL (선택)',
                  hint: 'rtsp://192.168.1.100:554/stream1',
                  icon: Icons.videocam_outlined,
                ),
                const SizedBox(height: AppSpacing.space6),

                // 저장 버튼
                PrimaryButton(
                  label: isEdit ? '수정하기' : '추가하기',
                  onPressed: _submit,
                  isLoading: actionsState.isLoading,
                ),
                const SizedBox(height: AppSpacing.space4),

                // 취소 버튼
                SecondaryButton(
                  label: '취소',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          if (actionsState.isLoading)
            const LoadingIndicator(
              message: '저장 중...',
              overlay: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelM.copyWith(
            color: AppColors.text1,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyM.copyWith(color: AppColors.text3),
            prefixIcon: Icon(icon, color: AppColors.text2, size: 20),
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: AppColors.danger),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final request = PanelRequest(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      rtspUrl: _rtspUrlController.text.trim().isNotEmpty
          ? _rtspUrlController.text.trim()
          : null,
    );

    final actions = ref.read(panelActionsProvider.notifier);

    if (isEdit) {
      await actions.updatePanel(widget.panel!.id, request);
    } else {
      await actions.createPanel(request);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? '패널이 수정되었습니다' : '패널이 추가되었습니다'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
