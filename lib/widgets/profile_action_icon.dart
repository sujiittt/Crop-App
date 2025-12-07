import 'package:flutter/material.dart';
import 'package:cropwise/presentation/profile_screen/profile_screen.dart';

class ProfileActionIcon extends StatelessWidget {
  const ProfileActionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Profile',
      onPressed: () => Navigator.of(context).pushNamed(ProfileScreen.routeName),
      icon: const Icon(Icons.person_outline),
    );
  }
}
