import 'package:flutter/material.dart';
import 'package:agriplant/pages/orders_page.dart';
import 'package:agriplant/models/marketplace.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewPostPage extends StatefulWidget {
  final Marketplace product;

  const NewPostPage({required this.product, super.key});

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _formKey = GlobalKey<FormState>();
  String transactionType = 'Sell';
  String selectedUnit = 'Kg';
  File? _image;
  bool _isImageUploadDisabled = false;
  bool _isPriceReadOnly = false;
  double? _fixedPricePerUnit;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fixedPricePerUnit = widget.product.price;
  }

  Future<void> pickImageFromGallery() async {
    if (_isImageUploadDisabled) return;
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _handleBuyMode() {
    setState(() {
      _image = null; // Don't use File for asset path
      _isImageUploadDisabled = true;
      _priceController.text = _fixedPricePerUnit.toString();
      _isPriceReadOnly = true;
    });
  }

  void _handleSellMode() {
    setState(() {
      _image = null;
      _isImageUploadDisabled = false;
      _priceController.clear();
      _isPriceReadOnly = false;
    });
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('I want to', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: 'Buy',
                          groupValue: transactionType,
                          onChanged: (value) {
                            transactionType = value!;
                            _handleBuyMode();
                          },
                        ),
                        const Text('Buy'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: 'Sell',
                          groupValue: transactionType,
                          onChanged: (value) {
                            transactionType = value!;
                            _handleSellMode();
                          },
                        ),
                        const Text('Sell'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Address', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () {
                      // Optional location picker
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Unit', style: TextStyle(fontSize: 16)),
                  Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedUnit,
                      iconSize: 30,
                      items: ['Kg', 'Grams', 'Ton'].map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUnit = value!;
                        });
                      },
                      underline: const SizedBox(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Quantity and Price', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity (in units)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      readOnly: _isPriceReadOnly,
                      decoration: const InputDecoration(
                        labelText: 'Price per unit',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (transactionType == 'Sell' &&
                            (value == null || value.isEmpty)) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Upload or Show image
              if (transactionType == 'Sell') ...[
                GestureDetector(
                  onTap: pickImageFromGallery,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _image == null
                        ? const Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else if (transactionType == 'Buy') ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset( // Use asset image for buy mode
                    widget.product.image,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Center(
                child: FilledButton(
                  onPressed: _validateForm()
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersPage(),
                      ),
                    );
                  }
                      : null,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
