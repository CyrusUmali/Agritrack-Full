import 'package:flareline/core/models/user_model.dart';
import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../user_bloc/user_bloc.dart';

class PasswordChangeCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isMobile;

  const PasswordChangeCard(
      {super.key, required this.user, this.isMobile = false});

  @override
  State<PasswordChangeCard> createState() => _PasswordChangeCardState();
}

class _PasswordChangeCardState extends State<PasswordChangeCard> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _passwordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = Map<String, dynamic>.from(widget.user);

      updatedUser['newPassword'] = _newPasswordController.text;
      updatedUser['password'] = _passwordController.text;

      context.read<UserBloc>().add(UpdateUser(
            UserModel.fromJson(updatedUser),
            passwordChanged: true,
          ));
    }
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required Widget value,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: colors.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
              ],
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: value,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
  }) {
    return _buildInfoRow(
      context,
      label: label,
      icon: icon,
      value: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasPassword = widget.user['hasPassword'] == true;

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UsersError) {
          ToastHelper.showErrorToast(state.message, context);
        } else if (state is UserUpdated) {
          if (state.passwordChanged) {
            Provider.of<UserProvider>(context, listen: false).signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lock_outline, color: colors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Change Password',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (hasPassword)
                  _buildPasswordField(
                    label: 'Current Password',
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    validator: (value) {
                      if (_newPasswordController.text.isNotEmpty &&
                          (value == null || value.isEmpty)) {
                        return 'Required to change password';
                      }
                      return null;
                    },
                  ),
                _buildPasswordField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  icon: Icons.lock_reset_outlined,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                _buildPasswordField(
                  label: 'Confirm New Password',
                  controller: _confirmPasswordController,
                  icon: Icons.lock_reset_outlined,
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveChanges,
                    child: Text(
                      'Change Password',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
