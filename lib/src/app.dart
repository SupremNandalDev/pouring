import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pouring/src/main_provider.dart';
import 'package:pouring/src/main_screen.dart';
import 'package:provider/provider.dart';

const Color mColor = Color(0xffff8c1f);
const Color mColorLight = Color(0xffff9c5f);
const Color mColorRed = Color(0xff931717);
const Color mColorGreen = Color(0xff447A34);
const Color mColorBlue = Color(0xff0784B5);
final BorderRadius mCardRadius = BorderRadius.circular(16.0);

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key
  }) : super(key: key);

  get _debugShowMaterialGrid => false;
  get _showSemanticsDebugger => false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MainProvider>(
          create: (context) => MainProvider.init(),
        )
      ],
      child: Consumer<MainProvider>(
          builder: (context, settings, child){
            return MaterialApp(
              restorationScopeId: 'app',
              debugShowCheckedModeBanner: false,
              debugShowMaterialGrid: _debugShowMaterialGrid,
              showSemanticsDebugger: _showSemanticsDebugger,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English, no country code
              ],
              theme: ThemeData(
                fontFamily: GoogleFonts.dancingScript().fontFamily,
                scaffoldBackgroundColor: Colors.white,
                colorScheme: const ColorScheme.light(
                  primary: mColor,
                  primaryVariant: mColorLight,
                  secondary: mColor,
                  onSecondary: Colors.white,
                  secondaryVariant: mColorLight,
                  onPrimary: Colors.white
                )
              ),
              darkTheme: ThemeData(
                  fontFamily: GoogleFonts.dancingScript().fontFamily,
                  brightness: Brightness.dark,
                  scaffoldBackgroundColor: Colors.black,
                  colorScheme: const ColorScheme.dark(
                      primary: mColor,
                      primaryVariant: mColorLight,
                      secondary: mColor,
                      onSecondary: Colors.white,
                      secondaryVariant: mColorLight,
                      onPrimary: Colors.white
                  )
              ),
              themeMode: settings.themeMode,
              home: MainScreenRoute(),
            );
          }
      ),
    );
  }
}
