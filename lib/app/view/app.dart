// ignore_for_file: deprecated_member_use

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spenditure/core/router/auto_route_observer.dart';
import 'package:spenditure/core/router/router_pod.dart';
import 'package:spenditure/core/theme/app_theme.dart';
import 'package:spenditure/core/theme/theme_controller.dart';
import 'package:spenditure/l10n/l10n.dart';
import 'package:spenditure/shared/helper/global_helper.dart';
import 'package:spenditure/shared/pods/locale_pod.dart';
import 'package:spenditure/shared/widget/no_internet_widget.dart';
import 'package:spenditure/shared/widget/responsive_wrapper.dart';

///This class holds Material App or Cupertino App
///with routing,theming and locale setup .
///Also responsive framerwork used for responsive application
///which auto resize or autoscale the app.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with GlobalHelper {
  @override
  Widget build(BuildContext context) {
    final approuter = ref.watch(autorouterProvider);
    final currentTheme = ref.watch(themecontrollerProvider);
    final locale = ref.watch(localePod);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Example App',
      theme: Themes.lightTheme,
      //!Uncomment this to usedark theme
      // darkTheme: Themes.darkTheme,
      themeMode: currentTheme,
      routerConfig: approuter.config(
        placeholder: (context) => const SizedBox.shrink(),
        navigatorObservers: () => [
          RouterObserver(),
        ],
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      builder: (context, child) {
        if (mounted) {
          ///Used for responsive design
          ///Here you can define breakpoint and how the responsive should work
          child = ResponsiveBreakPointWrapper(
            firstFrameWidget: Container(
              color: Colors.white,
            ),
            child: child!,
          );

          /// Add support for maximum text scale according to changes in
          /// accessibilty in sytem settings
          final mediaquery = MediaQuery.of(context);
          child = MediaQuery(
            data: mediaquery.copyWith(
              textScaler: TextScaler.linear(mediaquery.textScaleFactor.clamp(0, 1)),
            ),
            child: child,
          );

          /// Added annotate region by default to switch according to theme which
          /// customize the system ui veray style
          child = AnnotatedRegion<SystemUiOverlayStyle>(
            value: currentTheme == ThemeMode.dark
                ? SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.white.withOpacity(0.4),
                    systemNavigationBarColor: Colors.black,
                    systemNavigationBarDividerColor: Colors.black,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  )
                : currentTheme == ThemeMode.light
                    ? SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Colors.white.withOpacity(0.4),
                        systemNavigationBarColor: Colors.grey,
                        systemNavigationBarDividerColor: Colors.grey,
                        systemNavigationBarIconBrightness: Brightness.light,
                      )
                    : SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Colors.white.withOpacity(0.4),
                        systemNavigationBarColor: Colors.grey,
                        systemNavigationBarDividerColor: Colors.grey,
                        systemNavigationBarIconBrightness: Brightness.light,
                      ),
            child: GestureDetector(
              child: child,
              onTap: () {
                hideKeyboard();
              },
            ),
          );
        } else {
          child = const SizedBox.shrink();
        }

        ///Add toast support for flash
        return Toast(
          navigatorKey: navigatorKey,
          child: child,
        ).monitorConnection();
      },
    );
  }
}
