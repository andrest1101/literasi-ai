import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Blok jawaban AI yang sudah diurai dari format ringan.
///
/// Hanya tiga pola yang didukung (tanpa paket markdown agar tetap
/// deterministik dan aman dari overflow):
/// * judul baris diawali `## ` menjadi heading 15px tebal,
/// * penekanan `**teks**` menjadi bold sebaris,
/// * daftar `- ` / `* ` / `1. ` menjadi baris bullet/angka berindentasi.
///
/// Semua yang lain dirender sebagai paragraf biasa. Marker yang tidak
/// berpasangan (mis. `**` tunggal seperti keluhan user) tidak ditampilkan
/// mentah: parser menutupnya secara aman atau menampilkannya sebagai teks.
class ChatRichText extends StatelessWidget {
  const ChatRichText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final blocks = ChatRichTextParser.parse(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) SizedBox(height: blocks[i].tight ? 3 : 7),
          _BlockView(block: blocks[i]),
        ],
      ],
    );
  }
}

/// Satu blok render: heading, paragraf, atau satu baris daftar.
class ChatRichBlock {
  const ChatRichBlock._({
    required this.spans,
    required this.heading,
    required this.tight,
    this.bullet,
  });

  final List<ChatRichSpan> spans;
  final bool heading;
  final bool tight;
  final String? bullet;
}

/// Satu potongan teks sebaris dengan flag bold.
class ChatRichSpan {
  const ChatRichSpan(this.text, {this.bold = false});

  final String text;
  final bool bold;
}

/// Parser murni Dart agar unit-testable tanpa widget.
class ChatRichTextParser {
  const ChatRichTextParser._();

  static final RegExp _orderedExp = RegExp(r'^(\d+)[.)]\s+(.*)$');
  static final RegExp _boldExp = RegExp(r'\*\*(.+?)\*\*');

  static List<ChatRichBlock> parse(String raw) {
    final lines = raw.replaceAll('\r\n', '\n').split('\n');
    final blocks = <ChatRichBlock>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('##')) {
        blocks.add(
          ChatRichBlock._(
            spans: _inline(trimmed.replaceFirst(RegExp(r'^##+\s*'), '')),
            heading: true,
            tight: false,
          ),
        );
        continue;
      }
      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        blocks.add(
          ChatRichBlock._(
            spans: _inline(trimmed.substring(2).trim()),
            heading: false,
            tight: true,
            bullet: '•',
          ),
        );
        continue;
      }
      final ordered = _orderedExp.firstMatch(trimmed);
      if (ordered != null) {
        blocks.add(
          ChatRichBlock._(
            spans: _inline((ordered.group(2) ?? '').trim()),
            heading: false,
            tight: true,
            bullet: '${ordered.group(1)}.',
          ),
        );
        continue;
      }
      blocks.add(
        ChatRichBlock._(
          spans: _inline(trimmed),
          heading: false,
          tight: blocks.isNotEmpty && blocks.last.bullet != null,
        ),
      );
    }
    if (blocks.isEmpty) {
      return [
        const ChatRichBlock._(
          spans: [ChatRichSpan('')],
          heading: false,
          tight: false,
        ),
      ];
    }
    return blocks;
  }

  /// Urai `**teks**` sebaris. `**` tunggal yang tidak berpasangan dihapus
  /// agar tidak tampil mentah seperti keluhan user ("contoh" dengan bintang).
  static List<ChatRichSpan> _inline(String raw) {
    final spans = <ChatRichSpan>[];
    var index = 0;
    for (final match in _boldExp.allMatches(raw)) {
      if (match.start > index) {
        spans.add(ChatRichSpan(_clean(raw.substring(index, match.start))));
      }
      spans.add(ChatRichSpan(_clean(match.group(1) ?? ''), bold: true));
      index = match.end;
    }
    if (index < raw.length) {
      spans.add(ChatRichSpan(_clean(raw.substring(index))));
    }
    final cleaned = spans
        .where((span) => span.text.isNotEmpty)
        .toList(growable: false);
    return cleaned.isEmpty ? const [ChatRichSpan('')] : cleaned;
  }

  static String _clean(String value) => value.replaceAll('**', '');
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block});

  final ChatRichBlock block;

  @override
  Widget build(BuildContext context) {
    final text = Text.rich(
      TextSpan(
        children: [
          for (final span in block.spans)
            TextSpan(
              text: span.text,
              style: TextStyle(
                fontSize: block.heading ? 15 : 14.5,
                height: block.heading ? 1.4 : 1.55,
                fontWeight: span.bold || block.heading
                    ? FontWeight.w800
                    : FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
    final bullet = block.bullet;
    if (bullet == null) return text;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          child: Text(
            bullet,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.55,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        Expanded(child: text),
      ],
    );
  }
}
