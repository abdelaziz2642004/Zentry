import 'package:flutter_bloc/flutter_bloc.dart';
import 'guest_mode_states.dart';

class GuestmodeCubit extends Cubit<GuestmodeStates> {
  GuestmodeCubit() : super(GuestModeDisabledState());

  void enableGuestMode() {
    emit(GuestModeEnabledState());
  }

  void disableGuestMode() {
    emit(GuestModeDisabledState());
  }
}
