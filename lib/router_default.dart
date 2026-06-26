import 'package:flutter/material.dart';
class RouterDefault extends StatelessWidget {
  const RouterDefault({super.key, required this.settings});
  final RouteSettings settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404'),
      ),
      body: Center(
          child: Text('No route defined for ${settings.name}')),
    );
  }
}