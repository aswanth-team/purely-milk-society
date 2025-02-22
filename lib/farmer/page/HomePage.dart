import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:milkproject/farmer/page/BuyNow.dart';
import 'package:milkproject/farmer/page/farmerNotification.dart';
import 'package:milkproject/farmer/page/marketplace.dart';
import 'package:milkproject/farmer/page/orders.dart';
import 'package:milkproject/user/page/addtocart.dart';
import 'profile.dart';

class FarmerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purely Dairy Society',
      color: Colors.white,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      home: FarmerHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FarmerHomePage extends StatefulWidget {
  @override
  _FarmerHomePageState createState() => _FarmerHomePageState();
}

class _FarmerHomePageState extends State<FarmerHomePage> {
  final List<String> carouselImages = [
    "https://via.placeholder.com/600x300.png?text=Welcome+to+Milk+Zone",
    "https://via.placeholder.com/600x300.png?text=Quality+Products",
    "https://via.placeholder.com/600x300.png?text=Farm+Fresh+Feed",
  ];

  int? totalQuantity;
  double? totalPayment;

  // Search query for filtering products
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchFarmerData();
  }

  Future<void> _fetchFarmerData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('farmerSales')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          totalQuantity = doc.data()?['totalQuantity'] ?? 0;
          totalPayment = doc.data()?['totalPayment']?.toDouble() ?? 0.0;
        });
      } else {
        setState(() {
          totalQuantity = 0;
          totalPayment = 0.0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Purely Dairy Society",
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              size: 28,
              color: Colors.white,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, size: 28, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FarmerProfilePage()),
              );
            },
          ),
        ],
        elevation: 5,
      ),
      drawer: FarmerMenuDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Products...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              _buildCarouselSlider(),

              const SizedBox(height: 16),

              // Welcome Section
              Text(
                "👋 Welcome Back, Farmer!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 16),

              // Info Cards (Dynamic Data)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InfoCard(
                      title: "Today's Supply",
                      value: totalQuantity != null
                          ? "$totalQuantity Liters"
                          : "Loading...",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InfoCard(
                      title: "Payment Received",
                      value: totalPayment != null
                          ? "₹${totalPayment?.toStringAsFixed(2)}"
                          : "Loading...",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "🐄 Cattle Feed Products",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 12),
              CattleFeedProductList(searchQuery),
            ],
          ),
        ),
      ),
    );
  }
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

// Cattle Feed Product List Widget
class CattleFeedProductList extends StatelessWidget {
  final String searchQuery;

  const CattleFeedProductList(this.searchQuery, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cattleFeedProduct')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final products = snapshot.data!.docs;

        // Filter products based on search query
        final filteredProducts = products.where((product) {
          final productMap = product.data() as Map<String, dynamic>;
          return productMap['name']
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
        }).toList();

        return Column(
          children: filteredProducts.map((product) {
            final productMap = product.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      productMap['image_url'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productMap['name'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          productMap['description'],
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Price: ₹${productMap['price']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;

                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Please log in to add items to the cart.")),
                                  );
                                  return;
                                }

                                final cartProductData = {
                                  'name': productMap['name'],
                                  'description': productMap['description'],
                                  'price': productMap['price'],
                                  'image': productMap['image_url'],
                                  'quantity': 1,
                                  'user_id': user.uid,
                                };

                                try {
                                  await FirebaseFirestore.instance
                                      .collection('cart')
                                      .add(cartProductData);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "${cartProductData['name']} added to cart!"),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Failed to add to cart. Please try again.")),
                                  );
                                }
                              },
                              icon: Icon(Icons.add_shopping_cart),
                              label: Text("Add to Cart"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[700],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FarmerBuyNowPage(
                                      productName: productMap['name'],
                                      productPrice: productMap['price'],
                                      productImageUrl: productMap['image'] ??
                                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQinI_44p5jN05YioLyPBhn_1j5tsl7q85rfA&s',
                                    ),
                                  ),
                                );
                              },
                              child: Text("Buy Now"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// Drawer Widget (Menu)
class FarmerMenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[800],
            ),
            child: Text(
              'Purely Dairy Society',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('My Orders'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyOrdersPage()),
              );
            },
          ),
          ListTile(
            title: Text('Cart'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddToCartPage(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FarmerProfilePage()),
              );
            },
          ),
          ListTile(
            title: Text('Market Place'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MarketplacePage()),
              );
            },
          ),
          ListTile(
            title: Text('Notifications'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmerNotificationPage(),
                  ));
            },
          ),
        ],
      ),
    );
  }
}
