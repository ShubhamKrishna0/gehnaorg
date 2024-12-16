import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'features/add_product/data/repositories/category_repository.dart';
import 'features/add_product/presentation/pages/add_product_page.dart';
import 'features/add_product/presentation/bloc/add_product_bloc.dart';
// Import other BLoCs if needed

void main() {
  final dio = Dio(); // Create a Dio instance
  final categoryRepository =
      CategoryRepository(dio); // Pass Dio to the repository

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddProductBloc(categoryRepository),
        ),
        // Add other BlocProviders here if needed
        // BlocProvider(
        //   create: (context) => AnotherBloc(),
        // ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GehnaMall',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AddProductPage(),
    );
  }
}
