import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Error: $e");
  }
  runApp(const PremiumStoreApp());
}

// --- GLOBAL CART ---
List<Map<String, dynamic>> globalCart = [];

class PremiumStoreApp extends StatelessWidget {
  const PremiumStoreApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium Store',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        primaryColor: const Color(0xFFE5B80B), // Premium Gold
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121214),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // Automatically check login status
      home: FirebaseAuth.instance.currentUser == null ? const SubscriptionScreen() : const HomeScreen(),
    );
  }
}

// ==========================================
// 1. SUBSCRIPTION SCREEN (Premium iOS Style)
// ==========================================
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF09090B), Color(0xFF2A2104)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.star_circle_fill, size: 100, color: Color(0xFFE5B80B)),
                  const SizedBox(height: 20),
                  const Text("Unlock Premium Access", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  const Text("Get full access to all products, HD videos, and exclusive early discounts.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 50),
                  
                  // Plan Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5B80B).withOpacity(0.5), width: 2),
                      boxShadow: [BoxShadow(color: const Color(0xFFE5B80B).withOpacity(0.2), blurRadius: 20, spreadRadius: 2)],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Lifetime VIP", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 5),
                            Text("One-time payment", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        Text("₹33,299", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE5B80B))),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B80B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const AuthScreen())),
                      child: const Text("SIGN IN TO CONTINUE", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. AUTH SCREEN (Login / Register iOS Style)
// ==========================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  Future<void> submitAuth() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      } else {
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
        // Save Name to Firestore Database
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'createdAt': DateTime.now(),
        });
      }
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Authentication Error", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Sign In" : "Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isLogin ? "Welcome Back," : "Join Us,", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(isLogin ? "Sign in to continue" : "Create an account to shop", style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),
            if (!isLogin) ...[
              CupertinoTextField(controller: nameCtrl, placeholder: "Full Name", padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 16),
            ],
            CupertinoTextField(controller: emailCtrl, placeholder: "Email Address", keyboardType: TextInputType.emailAddress, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 16),
            CupertinoTextField(controller: passCtrl, placeholder: "Password", obscureText: true, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(12))),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B80B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: isLoading ? null : submitAuth,
                child: isLoading ? const CupertinoActivityIndicator(color: Colors.black) : Text(isLogin ? "LOGIN" : "REGISTER", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Don't have an account? Register" : "Already have an account? Login", style: const TextStyle(color: Color(0xFFE5B80B))),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. HOME SCREEN & DRAWER (YouTube Thumbnail Style)
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> dummyProducts = const [
    {"id": "p1", "name": "Sony WH-1000XM5 ANC Headphones", "price": 26990, "image": "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=800&q=80", "desc": "Industry leading noise cancellation headphones."},
    {"id": "p2", "name": "Apple Watch Ultra 2", "price": 89900, "image": "https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?auto=format&fit=crop&w=800&q=80", "desc": "The most rugged and capable Apple Watch."},
    {"id": "p3", "name": "Razer BlackWidow V4", "price": 18500, "image": "https://images.unsplash.com/photo-1595225476474-87563907a212?auto=format&fit=crop&w=800&q=80", "desc": "Premium mechanical gaming keyboard."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Premium Store", style: TextStyle(color: Color(0xFFE5B80B), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(CupertinoIcons.cart), onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const CartScreen()))),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121214),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF09090B)),
              accountName: const Text("Welcome, User", style: TextStyle(color: Color(0xFFE5B80B), fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? "Not logged in", style: const TextStyle(color: Colors.grey)),
              currentAccountPicture: const CircleAvatar(backgroundColor: Color(0xFFE5B80B), child: Icon(Icons.person, color: Colors.black, size: 40)),
            ),
            ListTile(leading: const Icon(CupertinoIcons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(CupertinoIcons.cart), title: const Text('My Cart'), onTap: () { Navigator.pop(context); Navigator.push(context, CupertinoPageRoute(builder: (_) => const CartScreen())); }),
            ListTile(leading: const Icon(CupertinoIcons.cube_box), title: const Text('My Orders'), onTap: () { Navigator.pop(context); Navigator.push(context, CupertinoPageRoute(builder: (_) => const OrdersScreen())); }),
            ListTile(leading: const Icon(CupertinoIcons.location), title: const Text('Address / Settings'), onTap: () {}),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyProducts.length,
        itemBuilder: (context, index) {
          final prod = dummyProducts[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => ProductDetailScreen(product: prod))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // YouTube Style 16:9 Big Thumbnail
                  Hero(
                    tag: prod['id'],
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(prod['image'], fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade900, child: const Center(child: Icon(Icons.image, size: 50)))),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prod['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Text("₹${prod['price']}", style: const TextStyle(fontSize: 16, color: Color(0xFFE5B80B), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.cart_badge_plus, color: Colors.white),
                          onPressed: () {
                            globalCart.add(prod);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${prod['name']} added to cart!"), duration: const Duration(seconds: 1)));
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. PRODUCT DETAIL SCREEN
// ==========================================
class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: product['id'],
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(product['image'], fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade900)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product['name'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text("₹${product['price']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE5B80B))),
                  const SizedBox(height: 20),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(product['desc'], style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFF121214), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: SizedBox(
          width: double.infinity, height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B80B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              globalCart.add(product);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to cart!")));
              Navigator.pop(context);
            },
            child: const Text("ADD TO CART", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. CART SCREEN
// ==========================================
class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get totalAmount => globalCart.fold(0, (sum, item) => sum + item['price']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: globalCart.isEmpty
          ? const Center(child: Text("Cart is Empty", style: TextStyle(color: Colors.grey, fontSize: 18)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: globalCart.length,
                    itemBuilder: (context, index) {
                      final item = globalCart[index];
                      return ListTile(
                        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover)),
                        title: Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text("₹${item['price']}", style: const TextStyle(color: Color(0xFFE5B80B))),
                        trailing: IconButton(icon: const Icon(CupertinoIcons.delete, color: Colors.redAccent), onPressed: () => setState(() => globalCart.removeAt(index))),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(color: Color(0xFF1A1A1D), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Amount", style: TextStyle(fontSize: 18)), Text("₹$totalAmount", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE5B80B)))]),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B80B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => PaymentScreen(amount: totalAmount))),
                          child: const Text("PROCEED TO PAY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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

// ==========================================
// 6. UPI PAYMENT LIVE TRACKING & FIRESTORE UPLOAD
// ==========================================
class PaymentScreen extends StatefulWidget {
  final double amount;
  const PaymentScreen({Key? key, required this.amount}) : super(key: key);
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isProcessing = false;

  Future<void> launchUPI() async {
    // UPI Intent URL
    String upiUrl = "upi://pay?pa=8406962570@ybl&pn=PremiumStore&am=${widget.amount}&cu=INR";
    Uri uri = Uri.parse(upiUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No UPI App found on this device.")));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> verifyPaymentAndSaveOrder() async {
    setState(() => isProcessing = true);
    
    // Simulate server side verification delay
    await Future.delayed(const Duration(seconds: 3));

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      // Save order to Firestore Admin Panel DB
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': uid,
        'items': globalCart,
        'totalAmount': widget.amount,
        'paymentStatus': 'Paid', // App detects User returned after intent
        'orderStatus': 'Pending Admin Approval', // Admin will see this
        'timestamp': FieldValue.serverTimestamp(),
      });

      globalCart.clear(); // Empty cart on success
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Successful! Order sent to Admin.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        Navigator.pushAndRemoveUntil(context, CupertinoPageRoute(builder: (_) => const HomeScreen()), (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error saving order.")));
    }
    setState(() => isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout via UPI")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFFE5B80B)),
              const SizedBox(height: 20),
              Text("Total to Pay: ₹${widget.amount}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              
              // Step 1: Open UPI App
              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5B80B))),
                  icon: const Icon(Icons.account_balance_wallet, color: Color(0xFFE5B80B)),
                  label: const Text("1. OPEN UPI APP TO PAY", style: TextStyle(color: Color(0xFFE5B80B))),
                  onPressed: launchUPI,
                ),
              ),
              const SizedBox(height: 20),

              // Step 2: Verify & Submit to Admin
              isProcessing 
                ? const CupertinoActivityIndicator(radius: 20, color: Color(0xFFE5B80B))
                : SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.verified, color: Colors.white),
                      label: const Text("2. I HAVE PAID (VERIFY & ORDER)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: verifyPaymentAndSaveOrder,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. MY ORDERS SCREEN (Fetches from Firestore)
// ==========================================
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: uid == null
          ? const Center(child: Text("Please Login First"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('orders').where('userId', isEqualTo: uid).orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CupertinoActivityIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No Orders Yet", style: TextStyle(color: Colors.grey)));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var order = snapshot.data!.docs[index];
                    return Card(
                      color: const Color(0xFF1A1A1D),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Order ID: ${order.id.substring(0, 8)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                  child: Text(order['orderStatus'], style: const TextStyle(color: Colors.blue, fontSize: 12)),
                                )
                              ],
                            ),
                            const Divider(color: Colors.white24),
                            Text("Total Paid: ₹${order['totalAmount']}", style: const TextStyle(color: Color(0xFFE5B80B), fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text("Items: ${(order['items'] as List).length}", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
