import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio_post/providers/auth_provider.dart';
import 'package:portfolio_post/providers/post_provider.dart';
import 'package:portfolio_post/providers/search_provider.dart';
import 'package:portfolio_post/providers/state_provider.dart';
import 'package:portfolio_post/providers/tab_provider.dart';
import 'package:portfolio_post/providers/user_provider.dart';
import 'package:portfolio_post/repos/variables.dart';
import 'package:portfolio_post/service/fcm_service.dart';
import 'package:portfolio_post/views/auth/auth_page.dart';
import 'package:portfolio_post/views/new_post/new_post_page.dart';
import 'package:portfolio_post/views/post/post_page.dart';
import 'package:portfolio_post/views/profile/profile_page.dart';
import 'package:portfolio_post/views/scaffold/scaffold_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FCMService.initializeFirebase();
  await FCMService.initializeLocalNotifications();
  await FCMService.onBackgroundMsg();
  await FCMService.onMessage();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  runApp(const PortfolioPost());
}

class PortfolioPost extends StatelessWidget {
  const PortfolioPost({Key? key}) : super(key: key);

  Widget _androidApp() => MaterialApp(onGenerateRoute: (RouteSettings route) {
    if (route.name == NewPostPage.routeName) {
      final String _pageTitle = route.arguments.toString();
      return MaterialPageRoute(
        builder: (_) => const NewPostPage(),
        settings: RouteSettings(name: NewPostPage.routeName, arguments: _pageTitle),
      );
    };
    if (route.name == ProfilePage.routeName) {
      return MaterialPageRoute(
        builder: (_) => const ProfilePage(),
        settings: RouteSettings(name: ProfilePage.routeName),
      );
    };
    if (route.name == AuthPage.routeName) {
      return MaterialPageRoute<bool>(
        builder: (_) => const AuthPage(),
        settings: RouteSettings(name: AuthPage.routeName),
      );
    };
    if (route.name == PostPage.routeName) {
      return MaterialPageRoute(
        builder: (_) => const PostPage(),
        settings: RouteSettings(name: PostPage.routeName),
      );
    };
    return MaterialPageRoute(
      builder: (_) => const ScaffoldPage(),
      settings: RouteSettings(name: ScaffoldPage.routeName),
    );
  },
    debugShowCheckedModeBanner: false,
    home: const ScaffoldPage(),
    theme: ThemeData(
      checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.all<Color>(MyColors.primary)),
      primaryColor: MyColors.primary,
      textTheme: const TextTheme(
        bodyText2: TextStyle(fontSize: 17.0),
        button: TextStyle(color: MyColors.primary, fontSize: 16.0)
      ),
      iconTheme: const IconThemeData(color: MyColors.primary),
    ),
  );

  Widget _iosApp() => CupertinoApp(
    theme: CupertinoThemeData(
      textTheme: const CupertinoTextThemeData(
        textStyle: TextStyle(fontSize: 16.0, color: CupertinoColors.black),
      ),
    ),
    onGenerateRoute: (RouteSettings route) {
      if (route.name == NewPostPage.routeName) {
        final String _pageTitle = route.arguments.toString();
        return CupertinoPageRoute(
          builder: (_) => const NewPostPage(),
          settings: RouteSettings(name: NewPostPage.routeName, arguments: _pageTitle),
        );
      };
      if (route.name == AuthPage.routeName) {
        return CupertinoPageRoute<bool>(
          builder: (_) => const AuthPage(),
          settings: RouteSettings(name: AuthPage.routeName),
        );
      };
      if (route.name == PostPage.routeName) {
        return CupertinoPageRoute(
          builder: (_) => const PostPage(),
          settings: RouteSettings(name: PostPage.routeName),
        );
      };
      return CupertinoPageRoute(
        builder: (_) => const ScaffoldPage(),
        settings: RouteSettings(name: ScaffoldPage.routeName),
      );
    },
    home: const ScaffoldPage(),

  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StateProvider>(create: (_) => StateProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (BuildContext ctx) => AuthProvider(Provider.of<StateProvider>(ctx, listen: false))),
        ChangeNotifierProvider<PostsProvider>(create: (BuildContext ctx) => PostsProvider(Provider.of<StateProvider>(ctx, listen: false))),
        ChangeNotifierProvider<UserProvider>(create: (BuildContext ctx) => UserProvider(Provider.of<StateProvider>(ctx, listen: false))),
        ChangeNotifierProvider<TabProvider>(create: (_) => TabProvider()),
        ChangeNotifierProvider<SearchProvider>(create: (BuildContext ctx) => SearchProvider(Provider.of<StateProvider>(ctx, listen: false)))
      ],
      child: Platform.isAndroid ? this._androidApp() : this._iosApp(),
    );
  }
}

/*
rules ????????? ??? false??? ????????? ???????????? ??????????????? postman????????? ?????? ?????? ?????? ??? ??????

???????????? ????????? ?????? ????????????, ???????????? ??????? realtime??? => ?????? ?????????
?????? ???????????? ??????????????? db??? ?????? ??????

????????? ???????????? ?????? ?????? ?????? ????????? ??? ????????? ????????????????????? ??????

???????????
 */