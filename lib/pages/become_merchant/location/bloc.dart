import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../import.dart';

class LocationPickerState {
  const LocationPickerState({this.selected, this.isLocating = false, this.message});

  final LatLng? selected;
  final bool isLocating;
  final String? message;

  LocationPickerState copyWith({LatLng? selected, bool? isLocating, String? message}) {
    return LocationPickerState(
      selected: selected ?? this.selected,
      isLocating: isLocating ?? this.isLocating,
      message: message,
    );
  }
}

class LocationPickerCubit extends Cubit<LocationPickerState> {
  LocationPickerCubit({LatLng? initial}) : super(LocationPickerState(selected: initial));

  void select(LatLng point) => emit(state.copyWith(selected: point));

  Future<void> locateMe() async {
    if (state.isLocating) return;
    emit(state.copyWith(isLocating: true));
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        emit(
          state.copyWith(isLocating: false, message: 'Vui lòng bật dịch vụ vị trí trên thiết bị'),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            isLocating: false,
            message: 'Ứng dụng chưa được cấp quyền truy cập vị trí',
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      emit(
        state.copyWith(selected: LatLng(position.latitude, position.longitude), isLocating: false),
      );
    } catch (_) {
      emit(state.copyWith(isLocating: false, message: 'Không lấy được vị trí hiện tại'));
    }
  }
}
