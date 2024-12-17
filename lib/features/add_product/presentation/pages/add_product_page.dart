import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  // Function to pick images from gallery
  Future<void> _pickImages(ImageSource source) async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _selectedImages.addAll(pickedImages);
      });
    }
  }

  // Function to capture an image from camera
  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
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
                    // Image Picker Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Images',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _pickImages(ImageSource.gallery),
                                child: Text('Pick from Gallery'),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _captureImage,
                                child: Text('Capture with Camera'),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (_selectedImages.isNotEmpty)
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(
                                _selectedImages.length,
                                (index) {
                                  return Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.file(
                                        File(_selectedImages[index].path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () => _removeImage(index),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
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
                              'images': _selectedImages
                                  .map((img) => img.path)
                                  .toList(),
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
