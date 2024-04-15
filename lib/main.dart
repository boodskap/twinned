import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/core/user_session.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:nocode_commons/core/constants.dart';
import 'package:twinned/pages/widgets/page_landing.dart';
import 'package:twinned/providers/state_provider.dart';
import 'package:twinned/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'pages/page_about.dart';
import 'pages/page_contact.dart';
//import 'package:twinned/design.dart';

Future main() async {
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => StateProvider())],
      child: TwinnedApp(
        key: Key(const Uuid().v4()),
      )));
}

class TwinnedApp extends StatefulWidget {
  const TwinnedApp({super.key});

  @override
  State<TwinnedApp> createState() => _TwinnedAppState();
}

class _TwinnedAppState extends BaseState<TwinnedApp> {
  @override
  void setup() async {
    await _load();
  }

  Future _load() async {
    await execute(debug: true, () async {
      await dotenv.load(fileName: 'settings.txt');

      var params = Uri.base.queryParameters;
      domainKey = params['domain'] ?? defaultDomainKey;

      if (!debug) {
        debugPrint = (String? message, {int? wrapWidth}) => '';
      }
      var res = await UserSession.twin.getTwinSysInfo(domainKey: domainKey);

      if (validateResponse(res)) {
        setState(() {
          twinSysInfo = res.body!.entity;
        });
        debugPrint(twinSysInfo.toString());
      }
    });
  }

  String lastRoute = "";
  Widget? lastPage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K')
        ],
      ),
      onGenerateRoute: (RouteSettings settings) {
        return Routes.fadeThrough(settings, (context) {
          return buildPage(context, settings.name ?? '');
        });
      },
      debugShowCheckedModeBanner: false,
    );
  }

  Widget buildPage(BuildContext context, String name) {
    if (null == twinSysInfo) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 350,
                height: 350,
                child: Image.asset(
                  'images/logo-large.png',
                  fit: BoxFit.contain,
                )),
            divider(),
            const Text(
              'Initializing....',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (null != lastPage && name == lastRoute) {
      return lastPage!;
    }

    lastRoute = name;

    switch (name) {
      case '/':
      //lastPage = const DesignPage(); //TODO comment after development
      //break; //TODO comment after development
      case LandingPage.name:
        lastPage = LandingPage(
          key: Key(const Uuid().v4()),
        );
        break;
      case AboutPage.name:
        lastPage = const AboutPage();
        break;
      case ContactPage.name:
        lastPage = const ContactPage();
        break;
      default:
        lastPage = const SizedBox.shrink();
        break;
    }

    return lastPage!;
  }
}
