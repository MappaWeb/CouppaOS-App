import '../import.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ExpandableText({
    super.key,
    this.maxLines = 3,
    this.style,
    required this.text
  });

  @override
  State<ExpandableText> createState() => _ExpandableCommentState();
}

class _ExpandableCommentState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = widget.style ?? DefaultTextStyle.of(context).style;
    final span = TextSpan(
      style: defaultStyle,
      text: widget.text,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        bool hasOverflow = false;
        if (!_expanded && constraints.maxWidth > 0 && constraints.maxWidth.isFinite) {
          final tp = TextPainter(
            text: span,
            maxLines: widget.maxLines,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);
          
          hasOverflow = tp.didExceedMaxLines;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              span,
              maxLines: _expanded ? null : widget.maxLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (hasOverflow || _expanded)
              InkWell(
                onTap: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _expanded ? 'Ẩn bớt' : 'Xem thêm',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}