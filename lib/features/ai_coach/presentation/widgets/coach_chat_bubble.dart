import 'package:flutter/material.dart';
import '../../domain/entities/coach_message.dart';

class CoachChatBubble extends StatelessWidget {
  final CoachMessage message;

  const CoachChatBubble({
    super.key,
    required this.message,
  });

  bool get isUser => message.type == MessageType.user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          _buildAvatar(),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? message.color : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUser ? message.color : Colors.black).withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: isUser
                  ? null
                  : Border.all(
                      color: message.color.withValues(alpha: 0.3),
                      width: 1,
                    ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser && message.type != MessageType.coach) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        message.icon,
                        size: 14,
                        color: message.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: message.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                _buildMessageContent(),
              ],
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 10),
          _buildUserAvatar(),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [message.color, message.color.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        message.icon,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 18,
        color: Color(0xFF6C5CE7),
      ),
    );
  }

  Widget _buildMessageContent() {
    final lines = message.content.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Bold text processing
        if (line.contains('**')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildFormattedText(line),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            line,
            style: TextStyle(
              fontSize: 14,
              color: isUser ? Colors.white : Colors.black87,
              height: 1.4,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFormattedText(String text) {
    final parts = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Text before bold
      if (match.start > lastEnd) {
        parts.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.white : Colors.black87,
          ),
        ));
      }
      // Bold text
      parts.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isUser ? Colors.white : Colors.black87,
        ),
      ));
      lastEnd = match.end;
    }

    // Remaining text
    if (lastEnd < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(
          fontSize: 14,
          color: isUser ? Colors.white : Colors.black87,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: parts),
    );
  }

  String _getTypeLabel() {
    switch (message.type) {
      case MessageType.tip:
        return 'Зөвлөгөө';
      case MessageType.workout:
        return 'Дасгал';
      case MessageType.motivation:
        return 'Урам зориг';
      default:
        return '';
    }
  }
}
