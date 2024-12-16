import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';
import 'features/add_product/data/repositories/category_repository.dart';
import 'features/add_product/data/repositories/subcategory_repository.dart';
import 'features/add_product/presentation/pages/add_product_page.dart';
import 'app/di_container.dart'; // Dependency Injection

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the dependency injection container
  await DependencyInjection.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DependencyInjection.resolve<AddProductBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'GehnaMall',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: AddProductPage(),
      ),
    );
  }
}
