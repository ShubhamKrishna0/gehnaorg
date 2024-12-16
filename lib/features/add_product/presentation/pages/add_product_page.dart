import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/subcategory_bloc/subcategory_bloc.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  Category? _selectedCategory;
  int? _selectedGender;

  @override
  Widget build(BuildContext context) {
    final dio = Dio();
    final categoryRepository = CategoryRepository(dio);
    final subCategoryRepository = SubCategoryRepository(dio);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AddProductBloc(
            categoryRepository: categoryRepository,
            subCategoryRepository: subCategoryRepository,
          )..loadCategories('BANSAL'),
        ),
        BlocProvider(
          create: (_) => SubCategoryBloc(subCategoryRepository),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text('Add Product')),
        body: BlocBuilder<AddProductBloc, List<Category>>(
          builder: (context, categories) {
            if (categories.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                // Category Dropdown
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DropdownButtonFormField<Category>(
                    isExpanded:
                        true, // Ensure DropdownButton takes up full width
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.categoryName),
                      );
                    }).toList(),
                    onChanged: (selectedCategory) {
                      setState(() {
                        _selectedCategory = selectedCategory;
                      });
                      if (selectedCategory != null &&
                          ['Gold', 'Silver', 'Diamond']
                              .contains(selectedCategory.categoryName)) {
                        // Load gender radio buttons if category is valid
                        context.read<SubCategoryBloc>().loadSubCategories(
                              categoryCode: selectedCategory.categoryCode,
                              genderCode: 1, // Default gender for initial load
                              wholeseller: 'BANSAL',
                            );
                      }
                    },
                    decoration: InputDecoration(labelText: 'Select Category'),
                  ),
                ),

                // Conditionally show Radio buttons for Gold, Silver, and Diamond categories
                if (_selectedCategory != null &&
                    ['Gold', 'Silver', 'Diamond']
                        .contains(_selectedCategory!.categoryName))
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          // This ensures the radio button takes only available width
                          child: RadioListTile<int>(
                            title: Text('Male'),
                            value: 1,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                              if (value != null) {
                                context
                                    .read<SubCategoryBloc>()
                                    .loadSubCategories(
                                      categoryCode:
                                          _selectedCategory!.categoryCode,
                                      genderCode: value,
                                      wholeseller: 'BANSAL',
                                    );
                              }
                            },
                          ),
                        ),
                        Expanded(
                          // Ensure proper width constraint for the second radio button
                          child: RadioListTile<int>(
                            title: Text('Female'),
                            value: 2,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                              if (value != null) {
                                context
                                    .read<SubCategoryBloc>()
                                    .loadSubCategories(
                                      categoryCode:
                                          _selectedCategory!.categoryCode,
                                      genderCode: value,
                                      wholeseller: 'BANSAL',
                                    );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // Subcategory Dropdown after selecting gender
                BlocBuilder<SubCategoryBloc, SubCategoryState>(
                  builder: (context, state) {
                    if (state is SubCategoryLoading) {
                      return CircularProgressIndicator();
                    } else if (state is SubCategoryLoaded) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DropdownButtonFormField<SubCategory>(
                          isExpanded:
                              true, // Ensure Dropdown takes up full width
                          items: state.subcategories.map((subcategory) {
                            return DropdownMenuItem(
                              value: subcategory,
                              child: Text(subcategory.subcategoryName),
                            );
                          }).toList(),
                          onChanged: (subcategory) {
                            // Handle subcategory selection
                          },
                          decoration:
                              InputDecoration(labelText: 'Select Subcategory'),
                        ),
                      );
                    } else if (state is SubCategoryError) {
                      return Text(state.message);
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
