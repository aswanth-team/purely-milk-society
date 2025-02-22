import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerNotificationPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Farmer Notifications"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 33, 150, 243),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('notifications')
            .where('farmerId',
                isEqualTo: FirebaseAuth.instance.currentUser
                    ?.uid) // Replace with current farmer ID
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data!.docs;
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                "No notifications yet!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 33, 150, 243),
                    child: Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    "Product: ${notification['productId']}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text("Requested by: ${notification['requestedBy']}"),
                      SizedBox(height: 4),
                      Text(
                        "Status: ${notification['status'].toUpperCase()}",
                        style: TextStyle(
                          color: notification['status'] == 'pending'
                              ? Colors.orange
                              : notification['status'] == 'accepted'
                                  ? Color.fromARGB(255, 33, 150, 243)
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: notification['status'] == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => _updateNotificationStatus(
                                  notification.id, 'accepted'),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => _updateNotificationStatus(
                                  notification.id, 'rejected'),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateNotificationStatus(
      String notificationId, String status) async {
    try {
      final notificationDoc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();

      if (!notificationDoc.exists) {
        print("Notification not found");
        return;
      }

      final notificationData = notificationDoc.data()!;
      final productId = notificationData['productId'];
      final requestedBy = notificationData['requestedBy'];

      if (status == 'accepted') {
        // Fetch product details
        final productDoc =
            await _firestore.collection('marketplace').doc(productId).get();

        if (productDoc.exists) {
          final productData = productDoc.data();

          // Add to orders collection
          await _firestore.collection('orders').add({
            'productId': productId,
            'orderedBy': requestedBy,
            'orderDate': Timestamp.now(),
            'productDetails': productData, // Save product details
          });

          // Update product availability
          await _firestore
              .collection('marketplace')
              .doc(productId)
              .update({'isAvailable': false});
        }
      }

      // Update notification status
      if (status == 'rejected') {
        // Delete the notification if rejected
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .delete();
      } else {
        // Update the notification for accepted status
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .update({'status': status});
      }
    } catch (e) {
      print("Error updating notification status: $e");
    }
  }
}
