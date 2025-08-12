import 'package:get_it/get_it.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/viewmodels/Room_Cubit.dart';
import 'package:zentry_pomodoro_app/features/Room%20Operations/data/repositories/room_repository.dart';

import '../features/Room Operations/data/services/room_service.dart';

final getIt = GetIt.instance;
void setUpLocator() {
  //Room
  getIt.registerLazySingleton<RoomService>(() => RoomService());
  getIt.registerLazySingleton<RoomRepository>(
    () => RoomRepository(getIt<RoomService>()),
  );

  getIt.registerFactory<RoomCubit>(() => RoomCubit(getIt<RoomRepository>()));
}
