import '../../../import.dart';
import 'bloc.dart';

class MerchantProfilePage extends StatelessWidget {
  const MerchantProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantProfileBloc(apiClient: context.read<ApiClient>()),
      child: const _MerchantProfileView(),
    );
  }
}

class _MerchantProfileView extends StatelessWidget {
  const _MerchantProfileView();

  @override
  Widget build(BuildContext context) {
    return SystemFormScaffold<MerchantProfileBloc, SystemFormState>(
      appBarBuilder: (context, state) =>
          BaseAppBar(context: context, title: const Text('Hồ sơ cửa hàng')),
      scaffoldBackgroundColor: Palette.cardColor,
      bottomNavigationBar: (context, state, submitBtn) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (state.showLoading || state.isSubmitting)
                ? null
                : () => context.read<MerchantProfileBloc>().add(SubmitSystemForm()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(state.isSubmitting ? 'Đang lưu...' : 'Lưu'),
            ),
          ),
        ),
      ),
      builder: (context, state, wrapper) {
        return BlocListener<MerchantProfileBloc, SystemFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.isSuccess) {
              showMessage('Cập nhật thành công', type: 'success');
              appNavigator.pop(true);
            } else if (state.isFail && state.message != null) {
              showMessage(state.message!, type: 'error');
            }
          },
          child: state.showLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  children: [
                    _sectionTitle('Thông tin cửa hàng'),
                    const SizedBox(height: 4),
                    wrapper<String>(
                      '_merchantName',
                      builder: (context, data, onChanged) => FieldText(
                        labelText: 'Tên cửa hàng',
                        required: true,
                        value: data.getValue() as String?,
                        errorText: data.error,
                        onChanged: onChanged,
                      ),
                    ),
                    _sectionTitle('Cơ sở chính'),
                    const SizedBox(height: 4),
                    wrapper<String>(
                      'storeName',
                      builder: (context, data, onChanged) => FieldText(
                        labelText: 'Tên cơ sở',
                        required: true,
                        value: data.getValue() as String?,
                        errorText: data.error,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(height: 12),
                    wrapper<String>(
                      'phone',
                      builder: (context, data, onChanged) => FieldText(
                        labelText: 'Số điện thoại',
                        required: true,
                        value: data.getValue() as String?,
                        errorText: data.error,
                        keyboardType: TextInputType.phone,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(height: 12),
                    wrapper<String>(
                      'address',
                      builder: (context, data, onChanged) => FieldText(
                        labelText: 'Địa chỉ',
                        required: true,
                        value: data.getValue() as String?,
                        errorText: data.error,
                        maxLines: 2,
                        onChanged: onChanged,
                      ),
                    ),
                    const _LocationField(),
                    const SizedBox(height: 4),
                    wrapper<List<FileRef>>(
                      'images',
                      builder: (context, data, onChanged) {
                        final raw = data.getValue();
                        final list = raw is List
                            ? raw.whereType<FileRef>().toList()
                            : const <FileRef>[];
                        final first = list.isEmpty ? null : list.first;
                        return FieldMedia.images(
                          key: ValueKey('mp_img_${first?.url ?? first?.id ?? ''}'),
                          labelText: 'Ảnh cơ sở chính',
                          maxCount: 1,
                          value: first,
                          onChanged: (ref) =>
                              onChanged(ref == null ? <FileRef>[] : [ref]),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Palette.textPrimary4,
      ),
    ),
  );
}

class _LocationField extends StatelessWidget {
  const _LocationField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantProfileBloc, SystemFormState>(
      buildWhen: (prev, curr) =>
          prev.fields['lat'] != curr.fields['lat'] ||
          prev.fields['lng'] != curr.fields['lng'] ||
          prev.errors['lat'] != curr.errors['lat'],
      builder: (context, state) {
        final bloc = context.read<MerchantProfileBloc>();
        final lat = (state.fields['lat'] as num?)?.toDouble();
        final lng = (state.fields['lng'] as num?)?.toDouble();
        final hasLocation = lat != null && lng != null;
        final locationError = state.errors['lat'];
        final subtitle = hasLocation
            ? '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
            : 'Chưa chọn vị trí';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _pickLocation(context, bloc, lat, lng),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: locationError != null ? Palette.redTxtColor : Palette.textPrimary3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: locationError != null ? Palette.redTxtColor : Palette.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vị trí cơ sở *',
                              style: TextStyle(
                                fontSize: 13,
                                color: locationError != null
                                    ? Palette.redTxtColor
                                    : Palette.textPrimary4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: hasLocation ? Palette.textPrimary : Palette.textPrimary3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Palette.textPrimary3),
                    ],
                  ),
                ),
              ),
              if (locationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    locationError,
                    style: const TextStyle(color: Palette.redTxtColor, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickLocation(
    BuildContext context,
    MerchantProfileBloc bloc,
    double? lat,
    double? lng,
  ) async {
    final result = await appNavigator.pushNamed(
      RouterConstants.merchantProfileLocation,
      arguments: {'lat': ?lat, 'lng': ?lng},
    );
    if (result is Map) {
      final newLat = (result['lat'] as num?)?.toDouble();
      final newLng = (result['lng'] as num?)?.toDouble();
      if (newLat != null && newLng != null) {
        bloc.add(UpdateFieldSystemForm('lat', newLat));
        bloc.add(UpdateFieldSystemForm('lng', newLng));
      }
    }
  }
}
