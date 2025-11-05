import 'package:flutter/material.dart';
import '../theme.dart';

class ProfilePanel extends StatelessWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: GalaxyColors.slate.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  'PROFILE',
                  style: text.labelSmall!.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 18),
                  color: Colors.white70,
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 96,
                  backgroundImage: AssetImage(
                    'assets/images/profile_ohtani.webp',
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  'Shohei Ohtani',
                  style: text.titleMedium?.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundIcon(icon: Icons.notifications_outlined),
                    const SizedBox(width: 8),
                    _RoundIcon(icon: Icons.chat_bubble_outline),
                    const SizedBox(width: 8),
                    _RoundIcon(icon: Icons.bookmark_outline),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectableText(
                  'FRIENDS',
                  style: text.labelSmall!.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  color: Colors.white70,
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _friends.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final f = _friends[index];
                return _FriendTile(name: f.name, role: f.role, color: f.color);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.name,
    required this.role,
    required this.color,
  });
  final String name;
  final String role;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GalaxyColors.panel.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SelectableText(
                  role,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall!.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}

class _FriendData {
  const _FriendData(this.name, this.role, this.color);
  final String name;
  final String role;
  final Color color;
}

const _friends = <_FriendData>[
  _FriendData('Yoshinobu Yamamoto', 'Baseball Player', Color(0xFFFF9E3D)),
  _FriendData('Will Ireton', 'Performance Manager', Color(0xFF2ED8A7)),
  _FriendData('Nez Balelo', 'Sports Agent', Color(0xFF31C0FF)),
  _FriendData('Adam Mendler', 'Business Podcast Host', Color(0xFF9C8CFF)),
  _FriendData('Mark Prior', 'Baseball Coach', Color(0xFFFFB86B)),
];
