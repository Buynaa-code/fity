import 'package:flutter/material.dart';

/// LazyIndexedStack - Зөвхөн идэвхтэй болсон tab-уудыг санах ойд ачаална
/// IndexedStack-аас ялгаатай нь бүх tab-ыг нэгэн зэрэг ачаалдаггүй
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List.generate(widget.children.length, (i) => i == widget.index);
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _activated[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        if (_activated[i]) {
          return widget.children[i];
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
