import 'package:flutter/material.dart';
import 'package:glass_bottom_navigation/glass_bottom_navigation.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glass Bottom Navigation Example',
      theme: ThemeData(useMaterial3: true),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  static const _items = [
    GlassBarItem(
      icon: Icons.home_rounded,
      label: 'Home',
      nativeSymbolName: 'house.fill',
    ),
    GlassBarItem(
      icon: Icons.chat_rounded,
      label: 'Chat',
      nativeSymbolName: 'bubble.left.fill',
    ),
    GlassBarItem(
      icon: Icons.settings_rounded,
      label: 'Settings',
      nativeSymbolName: 'gearshape.fill',
    ),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final activeItem = _items[_currentIndex];

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6FD8), Color(0xFF3813C2), Color(0xFF21D4FD)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.paddingOf(context).top + 20,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  GlassActionButton(
                    item: GlassActionButtonItem.back(
                      onTap: () => _showMessage(context, 'Back tapped'),
                      nativeStyle: GlassNativeButtonStyle.prominent,
                    ),
                  ),
                  const Spacer(),
                  GlassActionButtonRow(
                    actions: [
                      GlassActionButtonItem.more(
                        onTap: () => _showMessage(context, 'More tapped'),
                        nativeStyle: GlassNativeButtonStyle.prominent,
                      ),
                      GlassActionButtonItem.search(
                        onTap: () => _showMessage(context, 'Search tapped'),
                        nativeStyle: GlassNativeButtonStyle.prominent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  activeItem.label,
                  key: ValueKey(activeItem.label),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GlassBottomBar(
            items: _items,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            style: const GlassBottomNavStyle(showSpecularDot: false),
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
