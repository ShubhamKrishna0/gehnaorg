import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/subcategory_bloc/subcategory_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _wastageController = TextEditingController();
  final _weightController = TextEditingController();

  Category? _selectedCategory;
  int? _selectedGender;
  String? _selectedKarat = '18K';
  XFile? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });
  }

  // Function to delete the selected image
  void _deleteImage() {
    setState(() {
      _selectedImage = null;
    });
  }

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
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Category Dropdown
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<Category>(
                        isExpanded: true,
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
                            context.read<SubCategoryBloc>().loadSubCategories(
                                  categoryCode: selectedCategory.categoryCode,
                                  genderCode:
                                      1, // Default gender for initial load
                                  wholeseller: 'BANSAL',
                                );
                          }
                        },
                        decoration:
                            InputDecoration(labelText: 'Select Category'),
                      ),
                    ),

                    // Gender Radio Buttons
                    if (_selectedCategory != null &&
                        ['Gold', 'Silver', 'Diamond']
                            .contains(_selectedCategory!.categoryName))
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
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

                    // Subcategory Dropdown
                    BlocBuilder<SubCategoryBloc, SubCategoryState>(
                      builder: (context, state) {
                        if (state is SubCategoryLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is SubCategoryLoaded) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DropdownButtonFormField<SubCategory>(
                              isExpanded: true,
                              items: state.subcategories.map((subcategory) {
                                return DropdownMenuItem(
                                  value: subcategory,
                                  child: Text(subcategory.subcategoryName),
                                );
                              }).toList(),
                              onChanged: (subcategory) {
                                // Handle subcategory selection
                              },
                              decoration: InputDecoration(
                                  labelText: 'Select Subcategory'),
                            ),
                          );
                        } else if (state is SubCategoryError) {
                          return Text(state.message);
                        }
                        return SizedBox.shrink();
                      },
                    ),

                    // Product Details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration: InputDecoration(labelText: 'Product Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a product name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _wastageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Wastage (%)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wastage percentage';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Weight (g)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight in grams';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Image Picker
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: Text('Pick Image'),
                          ),
                          if (_selectedImage != null)
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: _deleteImage,
                            ),
                        ],
                      ),
                    ),
                    if (_selectedImage != null)
                      Image.file(
                        File(_selectedImage!.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),

                    // Karat Selection Dropdown
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedKarat,
                        items: ['18K', '20K', '22K', '24K']
                            .map((karat) => DropdownMenuItem(
                                  value: karat,
                                  child: Text(karat),
                                ))
                            .toList(),
                        onChanged: (karat) {
                          setState(() {
                            _selectedKarat = karat;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Select Karat'),
                      ),
                    ),

                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Logic to save the data
                            final productData = {
                              'name': _productNameController.text,
                              'description': _descriptionController.text,
                              'wastage': double.parse(_wastageController.text),
                              'weight': double.parse(_weightController.text),
                              'category': _selectedCategory?.categoryName,
                              'gender':
                                  _selectedGender == 1 ? 'Male' : 'Female',
                              'karat': _selectedKarat,
                              'image': _selectedImage?.path,
                            };
                            // Process the product data (e.g., submit to the server)
                          }
                        },
                        child: Text('Add Product'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
