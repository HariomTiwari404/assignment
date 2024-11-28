import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/cart_bloc.dart';
import 'cart_screen.dart';
import 'product_list_screen.dart';
import 'theme.dart'; // Import the custom theme

void main() {
  runApp(
    BlocProvider(
      create: (_) => CartBloc(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CartBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shopping Cart',
        theme: appTheme,
        home: ProductListScreen(),
        routes: {
          '/cart': (context) => const CartScreen(),
        },
      ),
    );
  }
}
