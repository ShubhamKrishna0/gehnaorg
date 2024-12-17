//lib\features\add_product\apis

import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';

class CategoryApi {
  final Dio _dio;

  CategoryApi(this._dio);

  Future<List<Category>> getCategories(String wholeseller) async {
    try {
      final response = await _dio.get(
        'http://3.110.34.172:8080/api/categories',
        queryParameters: {'wholeseller': wholeseller},
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Category.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
