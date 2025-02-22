import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerListPage extends StatefulWidget {
  @override
  _FarmerListPageState createState() => _FarmerListPageState();
}

class _FarmerListPageState extends State<FarmerListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers Management'),
        backgroundColor: Color.fromARGB(255, 33, 150, 243),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('farmer').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Failed to load farmers. Please try again later.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No farmers found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final farmers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: farmers.length,
            itemBuilder: (context, index) {
              final farmerDoc = farmers[index];
              final farmerId = farmerDoc.id;
              final farmerData = farmerDoc.data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 33, 150, 243),
                    child: Text(
                      farmerData['name'] != null &&
                              farmerData['name']!.isNotEmpty
                          ? farmerData['name']![0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    farmerData['name'] ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${farmerData['email'] ?? 'N/A'}'),
                      Text('Phone: ${farmerData['phone'] ?? 'N/A'}'),
                      Text('No. of cows : ${farmerData['cow'] ?? 'N/A'}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateFarmerPage(
                          farmerId: farmerId,
                          farmerData: farmerData,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UpdateFarmerPage extends StatefulWidget {
  final String farmerId;
  final Map<String, dynamic> farmerData;

  const UpdateFarmerPage({
    required this.farmerId,
    required this.farmerData,
    Key? key,
  }) : super(key: key);

  @override
  _UpdateFarmerPageState createState() => _UpdateFarmerPageState();
}

class _UpdateFarmerPageState extends State<UpdateFarmerPage> {
  final _formKey = GlobalKey<FormState>();
  final _todayQuantityController = TextEditingController();
  final _todayPaymentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int? _totalQuantity;
  double? _totalPayment;

  @override
  void initState() {
    super.initState();
    _fetchFarmerData();
  }

  Future<void> _fetchFarmerData() async {
    try {
      final doc =
          await _firestore.collection('farmerSales').doc(widget.farmerId).get();

      if (doc.exists) {
        setState(() {
          _totalQuantity = doc.data()?['totalQuantity'] ?? 0;
          _totalPayment = doc.data()?['totalPayment']?.toDouble() ?? 0.0;
        });
      } else {
        // Initialize values if no document exists
        setState(() {
          _totalQuantity = 0;
          _totalPayment = 0.0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching farmer data: $e')),
      );
    }
  }

  Future<void> _updateFarmerSales() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final todayQuantity = int.parse(_todayQuantityController.text);
      final todayPayment = double.parse(_todayPaymentController.text);

      // Use Firestore transaction to safely increment values
      await _firestore.runTransaction((transaction) async {
        final docRef =
            _firestore.collection('farmerSales').doc(widget.farmerId);

        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          transaction.set(docRef, {
            'userId': widget.farmerId,
            'totalQuantity': todayQuantity,
            'totalPayment': todayPayment,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          final currentQuantity = snapshot.data()?['totalQuantity'] ?? 0;
          final currentPayment =
              snapshot.data()?['totalPayment']?.toDouble() ?? 0.0;

          transaction.update(docRef, {
            'totalQuantity': currentQuantity + todayQuantity,
            'totalPayment': currentPayment + todayPayment,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer sales updated successfully!')),
      );

      // Clear the input fields
      _todayQuantityController.clear();
      _todayPaymentController.clear();

      // Refresh the displayed data
      _fetchFarmerData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update sales: $e')),
      );
    }
  }

  @override
  void dispose() {
    _todayQuantityController.dispose();
    _todayPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Farmer: ${widget.farmerData['name'] ?? 'N/A'}'),
        backgroundColor: Color.fromARGB(255, 33, 150, 243),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Input fields and update button
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Today’s Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _todayQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Today’s Quantity (in liters)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter today’s quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _todayPaymentController,
                    decoration: const InputDecoration(
                      labelText: 'Today’s Payment (in ₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter today’s payment';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateFarmerSales,
                      child: const Text('Update Sales'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 33, 150, 243),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Section 2: Display total quantity and total payment
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Sales Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total Quantity: ${_totalQuantity ?? 'Loading...'} liters',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Payment: ₹${_totalPayment?.toStringAsFixed(2) ?? 'Loading...'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
