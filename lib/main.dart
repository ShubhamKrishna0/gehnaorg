import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:gehnaorg/features/add_product/data/repositories/login_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart'; // Import LoginBloc
import 'package:gehnaorg/features/add_product/presentation/pages/add_product_page.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/home_page.dart';
import 'package:gehnaorg/features/add_product/presentation/pages/login_page.dart';

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
        // Provide the LoginBloc at the top level
        BlocProvider(
          create: (_) => LoginBloc(
              loginRepository: DependencyInjection.resolve<LoginRepository>()),
        ),
        // Provide the AddProductBloc
        BlocProvider(
          create: (_) => DependencyInjection.resolve<AddProductBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: Size(375, 812), // Set your design size (common iPhone size)
        builder: (context, child) {
          return MaterialApp(
            title: 'GehnaMall',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.grey[100],
            ),
            home: LoginPage(), // Show LoginPage first
            routes: {
              '/add_product': (context) => AddProductPage(),
              '/home': (context) => HomePage(), // Add a route for HomePage
            },
          );
        },
      ),
    );
  }
}
