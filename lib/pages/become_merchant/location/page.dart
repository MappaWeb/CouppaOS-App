import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../import.dart' hide Marker;
import 'bloc.dart';

/// Toạ độ mặc định (trung tâm Hà Nội) khi chưa có vị trí khởi tạo.
const _defaultCenter = LatLng(21.028511, 105.804817);

class BecomeMerchantLocationPage extends StatelessWidget {
  const BecomeMerchantLocationPage(this.args, {super.key});

  final Map? args;

  @override
  Widget build(BuildContext context) {
    final lat = (args?['lat'] as num?)?.toDouble();
    final lng = (args?['lng'] as num?)?.toDouble();
    final initial = (lat != null && lng != null) ? LatLng(lat, lng) : null;

    return BlocProvider(
      create: (_) => LocationPickerCubit(initial: initial),
      child: _LocationPickerView(initial: initial ?? _defaultCenter),
    );
  }
}

class _LocationPickerView extends StatefulWidget {
  const _LocationPickerView({required this.initial});

  final LatLng initial;

  @override
  State<_LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<_LocationPickerView> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final newZoom = (camera.zoom + delta).clamp(3.0, 18.0);
    _mapController.move(camera.center, newZoom);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LocationPickerCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn vị trí cửa hàng')),
      body: BlocConsumer<LocationPickerCubit, LocationPickerState>(
        listenWhen: (prev, curr) => prev.message != curr.message || prev.selected != curr.selected,
        listener: (context, state) {
          if (state.message != null) {
            showMessage(state.message!, type: 'error');
          }
          final selected = state.selected;
          if (selected != null) {
            _mapController.move(selected, 16);
          }
        },
        builder: (context, state) {
          final selected = state.selected;
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: selected ?? widget.initial,
                  initialZoom: 16,
                  onTap: (_, point) => cubit.select(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://osm.suyxet.com/styles/osm-liberty/{z}/{x}/{y}.png',
                    tileProvider: NetworkTileProvider(silenceExceptions: true),
                  ),
                  if (selected != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selected,
                          width: 44,
                          height: 44,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on,
                            color: Palette.redTxtColor,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 168,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      onPressed: () => _zoomBy(1),
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      onPressed: () => _zoomBy(-1),
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 96,
                child: FloatingActionButton(
                  heroTag: 'locate_me',
                  onPressed: state.isLocating ? null : cubit.locateMe,
                  child: state.isLocating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<LocationPickerCubit, LocationPickerState>(
        builder: (context, state) {
          final selected = state.selected;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: selected == null
                    ? null
                    : () => appNavigator.pop({'lat': selected.latitude, 'lng': selected.longitude}),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Xác nhận vị trí'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
