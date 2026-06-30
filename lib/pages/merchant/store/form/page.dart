import '../../../../import.dart';
import 'bloc.dart';

class MerchantStoreFormPage extends StatelessWidget {
  const MerchantStoreFormPage(this.args, {super.key});

  final Map? args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MerchantStoreFormBloc(
        apiClient: context.read<ApiClient>(),
        initialData: args,
      ),
      child: _MerchantStoreFormView(isEdit: args?['id'] != null),
    );
  }
}

class _MerchantStoreFormView extends StatelessWidget {
  const _MerchantStoreFormView({required this.isEdit});

  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return SystemFormScaffold<MerchantStoreFormBloc, SystemFormState>(
      scaffoldBackgroundColor: Palette.cardColor,
      appBarBuilder: (ctx, state) => BaseAppBar(
        context: ctx,
        title: Text(isEdit ? 'Sửa chi nhánh' : 'Thêm chi nhánh'),
      ),
      bottomNavigationBar: (ctx, state, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () => ctx.read<MerchantStoreFormBloc>().add(SubmitSystemForm()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                state.isSubmitting
                    ? (isEdit ? 'Đang lưu...' : 'Đang tạo...')
                    : (isEdit ? 'Lưu thay đổi' : 'Tạo chi nhánh'),
              ),
            ),
          ),
        ),
      ),
      builder: (context, state, wrapper) {
        return BlocListener<MerchantStoreFormBloc, SystemFormState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (ctx, st) {
            if (st.isSuccess) {
              showMessage(
                isEdit ? 'Cập nhật chi nhánh thành công' : 'Đã thêm chi nhánh',
                type: 'success',
              );
              appNavigator.pop(true);
            } else if (st.isFail && st.message != null) {
              showMessage(st.message!, type: 'error');
            }
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            children: [
              wrapper<String>(
                'name',
                builder: (ctx, data, onChanged) => FieldText(
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
                builder: (ctx, data, onChanged) => FieldText(
                  labelText: 'Số điện thoại',
                  required: true,
                  keyboardType: TextInputType.phone,
                  value: data.getValue() as String?,
                  errorText: data.error,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(height: 12),
              wrapper<String>(
                'address',
                builder: (ctx, data, onChanged) => FieldText(
                  labelText: 'Địa chỉ',
                  required: true,
                  maxLines: 2,
                  value: data.getValue() as String?,
                  errorText: data.error,
                  onChanged: onChanged,
                ),
              ),
              const _LocationField(),
              const SizedBox(height: 4),
              wrapper<List<FileRef>>(
                'images',
                builder: (ctx, data, onChanged) {
                  final list =
                      (data.getValue() as List<FileRef>?) ?? const <FileRef>[];
                  return FieldMedia.images(
                    labelText: 'Ảnh cơ sở',
                    maxCount: 1,
                    value: list.isEmpty ? null : list.first,
                    onChanged: (ref) =>
                        onChanged(ref == null ? <FileRef>[] : [ref]),extensions: [],
                  );
                },
              ),
              const SizedBox(height: 16),
              wrapper<bool>(
                'isPrimary',
                builder: (ctx, data, onChanged) => FieldGroup(
                  labelText: 'Đặt làm cơ sở chính',
                  helperText:
                      'Khi bật, các cơ sở khác sẽ tự động chuyển sang cơ sở phụ.',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FieldSwitch(
                      value: data.getValue() as bool? ?? false,
                      onChanged: (v) => onChanged(v),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _LocationField extends StatelessWidget {
  const _LocationField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MerchantStoreFormBloc, SystemFormState>(
      buildWhen: (prev, curr) =>
          prev.fields['lat'] != curr.fields['lat'] ||
          prev.fields['lng'] != curr.fields['lng'] ||
          prev.errors['lat'] != curr.errors['lat'] ||
          prev.errors['lng'] != curr.errors['lng'],
      builder: (context, state) {
        final bloc = context.read<MerchantStoreFormBloc>();
        final lat = (state.fields['lat'] as num?)?.toDouble();
        final lng = (state.fields['lng'] as num?)?.toDouble();
        final hasLocation = lat != null && lng != null;
        final error = state.errors['lat'] ?? state.errors['lng'];
        final subtitle = hasLocation
            ? '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}'
            : 'Chưa chọn vị trí';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: FieldGroup(
            labelText: 'Vị trí trên bản đồ',
            required: true,
            errorText: error,
            child: InkWell(
              onTap: () => _pickLocation(context, bloc, lat, lng),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: error != null
                        ? Theme.of(context).colorScheme.error
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
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: hasLocation
                              ? Palette.textPrimary
                              : Palette.textPrimary3,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Palette.textPrimary3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickLocation(
    BuildContext context,
    MerchantStoreFormBloc bloc,
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
