import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';

part 'add_product_event.dart';
part 'add_product_state.dart';

class AddProductBloc extends Cubit<List<Category>> {
  final CategoryRepository categoryRepository;

  AddProductBloc(this.categoryRepository) : super([]);

  Future<void> loadCategories(String wholeseller) async {
    try {
      final categories = await categoryRepository.fetchCategories(wholeseller);
      emit(categories);
    } catch (e) {
      emit([]);
      throw Exception('Failed to load categories');
    }
  }
}
