// 1. profile_header.dart
import 'package:ddip/features/profile/domain/entities/user_profile.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            // TODO: 실제 profile.profileImageUrl 연동
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            profile.nickname,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'LV.${profile.level} | ${profile.title}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
