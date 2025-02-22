import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:milkproject/society/farmeraccount.dart';
import 'package:milkproject/society/page/announcement.dart';
import 'package:milkproject/society/page/ordermanagement.dart';
import 'package:milkproject/society/page/product_upload.dart';
import 'package:milkproject/society/page/marketplace.dart';
import 'package:milkproject/society/page/profilepage.dart';
import 'package:milkproject/society/page/userAccount.dart';
import 'package:milkproject/society/page/viewfeedback.dart';

class MilkProjectHomePage extends StatelessWidget {
  const MilkProjectHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Purely Dairy Society',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to Notifications Page
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NotificationPage()));
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigate to Profile Page
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carousel Slider for Announcements
              _buildCarouselSlider(),
              const SizedBox(height: 20),

              // Quick Stats Dashboard
              _buildQuickStats(),

              const SizedBox(height: 20),

              // Feature Sections
              _buildFeatureSections(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Side Navigation Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 8, 111, 255)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('asset/user.png'),
                ),
                SizedBox(height: 10),
                Text(
                  'Admin Name',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'Admin Email',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Farmer Accounts'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => FarmerListPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('User Accounts'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => UserAccountPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Order Management'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OrderManagement()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Milk Product Upload'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => UserProductUpload()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Cattle Feed Product Upload'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CattleFeedProductUpload()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => FeedbackViewPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NotificationPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket_rounded),
            title: const Text('MarketPlace'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AdminMarketplace()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSlider() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .doc('main')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching announcements'));
        }

        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Center(child: Text('No announcements available'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List<String> imgList = (data['image_urls'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [];

        if (imgList.isEmpty) {
          return const Center(child: Text('No announcements available'));
        }

        return CarouselSlider(
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 5),
          ),
          items: imgList
              .map((item) => Container(
                    margin: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      image: DecorationImage(
                        image: NetworkImage(item),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

// Quick Stats Dashboard
  Widget _buildQuickStats() {
    return StreamBuilder<int>(
      stream: _getPendingOrdersStream(), // Stream for pending orders
      builder: (context, pendingOrdersSnapshot) {
        return StreamBuilder<double>(
          stream: _getTotalSalesStream(), // Stream for total sales
          builder: (context, totalSalesSnapshot) {
            return StreamBuilder<int>(
              stream: _getFeedbackCountStream(), // Stream for feedback count
              builder: (context, feedbackSnapshot) {
                if (pendingOrdersSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    totalSalesSnapshot.connectionState ==
                        ConnectionState.waiting ||
                    feedbackSnapshot.connectionState ==
                        ConnectionState.waiting) {
                  // Return loading indicators if any stream is waiting
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard('Total Sales', '...', Icons.attach_money,
                          Colors.blue),
                      _buildStatCard('Pending Orders', '...',
                          Icons.shopping_cart, Colors.blue),
                      _buildStatCard(
                          'Feedback', '...', Icons.feedback, Colors.orange),
                    ],
                  );
                } else if (pendingOrdersSnapshot.hasError ||
                    totalSalesSnapshot.hasError ||
                    feedbackSnapshot.hasError) {
                  return Text(
                      'Error: ${pendingOrdersSnapshot.error ?? totalSalesSnapshot.error ?? feedbackSnapshot.error}');
                } else {
                  final pendingOrders = pendingOrdersSnapshot.data ?? 0;
                  final totalSales = totalSalesSnapshot.data ?? 0.0;
                  final totalFeedback = feedbackSnapshot.data ?? 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(
                          'Total Sales',
                          '₹${totalSales.toStringAsFixed(2)}',
                          Icons.attach_money,
                          Colors.blue),
                      _buildStatCard('Pending Orders', '$pendingOrders',
                          Icons.shopping_cart, Colors.blue),
                      _buildStatCard(
                          'Feedback',
                          '$totalFeedback', // Display actual feedback count
                          Icons.feedback,
                          Colors.orange),
                    ],
                  );
                }
              },
            );
          },
        );
      },
    );
  }

// Stream for getting the total sales
  Stream<double> _getTotalSalesStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Delivered')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.fold<double>(
          0.0,
          (sum, doc) =>
              sum +
              (doc['totalPrice'] is num ? doc['totalPrice'].toDouble() : 0));
    });
  }

// Stream for getting the number of pending orders
  Stream<int> _getPendingOrdersStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.length);
  }

// Stream for getting the number of feedbacks
  Stream<int> _getFeedbackCountStream() {
    return FirebaseFirestore.instance
        .collection('feedback') // Listen to 'feedback' collection
        .snapshots() // Listen for real-time updates
        .map((querySnapshot) =>
            querySnapshot.docs.length); // Count number of documents (feedbacks)
  }

  // Individual Stat Card
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Feature Sections
  Widget _buildFeatureSections(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildFeatureCard(
                context, 'User Accounts', Icons.people, 'asset/user.png', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => UserAccountPage()));
            }),
            _buildFeatureCard(context, 'Order Management', Icons.shopping_cart,
                'asset/order.png', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => OrderManagement()));
            }),
            _buildFeatureCard(
                context, 'Feedback', Icons.feedback, 'asset/feedback.png', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => FeedbackViewPage()));
            }),
            _buildFeatureCard(
                context, 'Notifications', Icons.notifications, 'asset/noti.png',
                () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => NotificationPage()));
            }),
          ],
        ),
      ],
    );
  }

  // Individual Feature Card
  Widget _buildFeatureCard(BuildContext context, String title, IconData icon,
      String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 50, width: 50, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.announcement),
          label: 'Announcement',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: const Color.fromARGB(255, 32, 122, 161),
      onTap: (index) {
        // Handle navigation based on index
        switch (index) {
          case 0:
            // Already on Home
            break;
          case 1:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => PostAnnouncementPage()));
            break;
          case 2:
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfilePage()));
            break;
        }
      },
    );
  }
}

class NotificationPage extends StatelessWidget {
  NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 111, 255),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('orders')
              .where('status', isEqualTo: 'Pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No pending orders.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final notifications = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'name': data['productName'] ?? 'Unknown Product',
                'quantity': data['quantity'] ?? 0,
                'timestamp': data['timestamp'] ?? '',
                'address': data['address'] ?? 'No Address',
              };
            }).toList();

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(
                  name: notification['name'] ?? '',
                  quantity: notification['quantity'] ?? 0,
                  timestamp: notification['timestamp'] ?? '',
                  address: notification['address'] ?? '',
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Notification card widget
  Widget _buildNotificationCard({
    required String name,
    required int quantity,
    required dynamic timestamp,
    required String address,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification icon
            CircleAvatar(
              backgroundColor:
                  const Color.fromARGB(255, 8, 111, 255).withOpacity(0.2),
              child: const Icon(Icons.notifications,
                  color: Color.fromARGB(255, 8, 111, 255)),
            ),
            const SizedBox(width: 12),
            // Notification details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Order: $name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: $quantity',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Address: $address',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: ${_formatTimestamp(timestamp)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format the timestamp (if it's a Timestamp object)
  String _formatTimestamp(dynamic timestamp) {
    try {
      // Check if the timestamp is of type Timestamp and convert it to DateTime
      DateTime parsedTimestamp;
      if (timestamp is Timestamp) {
        parsedTimestamp = timestamp.toDate(); // Convert Timestamp to DateTime
      } else if (timestamp is String) {
        parsedTimestamp =
            DateTime.parse(timestamp); // If it's a string, parse it
      } else {
        return 'Invalid time';
      }

      final Duration difference = DateTime.now().difference(parsedTimestamp);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} mins ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Invalid time';
    }
  }
}
