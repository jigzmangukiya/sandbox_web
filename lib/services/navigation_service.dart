import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void navigateTO(String routeName) {
    navigatorKey.currentState?.pushNamed(routeName);
  }
}
