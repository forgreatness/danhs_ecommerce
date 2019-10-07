import 'package:flutter/material.dart';
import 'package:danhs_ecommerce/ui/search_items.dart';

void main() {
  runApp(new MaterialApp(
    title: 'Danh\'s Ecommerce',
    theme: new ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: new SearchItems(),
  ));
}