import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';
import 'package:solar_eye_frontend/data/repository/snapshot_repository_impl.dart';
import 'package:solar_eye_frontend/domain/repository/snapshot_repository.dart';

final snapshotRepositoryProvider = Provider<SnapshotRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return SnapshotRepositoryImpl(dio);
});
