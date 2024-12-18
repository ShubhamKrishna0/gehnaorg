import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart';
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
  SubCategory? _selectedSubCategory;
  int? _selectedGender;
  String? _selectedKarat = '18K';

  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  Future<void> _pickImages(ImageSource source) async {
    print("Picking images from gallery...");
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null &&
        _selectedImages.length + pickedImages.length <= 7) {
      print("Picked ${pickedImages.length} images.");
      setState(() {
        _selectedImages.addAll(pickedImages);
      });
    } else {
      print("Exceeded image limit. Showing error message.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can select a maximum of 7 images.')),
      );
    }
  }

  // Function to capture an image from camera
  Future<void> _captureImage() async {
    print("Capturing image from camera...");
    if (_selectedImages.length >= 7) {
      print("Exceeded image limit. Showing error message.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can select a maximum of 7 images.')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      print("Captured image: ${image.path}");
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    print("Removing image at index: $index");
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProduct() async {
    print("Submitting product...");
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed.");
      return;
    }

    if (_selectedImages.isEmpty || _selectedImages.length > 7) {
      print("Invalid image selection.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select between 1 and 7 images.')),
      );
      return;
    }

    if (_selectedCategory == null || _selectedSubCategory == null) {
      print("Category or subcategory not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category and Subcategory are required!')),
      );
      return;
    }

    final dio = Dio();
    final String categoryCode = _selectedCategory!.categoryCode.toString();
    final String subCategoryCode =
        _selectedSubCategory!.subcategoryCode.toString();

    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      final String identity = loginState.login.identity;
      final String token = loginState.login.token;
      print("Login successful! Identity: $identity, Token: $token");
      final String url =
          'http://3.110.34.172:8080/admin/upload/Products?category=$categoryCode&subCategory=$subCategoryCode&wholeseller=$identity';
      print("URL for product upload: $url");
      try {
        print("Preparing images for upload...");
        // Directly convert images to MultipartFile without compression
        List<MultipartFile> imageFiles = await Future.wait(_selectedImages.map(
          (XFile image) async {
            final bytes = await image.readAsBytes();
            return MultipartFile.fromBytes(
              bytes,
              filename: image.name,
              contentType: DioMediaType.parse('image/jpeg'),
            );
          },
        ));

        print("Images ready, preparing form data...");
        final formData = FormData.fromMap({
          'productName': _productNameController.text,
          'description': _descriptionController.text,
          'wastage': _wastageController.text,
          'weight': _weightController.text,
          'karat': _selectedKarat,
          'genderCode': _selectedGender == 1 ? '1' : '2',
          'images': imageFiles,
        });

        print("Sending data to server...");
        final response = await dio.post(
          url,
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        // Correctly access the 'status' field in the response
        if (response.data['status'] == 0) {
          print("Product added successfully!");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product added successfully!')),
          );

          // Reset all fields after successful submission
          _resetForm();
        } else {
          print("Failed with status: ${response.data['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.data['message']}')),
          );
        }
      } on DioException catch (e) {
        print("DioException: ${e.response?.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${e.response?.statusCode}')),
        );
      } catch (e) {
        print("Unexpected error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error occurred!')),
        );
      }
    }
  }

// Method to reset all form fields
  void _resetForm() {
    setState(() {
      _productNameController.clear();
      _descriptionController.clear();
      _wastageController.clear();
      _weightController.clear();
      _selectedCategory = null;
      _selectedSubCategory = null;
      _selectedGender = null;
      _selectedKarat = '18K';
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Building UI...");
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
              print("Loading categories...");
              return Center(child: CircularProgressIndicator());
            }
            print("Categories loaded: ${categories.length}");
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
                          print(
                              "Category selected: ${selectedCategory?.categoryName}");
                          setState(() {
                            _selectedCategory = selectedCategory;
                          });

                          if (selectedCategory != null &&
                              ['Gold', 'Silver', 'Diamond']
                                  .contains(selectedCategory.categoryName)) {
                            // For Gold, Silver, Diamond, pass genderCode: 1
                            context.read<SubCategoryBloc>().loadSubCategories(
                                  categoryCode: selectedCategory.categoryCode,
                                  genderCode:
                                      1, // Default gender for Gold, Silver, Diamond
                                  wholeseller: 'BANSAL',
                                );
                          } else {
                            // For other categories, pass genderCode: null (if genderCode is nullable)
                            context.read<SubCategoryBloc>().loadSubCategories(
                                  categoryCode:
                                      selectedCategory?.categoryCode ??
                                          0, // Default value if null
                                  genderCode:
                                      null, // Null gender for other categories
                                  wholeseller: 'BANSAL',
                                );
                          }
                        },
                        decoration:
                            InputDecoration(labelText: 'Select Category'),
                      ),
                    ),

                    // Gender Radio Buttons (Only for Gold, Silver, and Diamond)
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
                                  print("Gender selected: Male");
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
                                  print("Gender selected: Female");
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
                    BlocBuilder<SubCategoryBloc, SubCategoryState>(
                      builder: (context, state) {
                        if (state is SubCategoryLoading) {
                          print("Loading subcategories...");
                          return Center(child: CircularProgressIndicator());
                        }
                        if (state is SubCategoryLoaded) {
                          final subCategories = state.subcategories;
                          print(
                              "Subcategories loaded: ${subCategories.length}");
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DropdownButtonFormField<SubCategory>(
                              isExpanded: true,
                              items: subCategories.map((subCategory) {
                                return DropdownMenuItem(
                                  value: subCategory,
                                  child: Text(subCategory.subcategoryName),
                                );
                              }).toList(),
                              onChanged: (selectedSubCategory) {
                                print(
                                    "Subcategory selected: ${selectedSubCategory?.subcategoryName}");
                                setState(() {
                                  _selectedSubCategory = selectedSubCategory;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: 'Select SubCategory'),
                            ),
                          );
                        }
                        return SizedBox();
                      },
                    ),

                    // Other input fields for product details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration: InputDecoration(labelText: 'Product Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
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
                        decoration: InputDecoration(labelText: 'Wastage'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wastage';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(labelText: 'Weight'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Karat Dropdown
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedKarat,
                        onChanged: (value) {
                          print("Karat selected: $value");
                          setState(() {
                            _selectedKarat = value;
                          });
                        },
                        items: ['18K', '22K', '24K']
                            .map((karat) => DropdownMenuItem<String>(
                                  value: karat,
                                  child: Text(karat),
                                ))
                            .toList(),
                        decoration: InputDecoration(labelText: 'Select Karat'),
                      ),
                    ),
                    // Image Picker Buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _pickImages(ImageSource.gallery),
                            child: Text('Pick Images'),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _captureImage,
                            child: Text('Capture Image'),
                          ),
                        ],
                      ),
                    ),

                    // Display Selected Images
                    if (_selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          children: _selectedImages.map((image) {
                            return Stack(
                              children: [
                                Image.file(
                                  File(image.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () => _removeImage(
                                        _selectedImages.indexOf(image)),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _submitProduct,
                        child: Text('Submit'),
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
