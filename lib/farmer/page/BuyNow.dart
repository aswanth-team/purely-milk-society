import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerBuyNowPage extends StatefulWidget {
  final String productName;
  final int productPrice;
  final String productImageUrl; // Expecting the product name as an argument

  const FarmerBuyNowPage({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
  });

  @override
  _FarmerBuyNowPageState createState() => _FarmerBuyNowPageState();
}

class _FarmerBuyNowPageState extends State<FarmerBuyNowPage> {
  int quantity = 1;
  String? deliveryAddress;
  DateTime? selectedDate;
  bool isPlacingOrder = false;
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? productDetails;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  /// Fetch product details from Firestore
  Future<void> _fetchProductDetails() async {
    try {
      final querySnapshot = await _firestore
          .collection('cattleFeedProduct')
          .where('name', isEqualTo: widget.productName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          productDetails = querySnapshot.docs.first.data();
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${widget.productName}" not found!'),
          ),
        );
        Navigator.pop(context); // Return to the previous screen
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch product details: $e')),
      );
      Navigator.pop(context); // Return to the previous screen
    }
  }

  /// Function to select a delivery date
  void _selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// Function to calculate total price
  num _calculateTotalPrice() {
    if (productDetails == null) return 0;
    return (productDetails!['price'] as num) * quantity;
  }

  /// Function to place order and save to Firestore
  Future<void> _placeOrder() async {
    if (deliveryAddress == null || deliveryAddress!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address!')),
      );
      return;
    }
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery date!')),
      );
      return;
    }
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not logged in!')),
      );
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      final order = {
        'productName': productDetails!['name'],
        'quantity': quantity,
        'totalPrice': _calculateTotalPrice(),
        'address': deliveryAddress,
        'deliveryDate': selectedDate,
        'user_id': user.uid,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add order to Firestore
      await _firestore.collection('orders').add(order);

      // Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order placed successfully for $quantity item(s) to $deliveryAddress!',
          ),
        ),
      );

      // Reset form
      setState(() {
        quantity = 1;
        deliveryAddress = null;
        selectedDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    }

    setState(() {
      isPlacingOrder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.blue[800],
      ),
      body: Container(
        color: Colors.white, // Background color set to white
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressStep("Cart", true),
                  _buildProgressConnector(),
                  _buildProgressStep("Details", true),
                  _buildProgressConnector(),
                  _buildProgressStep("Confirm", false),
                ],
              ),
              const SizedBox(height: 16),

              // Product Details Section
              _buildSectionCard(
                icon: Icons.info,
                title: "Product Details",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productDetails!['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      productDetails!['description'] ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: \$${productDetails!['price']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quantity Section
              _buildSectionCard(
                icon: Icons.shopping_cart,
                title: "Select Quantity",
                child: DropdownButton<int>(
                  value: quantity,
                  items: List.generate(10, (index) => index + 1)
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      quantity = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Address Section
              _buildSectionCard(
                icon: Icons.location_on,
                title: "Delivery Address",
                child: TextField(
                  onChanged: (value) => deliveryAddress = value,
                  decoration: const InputDecoration(
                    hintText: 'Enter delivery address',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delivery Date Section
              _buildSectionCard(
                icon: Icons.calendar_today,
                title: "Delivery Date",
                child: TextButton(
                  onPressed: () => _selectDeliveryDate(context),
                  child: Text(
                    selectedDate == null
                        ? 'Select Date'
                        : '${selectedDate!.toLocal()}'.split(' ')[0],
                    style: TextStyle(fontSize: 16, color: Colors.blue[800]),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Total Price Section
              _buildSectionCard(
                icon: Icons.monetization_on,
                title: "Total Price",
                child: Text(
                  '\$${_calculateTotalPrice().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Place Order Button
              Center(
                child: ElevatedButton.icon(
                  icon: isPlacingOrder
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    isPlacingOrder ? 'Placing Order...' : 'Place Order',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: isPlacingOrder ? null : _placeOrder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required IconData icon, required String title, required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.blue.withOpacity(0.5), width: 2), // blue border
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blue[800]),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(String title, bool isCompleted) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isCompleted ? Colors.blue : Colors.grey,
          child: Icon(
            isCompleted ? Icons.check : Icons.circle,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isCompleted ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressConnector() {
    return Container(
      width: 30,
      height: 2,
      color: Colors.grey,
    );
  }
}
