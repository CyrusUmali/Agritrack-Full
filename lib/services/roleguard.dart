import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleGuard {
  static final Map<String, List<String>> roleRoutes = {
    'admin': [
      '/',
      '/usersPage',
      '/products',
      '/reports',
      '/settings',
      '/profile',
      '/farmers',
      '/recommendation',
      '/yields',
      '/newPage',
      '/farms',
      '/sectors',
    ],
    'officer': [
      '/',
      '/usersPage',
      '/products',
      '/reports',
      '/settings',
      '/profile',
      '/farmers',
      '/recommendation',
      '/yields',
      '/newPage',
      '/farms',
      '/sectors',
    ],
    'farmer': [
      '/',
      '/products',
      '/reports',
      '/settings',
      '/profile',
      '/recommendation',
      '/yields',
      '/newPage',
      '/farms',
    ],
  };

  static bool canAccess(String path, BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final role = userProvider.user?.role;

    if (role == null) return true; // Not authenticated properly

    final allowedRoutes = roleRoutes[role];
    return allowedRoutes?.contains(path) ?? false;
  }
}
