// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:icpv_book/import.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'sms_autofill_builder.dart';
//
// class FormOTPField extends StatefulWidget {
//   const FormOTPField({super.key, this.hasSendOTP = false,
//     required this.builder,required this.controller, required this.onChanged,
//     this.autoFocus = false, this.shape, this.borderWidth, this.borderRadius,
//     this.hasError = false, this.focusNode, this.onCompleted, this.useBasic = false});
//   final bool hasSendOTP;
//   final Function(String? code) builder;
//   final TextEditingController controller;
//   final ValueChanged<String> onChanged;
//   final bool autoFocus;
//   final PinCodeFieldShape? shape;
//   final double? borderWidth;
//   final BorderRadius? borderRadius;
//   final bool hasError;
//   final FocusNode? focusNode;
//   final ValueChanged<String>? onCompleted;
//   final bool useBasic;
//
//   @override
//   State<FormOTPField> createState() => _FormOTPFieldState();
// }
//
// class _FormOTPFieldState extends State<FormOTPField> {
//   late ValueKey key;
//   String otp = '';
//   @override
//   void initState() {
//     key = ValueKey('FormOTPField-${time()}');
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     double width = 45;
//     double height = 60;
//     Widget input = PinCodeTextField(
//       length: 6,
//       appContext: context,
//       obscureText: false,
//       cursorColor: Theme
//           .of(context)
//           .textTheme
//           .bodyLarge
//           ?.color,
//       animationType: AnimationType.fade,
//       controller: widgets.controller,
//       autoDisposeControllers: false,
//       autoDismissKeyboard: true,
//       inputFormatters: [
//         FilteringTextInputFormatter.digitsOnly,
//       ],
//       keyboardType: TextInputType.number,
//       textStyle: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.w500
//       ),
//       pinTheme: PinTheme(
//         shape: widgets.shape ?? PinCodeFieldShape.box,
//         fieldHeight: height,
//         fieldWidth: width,
//         borderWidth: widgets.borderWidth ?? 2,
//         borderRadius: widgets.borderRadius??BorderRadius.circular(5),
//         disabledBorderWidth: 1,
//
//         inactiveColor: widgets.hasError ? Theme.of(context).colorScheme.error : darken(AppColors.scaffoldBackgroundColor, 0.01),
//         inactiveFillColor: Theme.of(context).cardColor,
//
//         activeColor: darken(AppColors.scaffoldBackgroundColor, 0.01),
//         activeFillColor: darken(AppColors.scaffoldBackgroundColor, 0.01),
//
//         selectedColor: darken(AppColors.scaffoldBackgroundColor, 0.01),
//         selectedFillColor: Theme.of(context).cardColor,
//         selectedBorderWidth: 1,
//       ),
//       animationDuration: const Duration(milliseconds: 300),
//       enableActiveFill: true,
//       onCompleted: widgets.onCompleted,
//       onChanged: widgets.onChanged,
//       autoFocus: widgets.autoFocus,
//     );
//     return Center(
//       child: Container(
//         constraints: const BoxConstraints(
//             maxWidth: 400
//         ),
//         height: widgets.useBasic?null:height,
//         child: ((Platform.isAndroid && widgets.hasSendOTP)?SMSAutofillBuilder(
//             key: key,
//             builder: (code) {
//               if(!empty(code) && code != otp){
//                 otp = code??'';
//                 Future.delayed(const Duration(milliseconds: 500),(){
//                   safeRun((){setState(() {
//                     key = ValueKey('FormOTPField-${time()}');
//                   });});
//                 });
//               }
//               if(!empty(code) || !empty(otp)) {
//                 widgets.builder(!empty(code)?code:otp);
//               }
//               return input;
//             }
//         ):input),
//       ),
//     );
//   }
// }
