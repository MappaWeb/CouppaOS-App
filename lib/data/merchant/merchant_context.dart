// Extension BuildContext — yêu cầu BlocProvider<MerchantSessionCubit> phía trên.
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'me_merchant.dart';
import 'merchant_session_cubit.dart';

extension MerchantSessionContext on BuildContext {
  MerchantSessionCubit get merchantSessionCubit => read<MerchantSessionCubit>();

  /// Snapshot — không rebuild khi state đổi. Dùng trong callback / one-shot read.
  MeMerchant? get meMerchantOrNull => read<MerchantSessionCubit>().state;

  /// Reactive — widget rebuild khi merchant state đổi. Dùng trong build().
  MeMerchant? get watchMeMerchantOrNull => watch<MerchantSessionCubit>().state;
}
