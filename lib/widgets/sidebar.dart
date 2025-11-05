import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key, this.onReset});

  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: GalaxyColors.slate.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onReset,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/Samsung_icon.svg',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 8),
                SelectableText(
                  'Galaxy\nLearning',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    height: 1.1,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'OVERVIEW',
            items: [
              _Item(
                Icons.chat_bubble_outline,
                'Counseling',
                showRedDot: true,
                isActive: true,
                onTap: () {
                  if (onReset != null) {
                    onReset!();
                  } else {
                    Navigator.of(context).pushNamed('/page1');
                  }
                },
              ),
              const _Item(Icons.dashboard, 'Dashboard'),
              const _Item(Icons.mail_outline, 'Inbox'),
              const _Item(Icons.book_outlined, 'Lesson'),
              _Item(
                Icons.smart_toy_outlined,
                'Teaching Assistant',
                onTap: () {
                  Navigator.of(context).pushNamed('/page2');
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Section(
            title: 'BROWSE',
            items: [
              const _Item(Icons.business_center_outlined, 'Business'),
              const _Item(Icons.memory_outlined, 'Technology'),
              const _Item(Icons.forum_outlined, 'Communications'),
              const _Item(Icons.category_outlined, 'Other Topics'),
              _Item(
                Icons.flash_on_outlined,
                'Micro-Learning',
                onTap: () {
                  Navigator.of(context).pushNamed('/page3');
                },
              ),
            ],
          ),
          const Spacer(),
          _Section(
            title: 'SETTINGS',
            items: const [
              _Item(Icons.settings_outlined, 'Settings'),
              _Item(Icons.logout, 'Logout'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});
  final String title;
  final List<_Item> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Builder(
            builder: (context) {
              final base = Theme.of(context).textTheme.labelSmall!;
              return SelectableText(
                title,
                style: base.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.8,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(
    this.icon,
    this.label, {
    this.isActive = false,
    this.showRedDot = false,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isActive;
  final bool showRedDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? scheme.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SelectableText(
                label,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (showRedDot)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
