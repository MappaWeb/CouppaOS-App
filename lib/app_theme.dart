import 'import.dart';
const _lightSecondaryColor =  Color(0xFFEE000C);
const _lightPrimaryColor = Palette.primary;
final _lightScheme = BaseColorScheme.light( 
  seedColor: _lightSecondaryColor,
  primary: _lightPrimaryColor,
  secondary: _lightSecondaryColor
);
final baseTheme = BaseAppTheme(
  lightScheme: _lightScheme,
  darkScheme: _lightScheme,
  useRedRequired: true,
);

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = baseTheme.light.copyWith(
    appBarTheme: const AppBarTheme(),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _lightPrimaryColor,
      backgroundColor: Colors.white,
      unselectedIconTheme: IconThemeData(size: 24),
      selectedIconTheme: IconThemeData(size: 24),
      selectedLabelStyle: TextStyle(
        color: _lightPrimaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(
        color: Palette.textPrimary,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
      unselectedItemColor: Palette.textPrimary,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    tabBarTheme: TabBarThemeData(
      unselectedLabelColor: AppColors.gray500,
      labelColor: AppColors.gray900,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: _lightPrimaryColor, width: 2.0),
        insets: EdgeInsets.symmetric(horizontal: 0),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      // tabAlignment: TabAlignment.start,
      dividerHeight: 0,
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
    extensions: [
      AppBarThemeExtension(
        appBarTheme: baseTheme.light.appBarTheme,
        baseLeading: const Icon(Icons.arrow_back_rounded),
      ),
      AppThemeExtension(
        logo: 'assets/logo.png',
        logoBuilder: (context) => Image.asset('assets/logo.png', height: 80),
        formGroupLabelStyle: const TextStyle(
          color: Palette.textPrimary,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        textColor:   Palette.textPrimary,
        borderColor: AppColors.gray300,
        disabledFillColor: const Color(0xffF2F4F7),
      ),
    ],
  );
}
