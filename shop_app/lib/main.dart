import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/cart_provider.dart';
import 'package:shop_app/home_page.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
      title: 'Shopping App',
      theme: ThemeData.light().copyWith(
        textTheme: ThemeData.light().textTheme.copyWith(
        titleLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 35,
          fontFamily: "Lato",
          color: Colors.black,
        ),
        bodySmall: const TextStyle(
          fontFamily: "Lato",
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
        titleMedium: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
          fontFamily: "Lato",
        ),
        ),
        colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromRGBO(254, 206, 1, 1),
        primary: const Color.fromRGBO(254, 206, 1, 1),
        ),
        appBarTheme: AppBarTheme(
        backgroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: const TextStyle(
          fontFamily: "Lato",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        prefixIconColor: Color.fromRGBO(119, 119, 119, 1),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      ),
    );
  }
}
