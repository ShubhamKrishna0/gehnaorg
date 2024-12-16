import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';

class SubCategoryRepository {
  final Dio dio;

  SubCategoryRepository(this.dio);

  Future<List<SubCategory>> fetchSubCategories({
    required int categoryCode,
    required String wholeseller,
    required int genderCode,
  }) async {
    try {
      final response = await dio.get(
        'http://3.110.34.172:8080/api/subCategories/$categoryCode',
        queryParameters: {
          'wholeseller': wholeseller,
          'gender': genderCode,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => SubCategory.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch subcategories');
      }
    } catch (e) {
      throw Exception('Error fetching subcategories: $e');
    }
  }
}