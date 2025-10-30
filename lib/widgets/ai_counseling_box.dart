import 'package:flutter/material.dart';
import '../data/conversation_data.dart';
import '../theme.dart';

class AICounselingBox extends StatelessWidget {
  const AICounselingBox({super.key, this.messages});

  final List<Message>? messages;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'AI Tutor',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (messages ?? ConversationData.messages).length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final message = (messages ?? ConversationData.messages)[index];
            return _ChatMessage(message: message);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Ask Anything…',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}

class _ChatMessage extends StatelessWidget {
  const _ChatMessage({required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final isOhtani = message.sender == 'ohtani';
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isOhtani
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isOhtani) ...[_buildAvatar(context), const SizedBox(width: 8)],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isOhtani
                  ? scheme.primary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _MessageBody(content: message.content),
              ],
            ),
          ),
        ),
        if (isOhtani) ...[const SizedBox(width: 8), _buildAvatar(context)],
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (message.avatarAsset != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: AssetImage(message.avatarAsset!),
      );
    } else {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(
          context,
        ).colorScheme.secondary.withOpacity(0.3),
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 48),
      );
    }
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    final base = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      fontSize: 14,
      height: 1.4,
    );
    final heading = base?.copyWith(
      fontWeight: FontWeight.w800,
      color: GalaxyColors.yellow,
    );
    final numberHeading = RegExp(r'^\d+\.');
    final timeIndex = RegExp(r"\(\d{2}:\d{2}-\d{2}:\d{2}\)");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Builder(
            builder: (context) {
              if (numberHeading.hasMatch(line)) {
                return Text(line, style: heading);
              }
              final match = timeIndex.firstMatch(line);
              if (match == null) {
                return Text(line, style: base);
              }
              final before = line.substring(0, match.start);
              final mid = line.substring(match.start, match.end);
              final after = line.substring(match.end);
              return Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: before, style: base),
                    TextSpan(
                      text: mid,
                      style: base?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.redAccent,
                      ),
                    ),
                    TextSpan(text: after, style: base),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
