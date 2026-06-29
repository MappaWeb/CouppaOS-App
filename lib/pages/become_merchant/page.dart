import 'package:flutter/services.dart';

import '../../import.dart';
import '../../data/merchant/merchant_session_cubit.dart';
import 'bloc.dart';

class BecomeMerchantPage extends StatelessWidget {
  const BecomeMerchantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BecomeMerchantBloc(
        apiClient: context.read<ApiClient>(),
        authSetup: AuthSetup.instance,
        merchantSession: context.read<MerchantSessionCubit>(),
      ),
      child: const _BecomeMerchantView(),
    );
  }
}

class _BecomeMerchantView extends StatelessWidget {
  const _BecomeMerchantView();

  @override
  Widget build(BuildContext context) {
    return SystemFormScaffold<BecomeMerchantBloc, SystemFormState>(
      appBarBuilder: (context, state) =>
          BaseAppBar(title: const Text('Trở thành cửa hàng'), context: context),
      scaffoldBackgroundColor: Palette.cardColor,
      bottomNavigationBar: (context, state, submitBtn) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () => context.read<BecomeMerchantBloc>().add(
                    SubmitSystemForm(),
                  ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(state.isSubmitting ? 'Đang gửi...' : 'Gửi đăng ký'),
            ),
          ),
        ),
      ),
      builder: (context, state, wrapper) {
        return BlocListener<BecomeMerchantBloc, SystemFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.isSuccess) {
              showMessage('Đăng ký cửa hàng thành công', type: 'success');
              appNavigator.go(RouterConstants.merchantCoupon);
            } else if (state.isFail && state.message != null) {
              showMessage(state.message!, type: 'error');
            }
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            children: [
              _sectionTitle('Thông tin pháp nhân'),
              wrapper<String>(
                'name',
                builder: (context, data, onChanged) => FieldText(
                  labelText: 'Tên pháp nhân',
                  required: true,
                  value: data.getValue() as String?,
                  errorText: data.error,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(height: 12),
              wrapper<String>(
                'taxCode',
                builder: (context, data, onChanged) => FieldText(
                  labelText: 'Mã số thuế',
                  required: true,
                  value: data.getValue() as String?,
                  errorText: data.error,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: onChanged,
                ),
              ),
              _sectionTitle('Thông tin cửa hàng'),
              wrapper<String>(
                'storeName',
                builder: (context, data, onChanged) => FieldText(
                  labelText: 'Tên cửa hàng',
                  required: true,
                  value: data.getValue() as String?,
                  errorText: data.error,
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
              const SizedBox(height: 12),
              wrapper<String>(
                'phone',
                builder: (context, data, onChanged) => FieldText(
                  labelText: 'Số điện thoại cửa hàng',
                  required: true,
                  value: data.getValue() as String?,
                  errorText: data.error,
                  keyboardType: TextInputType.phone,
                  onChanged: onChanged,
                ),
              ),
              const _LocationField(),
              wrapper<List<FileRef>>(
                'images',
                builder: (context, data, onChanged) => FieldMedia.images(
                  labelText: 'Ảnh cửa hàng',
                  listValue: (data.getValue() as List<FileRef>?) ?? const [],
                  onListChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
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
    return BlocBuilder<BecomeMerchantBloc, SystemFormState>(
      buildWhen: (prev, curr) =>
          prev.fields['lat'] != curr.fields['lat'] ||
          prev.fields['lng'] != curr.fields['lng'] ||
          prev.errors['lat'] != curr.errors['lat'],
      builder: (context, state) {
        final bloc = context.read<BecomeMerchantBloc>();
        final lat = (state.fields['lat'] as num?)?.toDouble();
        final lng = (state.fields['lng'] as num?)?.toDouble();
        final hasLocation = lat != null && lng != null;
        final locationError = state.errors['lat'];
        final subtitle = hasLocation
            ? '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
            : 'Chưa chọn vị trí';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
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
                      color: locationError != null
                          ? Palette.redTxtColor
                          : Palette.textPrimary3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Palette.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vị trí cửa hàng *',
                              style: TextStyle(
                                fontSize: 13,
                                color: Palette.textPrimary4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(subtitle),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              if (locationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    locationError,
                    style: const TextStyle(
                      color: Palette.redTxtColor,
                      fontSize: 12,
                    ),
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
    BecomeMerchantBloc bloc,
    double? lat,
    double? lng,
  ) async {
    final result = await appNavigator.pushNamed(
      RouterConstants.becomeMerchantLocation,
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
