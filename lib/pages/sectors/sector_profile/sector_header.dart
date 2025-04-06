import 'package:flutter/material.dart';

class SectorHeader extends StatelessWidget {
  final Map<String, dynamic> sector;
  final bool isMobile;

  const SectorHeader({
    super.key,
    required this.sector,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = isMobile ? 80.0 : 120.0;
    final coverHeight = isMobile ? 160.0 : 240.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: coverHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/cover/cover-01.png'),
              fit: BoxFit.cover,
            ),
            color: theme.colorScheme.primaryContainer,
          ),
        ),
        Positioned(
          bottom: -size / 2,
          left: isMobile ? 16 : 24,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surface,
                width: 4,
              ),
            ),
            child: CircleAvatar(
              radius: size / 2,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: ClipOval(
                child: Image.asset(
                  'assets/user/user-01.png',
                  width: size - 8,
                  height: size - 8,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        if (!isMobile)
          Positioned(
            bottom: 16,
            right: 24,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Edit Cover'),
            ),
          ),
      ],
    );
  }
}
