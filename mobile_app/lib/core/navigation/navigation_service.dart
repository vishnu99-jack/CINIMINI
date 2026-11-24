import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  NavigationService._();

  static void push(BuildContext context, String route, {Object? extra}) {
    context.push(route, extra: extra);
  }

  static void replace(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  static void pop(BuildContext context) {
    context.pop();
  }
}
