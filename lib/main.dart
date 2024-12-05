import 'dart:ui';

import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) => DockItem(
              key: ValueKey(icon),
              icon: icon,
            ),
          ),
        ),
      ),
    );
  }
}

class DockItem extends StatelessWidget {
  const DockItem({
    super.key,
    required this.icon,
  });

  static const double iconSize = 48;
  static const double margin = 8;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: iconSize,
        width: iconSize,
        margin: const EdgeInsets.all(margin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        ),
        child: Center(child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  static const double _padding = 4;

  /// [T] items being manipulated.
  List<T> _items = [];

  @override
  void initState() {
    _items = List.from(widget.items);

    super.initState();
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double scale = lerpDouble(1, 1.15, animValue)!;
        return Transform.scale(
          scale: scale,
          child: DockItem(
            icon: _items[index] as IconData,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      height: DockItem.iconSize + DockItem.margin * 2 + _padding * 2,
      padding: const EdgeInsets.all(_padding),
      child: ReorderableListView(
        shrinkWrap: true,
        proxyDecorator: proxyDecorator,
        scrollDirection: Axis.horizontal,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        prototypeItem: const SizedBox(
          width: DockItem.iconSize + 2 * DockItem.margin,
          height: DockItem.iconSize + 2 * DockItem.margin,
        ),
        children: _items.map(widget.builder).toList(),
      ),
    );
  }
}
