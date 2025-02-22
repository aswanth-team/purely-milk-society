import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderManagement extends StatefulWidget {
  @override
  _OrderManagementState createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Function to update the order status
  Future<void> _updateStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  /// Function to view order details in a dialog
  void _viewOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${order['orderId'] ?? 'N/A'}'),
              Text('Customer Name: ${order['customerName'] ?? 'N/A'}'),
              Text('Details: ${order['orderDetails'] ?? 'N/A'}'),
              Text('Total Price: ₹${order['totalPrice'] ?? 0}'),
              Text('Status: ${order['status'] ?? 'N/A'}'),
              Text(
                'Delivery Date: ${_formatTimestamp(order['deliveryDate']) ?? 'N/A'}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Helper function to format Firestore Timestamp
  String? _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return null;
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  /// Helper function to get color based on order status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'Delivered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('orders')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Something went wrong! Please try again later.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No orders available.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final orders = snapshot.data!.docs;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final orderId = order.id;
                final data = order.data() as Map<String, dynamic>;

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      'Product: ${data['productName'] ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${data['address'] ?? 'N/A'}'),
                        Text('Total Price: ₹${data['totalPrice'] ?? 0}'),
                        Text(
                          'Delivery Date: ${_formatTimestamp(data['deliveryDate']) ?? 'N/A'}',
                        ),
                        Text('Quantity : ${data['quantity'] ?? 0}'),
                        Text(
                          'Status: ${data['status'] ?? 'N/A'}',
                          style: TextStyle(
                            color: _getStatusColor(data['status'] ?? ''),
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'View Details') {
                          _viewOrderDetails(data);
                        } else {
                          _updateStatus(orderId, value);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'View Details',
                          child: Text('View Details'),
                        ),
                        const PopupMenuItem(
                          value: 'Pending',
                          child: Text('Mark as Pending'),
                        ),
                        const PopupMenuItem(
                          value: 'Shipped',
                          child: Text('Mark as Shipped'),
                        ),
                        const PopupMenuItem(
                          value: 'Delivered',
                          child: Text('Mark as Delivered'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
