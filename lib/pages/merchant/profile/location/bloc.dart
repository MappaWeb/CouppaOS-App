import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../import.dart';

class MerchantProfileLocationState {
  const MerchantProfileLocationState({
    this.selected,
    this.isLocating = false,
    this.isSearching = false,
    this.message,
  });

  final LatLng? selected;
  final bool isLocating;
  final bool isSearching;
  final String? message;

  MerchantProfileLocationState copyWith({
    LatLng? selected,
    bool? isLocating,
    bool? isSearching,
    String? message,
  }) {
    return MerchantProfileLocationState(
      selected: selected ?? this.selected,
      isLocating: isLocating ?? this.isLocating,
      isSearching: isSearching ?? this.isSearching,
      message: message,
    );
  }
}

class MerchantProfileLocationCubit extends Cubit<MerchantProfileLocationState> {
  MerchantProfileLocationCubit({
    LatLng? initial,
  }) : super(MerchantProfileLocationState(selected: initial));


  void select(LatLng point) => emit(state.copyWith(selected: point));

  Future<void> searchLocation(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    emit(state.copyWith(isSearching: true));
    try {
      final res = await Dio(BaseOptions(
        headers: {
          'User-Agent': 'CouppaOS/1.0 (trungtt@iotcommunication.net)',
          'Accept': 'application/json',
        },
      )).get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'format': 'json', 'limit': 1, 'q': q},
      );
      final list = res.data as List?;
      if (list == null || list.isEmpty) {
        emit(state.copyWith(isSearching: false, message: 'Không tìm thấy địa điểm'));
        return;
      }
      final first = list.first as Map;
      final lat = double.tryParse(first['lat']?.toString() ?? '');
      final lng = double.tryParse(first['lon']?.toString() ?? '');
      if (lat == null || lng == null) {
        emit(state.copyWith(isSearching: false, message: 'Không xác định được tọa độ'));
        return;
      }
      emit(state.copyWith(
        isSearching: false,
        selected: LatLng(lat, lng),
      ));
    } on DioException catch (e, st) {
      debugPrint('[searchLocation] DioException: '
          'type=${e.type} status=${e.response?.statusCode} '
          'data=${e.response?.data} msg=${e.message}');
      debugPrintStack(stackTrace: st, label: 'searchLocation');
      emit(state.copyWith(isSearching: false, message: 'Không thể tìm kiếm địa điểm'));
    } catch (e, st) {
      debugPrint('[searchLocation] Error: $e');
      debugPrintStack(stackTrace: st, label: 'searchLocation');
      emit(state.copyWith(isSearching: false, message: 'Tìm kiếm thất bại'));
    }
  }

  Future<void> locateMe() async {
    if (state.isLocating) return;
    emit(state.copyWith(isLocating: true));
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        emit(state.copyWith(
          isLocating: false,
          message: 'Vui lòng bật dịch vụ vị trí trên thiết bị',
        ));
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(state.copyWith(
          isLocating: false,
          message: 'Ứng dụng chưa được cấp quyền truy cập vị trí',
        ));
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      emit(state.copyWith(
        selected: LatLng(position.latitude, position.longitude),
        isLocating: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLocating: false, message: 'Không lấy được vị trí hiện tại'));
    }
  }
}
