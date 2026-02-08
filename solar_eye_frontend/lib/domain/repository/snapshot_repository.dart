abstract class SnapshotRepository {
  Future<void> saveAnalysisSnapshot({
    required String imagePath,
    required String panelId,
    required List<Map<String, dynamic>> detections,
  });
}
