import 'dart:ui';

class ViewPortModel {
  final String name;
  late Size size;
  late final bool portrait;

  ViewPortModel({required this.name, required this.size, this.portrait = true});

  @override
  String toString() {
    return '$name - [${size.width} x ${size.height}]';
  }

  static const double dpi = 96;

  static List<ViewPortModel> models = [
    ViewPortModel(
        name: 'Monitor', size: const Size(48 * dpi, 23 * dpi), portrait: false),
    ViewPortModel(name: 'Tablet', size: const Size(10.2 * dpi, 8.6 * dpi)),
    ViewPortModel(name: 'Mobile', size: const Size(5.2 * dpi, 9.2 * dpi))
  ];

  static List<ViewPortModel> getAllModels() {
    return models;
  }
}