import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketplacePage extends StatefulWidget {
  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  int _currentIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dsdvk2lms/image/upload';
  final String uploadPreset = 'milk project';

  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _sections = [
      _marketplaceSection(),
      _postProductSection(),
      _myPostingsSection(),
      MyOrdersWidget(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Purely Dairy Society Marketplace"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 33, 150, 243),
      ),
      body: _sections[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Color.fromARGB(255, 33, 150, 243),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.store), label: "Marketplace"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box), label: "Post Product"),
          BottomNavigationBarItem(
              icon: Icon(Icons.post_add), label: "My Postings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "My Orders"),
        ],
      ),
    );
  }

  Widget _marketplaceSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('marketplace')
          .where('postedBy',
              isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('isAvailable', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        // If the stream has not yet fetched data, show a loading indicator
        if (!snapshot.hasData) {
          return Center(
            child: Text(
              "No products are available yet!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final products = snapshot.data!.docs;

        // If there are no products to display, show a message
        if (products.isEmpty || !snapshot.hasData) {
          return Center(
            child: Text(
              "No products are available yet!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        // Otherwise, display the list of products
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product['imageUrl'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  product['title'], // Display product title here
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Price: ₹${product['price']}",
                    style: TextStyle(color: Colors.green)),
                trailing: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () =>
                      _sendRequest(product.id, product['postedBy']),
                  child: Text("Request"),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _sendRequest(String productId, String farmerId) async {
    try {
      await _firestore.collection('notifications').add({
        'productId': productId,
        'farmerId': farmerId,
        'status': 'pending',
        'requestedBy': FirebaseAuth
            .instance.currentUser?.uid, // Replace with current user ID
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Request sent to farmer")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to send request")));
    }
  }

  Widget _postProductSection() {
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final titleController =
        TextEditingController(); // Controller for product title

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Post a Product",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Product Title Field
          TextField(
            controller: titleController, // Use the new controller
            decoration: InputDecoration(
              labelText: "Product Title",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 16),

          // Product Description Field
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: "Product Description",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 16),

          // Product Price Field
          TextField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: "Expected Price",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),

          // Image Upload Section
          Text(
            "Upload Image",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _selectedImage = pickedFile;
                });
              }
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: FileImage(File(_selectedImage!.path)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          SizedBox(height: 16),

          // Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50)),
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }
              if (_selectedImage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please upload an image")),
                );
                return;
              }

              // Show uploading state
              setState(() => _isUploading = true);

              try {
                final imageUrl =
                    await _uploadImageToCloudinary(_selectedImage!);
                if (imageUrl == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to upload image")),
                  );
                } else {
                  await _firestore.collection('marketplace').add({
                    'title':
                        titleController.text, // Add product title to Firestore
                    'description': descriptionController.text,
                    'price': double.parse(priceController.text),
                    'imageUrl': imageUrl,
                    'isAvailable': true,
                    'postedBy': FirebaseAuth.instance.currentUser?.uid,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Product posted successfully")),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to post product")),
                );
              } finally {
                setState(() => _isUploading = false);
              }
            },
            child: _isUploading
                ? CircularProgressIndicator()
                : Text("Post Product"),
          ),
        ],
      ),
    );
  }

  Future<String?> _uploadImageToCloudinary(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return json['secure_url'];
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Widget _myPostingsSection() {
    return _sectionList('marketplace', 'postedBy', "My Postings");
  }

  Widget _sectionList(String collection, String field, String title) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(collection)
          .where(field, isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data!.docs;

        // If there are no items in the list
        if (items.isEmpty) {
          return Center(
            child: Text(
              "No items found!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return Card(
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['imageUrl'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  item['title'], // Display product title here
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Price: ₹${item['price']}",
                    style: TextStyle(color: Colors.green)),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // Confirm before deletion
                    bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Delete Product"),
                          content: Text(
                              "Are you sure you want to delete this product?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );

                    // If confirmed, delete the document
                    if (confirmDelete ?? false) {
                      try {
                        await _firestore
                            .collection(collection)
                            .doc(item.id)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Product deleted successfully")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to delete product")),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MyOrdersWidget extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return _buildMyOrdersSection();
  }

  Widget _buildMyOrdersSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .where('orderedBy', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return Center(
            child: Text(
              "No orders placed yet!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final productDetails = order['productDetails'] ?? {};

            return Card(
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: productDetails['imageUrl'] != null
                      ? Image.network(
                          productDetails['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image, size: 60, color: Colors.grey),
                ),
                title: Text(
                  productDetails['title'] ?? 'Product',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Price: ₹${productDetails['price'] ?? 'N/A'}",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
