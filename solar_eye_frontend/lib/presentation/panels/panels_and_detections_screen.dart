import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/presentation/panels/panels_list_tab.dart';
import 'package:solar_eye_frontend/presentation/detections/detections_list_tab.dart';
import 'package:solar_eye_frontend/presentation/panels/panel_form_screen.dart';
import 'package:solar_eye_frontend/data/provider/panel_provider.dart';

class PanelsAndDetectionsScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const PanelsAndDetectionsScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<PanelsAndDetectionsScreen> createState() =>
      _PanelsAndDetectionsScreenState();
}

class _PanelsAndDetectionsScreenState
    extends ConsumerState<PanelsAndDetectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        title: Text(
          _currentIndex == 0 ? '패널 관리' : '탐지 이력',
          style: AppTypography.titleL.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle:
              AppTypography.titleM.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '패널 목록'),
            Tab(text: '탐지 이력'),
          ],
        ),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => ref.refresh(panelListProvider),
            )
          else
            // 탐지 이력 필터 버튼은 DetectionsListTab 내부에서 처리하기 어려우므로
            // 여기서 GlobalKey나 Notification을 통해 처리하거나,
            // 탭 내부로 AppBar를 옮기는 방식 고려.
            // 여기서는 심플하게 탭 내부에서 별도 필터 UI를 제공하거나
            // GlobalKey를 사용하는 패턴을 피하기 위해
            // DetectionsListTab이 자체적으로 필터 버튼을 가지지 않고
            // 상위에서 필터 콜백을 전달받는 형태로 구현하거나,
            // 일단 비워두고 DetectionsListTab 상단에 필터바를 배치하는 것으로 변경.
            const SizedBox.shrink(),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PanelsListTab(),
          DetectionsListTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PanelFormScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                '패널 추가',
                style: AppTypography.labelL.copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
