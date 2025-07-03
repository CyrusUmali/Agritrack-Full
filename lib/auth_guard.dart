import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGuard {
  static const publicRoutes = [
    '/signIn',
    '/signUp',
    '/resetPwd',
    '/calendar',
    '/invoice',
    '/profile',
    '/formElements',
    '/formLayout',
    '/tables',
    '/contacts',
    '/advancetable',
    '/settings',
    '/alerts',
    '/buttons',
    '/toast',
    '/modal',
    '/basicChart',
  ];

  static bool isPublicRoute(String path) {
    return publicRoutes.contains(path);
  }

  static bool isAuthenticated(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null;
  }

  // The original canAccess can be removed or kept as a combined check
  static bool canAccess(String path, BuildContext context) {
    return isPublicRoute(path) || isAuthenticated(context);
  }
}
