// import 'package:dio/dio.dart';

// class ProductApi {
//   final Dio dio;

//   ProductApi(this.dio);

//   Future<void> uploadProduct(
//       String categoryCode, String subCategoryCode) async {
//     final identity = "BANSAL";
//     final url = 'http://3.110.34.172:8080/admin/upload/Products'
//         '?category=$categoryCode&subCategory=$subCategoryCode&wholeseller=$identity';

//     try {
//       final response = await dio.post(url);
//       if (response.statusCode == 200) {
//         print('Product uploaded successfully: ${response.data}');
//       } else {
//         print('Failed to upload product. Status code: ${response.statusCode}');
//         throw Exception('Failed to upload product');
//       }
//     } catch (e) {
//       print('Error occurred during product upload: $e');
//       rethrow;
//     }
//   }
// }
