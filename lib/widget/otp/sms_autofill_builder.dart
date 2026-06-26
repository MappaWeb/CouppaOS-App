// import 'package:flutter/material.dart';
// import 'package:sms_autofill/sms_autofill.dart';
// import 'package:core/core.dart';
//
// class SMSAutofillBuilder extends StatefulWidget {
//   final Widget Function(String? code) builder;
//
//   const SMSAutofillBuilder({super.key, required this.builder});
//   @override
//   State<SMSAutofillBuilder> createState() => _SMSAutofillBuilderState();
// }
//
// class _SMSAutofillBuilderState extends State<SMSAutofillBuilder> with CodeAutoFill {
//   String? otpCode;
//
//   @override
//   void codeUpdated() {
//     setState(() {
//       otpCode = code!;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     SmsAutoFill().getAppSignature.then((signature) {
//       if(Setting().get('appSignature') != signature) {
//         Setting().put('appSignature', signature);
//       }
//     });
//     listenForCode();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     cancel();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return  widgets.builder(otpCode);
//   }
// }