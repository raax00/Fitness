import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialize setup
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error (Ignore if setup is pending): $e");
  }
  runApp(const PremiumKiranaApp());
}

class PremiumKiranaApp extends StatelessWidget {
  const PremiumKiranaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium Kirana',
      // iOS jaisa UI feel dene ke liye Android ripples ko disable kar rahe hain
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS System Background
        primaryColor: const Color(0xFF34C759), // iOS Green
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      home: const MainTabView(),
    );
  }
}

// --- BOTTOM TAB BAR (iOS Style) ---
class MainTabView extends StatefulWidget {
  const MainTabView({Key? key}) : super(key: key);
  @override
  _MainTabViewState createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text("Cart Screen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
    const Center(child: Text("Profile Screen", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        activeColor: const Color(0xFF34C759),
        backgroundColor: Colors.white.withOpacity(0.9),
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // iOS wali smooth bouncing physics
      physics: const BouncingScrollPhysics(),
      slivers: [
        // iOS Large Title App Bar
        const CupertinoSliverNavigationBar(
          largeTitle: Text("Grocery Store"),
          backgroundColor: Color(0xFFF2F2F7),
          border: null, // Removes bottom border for clean look
        ),
        
        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: CupertinoSearchTextField(
              placeholder: "Search fresh groceries...",
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(12),
              backgroundColor: Colors.black.withOpacity(0.05),
            ),
          ),
        ),

        // Beautiful Promo Banner
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34C759).withOpacity(0.4), 
                  blurRadius: 15, 
                  offset: const Offset(0, 8)
                ),
              ]
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Fresh Veggies", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text("Get 20% off on first order", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.leaf_arrow_circlepath, color: Colors.white, size: 60),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("Popular Items", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          ),
        ),

        // --- FIREBASE DATABASE CONNECTION ---
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: StreamBuilder<QuerySnapshot>(
            // Database me "products" naam ka collection banaye
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20.0), child: CupertinoActivityIndicator(radius: 15))));
              }
              
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Center(child: Text("No products found.\n(Add items to Firestore 'products' collection)", textAlign: TextAlign.center, style: TextStyle(color: CupertinoColors.systemGrey))),
                  ),
                );
              }

              final products = snapshot.data!.docs;

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var data = products[index].data() as Map<String, dynamic>;
                    return _buildProductCard(
                      name: data['name'] ?? 'Unknown Item',
                      price: data['price']?.toString() ?? '0',
                      unit: data['unit'] ?? 'kg',
                      imageUrl: data['imageUrl'] ?? '',
                    );
                  },
                  childCount: products.length,
                ),
              );
            },
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom spacing
      ],
    );
  }

  // --- PREMIUM PRODUCT CARD WIDGET ---
  Widget _buildProductCard({required String name, required String price, required String unit, required String imageUrl}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                color: const Color(0xFFF9F9F9),
                width: double.infinity,
                child: imageUrl.isNotEmpty 
                  ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey))
                  : const Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("₹$price / $unit", style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text("Add", style: TextStyle(color: Color(0xFF34C759), fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () {
                      // Add to cart logic will go here
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
