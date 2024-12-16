import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';

class AddProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dio = Dio(); // Create a Dio instance
    final categoryRepository =
        CategoryRepository(dio); // Pass Dio to the repository

    return BlocProvider(
      create: (context) =>
          AddProductBloc(categoryRepository)..loadCategories('BANSAL'),
      child: Scaffold(
        appBar: AppBar(title: Text('Add Product')),
        body: BlocBuilder<AddProductBloc, List<Category>>(
          builder: (context, categories) {
            if (categories.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            return DropdownButtonFormField<Category>(
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.categoryName),
                );
              }).toList(),
              onChanged: (category) {
                // Handle selection
              },
              decoration: InputDecoration(labelText: 'Select Category'),
            );
          },
        ),
      ),
    );
  }
}
