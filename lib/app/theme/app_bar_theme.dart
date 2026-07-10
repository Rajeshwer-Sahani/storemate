import 'package:flutter/material.dart';

abstract final class StoreMateAppBarTheme {
  static AppBarTheme get appBarTheme {
    return const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,

      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),

      iconTheme: IconThemeData(
        size: 24,
      ),
    );
  }
}