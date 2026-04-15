import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ANTI-CRASH SYSTEM: Grey screen ki jagah proper error dikhayega
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "App Error:\n${details.exceptionAsString()}",
            style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  runApp(const PremiumStoreApp());
}

// --- GLOBAL CART ---
List<Map<String, dynamic>> globalCart = [];
bool isDemoMode = false; // Agar Firebase fail ho jaye to demo mode on ho jayega

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
        primaryColor: const Color(0xFFE5B80B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121214),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const AppInitScreen(), // App ab yahan se safely start hoga
    );
  }
}

// ==========================================
// 0. APP INITIALIZER (Fixes Blank Screen)
// ==========================================
class AppInitScreen extends StatefulWidget {
  const AppInitScreen({Key? key}) : super(key: key);
  @override
  _AppInitScreenState createState() => _AppInitScreenState();
}

class _AppInitScreenState extends State<AppInitScreen> {
  Future<bool> initFirebase() async {
    try {
      await Firebase.initializeApp();
      return true; // Success
    } catch (e) {
      debugPrint("Firebase Setup Missing: $e");
      return false; // Failed (No google-services.json)
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: initFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CupertinoActivityIndicator(radius: 20, color: Color(0xFFE5B80B))));
        }

        if (snapshot.hasData && snapshot.data == true) {
          // Firebase Initialized Successfully!
          isDemoMode = false;
          return FirebaseAuth.instance.currentUser == null ? const SubscriptionScreen() : const HomeScreen();
        } else {
          // Firebase Failed (Missing config file) -> Safe Fallback
          isDemoMode = true;
          return const FirebaseErrorScreen();
        }
      },
    );
  }
}

class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 80),
              const SizedBox(height: 20),
              const Text("Firebase Not Connected", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              const Text(
                "App crash hone se bacha liya gaya hai! Aapne abhi google-services.json add nahi kiya hai.",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B80B)),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                },
                child: const Text("SEE APP UI (DEMO MODE)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 1. SUBSCRIPTION SCREEN
// ==========================================
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF09090B), Color(0xFF2A2104)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
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
                  const Text("Unlock Premium Access", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 10),
                  const Text("Get full access to all products and features.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5B80B).withOpacity(0.5), width: 2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text("Lifetime VIP", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text("One-time payment", style: TextStyle(color: Colors.grey))],
                        ),
                        Text("₹33,299", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFE5B80B))),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity, height: 55,
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
// 2. AUTH SCREEN
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
    if (isDemoMode) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
      return;
    }

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      } else {
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailCtrl.text.trim(), password: passCtrl.text.trim());
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'name': nameCtrl.text.trim(), 'email': emailCtrl.text.trim(), 'createdAt': DateTime.now(),
        });
      }
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
            const SizedBox(height: 40),
            if (!isLogin) ...[CupertinoTextField(controller: nameCtrl, placeholder: "Full Name", padding: const EdgeInsets.all(16)), const SizedBox(height: 16)],
            CupertinoTextField(controller: emailCtrl, placeholder: "Email", keyboardType: TextInputType.emailAddress, padding: const EdgeInsets.all(16)),
            const SizedBox(height: 16),
            CupertinoTextField(controller: passCtrl, placeholder: "Password", obscureText: true, padding: const EdgeInsets.all(16)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B80B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: isLoading ? null : submitAuth,
                child: isLoading ? const CupertinoActivityIndicator(color: Colors.black) : Text(isLogin ? "LOGIN" : "REGISTER", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
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
// 3. HOME SCREEN & DRAWER
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> dummyProducts = const [
    {"id": "p1", "name": "Sony WH-1000XM5 ANC Headphones", "price": 26990, "image": "https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=800&q=80", "desc": "Noise cancellation headphones."},
    {"id": "p2", "name": "Apple Watch Ultra 2", "price": 89900, "image": "https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?auto=format&fit=crop&w=800&q=80", "desc": "Rugged Apple Watch."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Premium Store", style: TextStyle(color: Color(0xFFE5B80B), fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(CupertinoIcons.cart), onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => const CartScreen())))],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121214),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF09090B)),
              accountName: Text("Premium User", style: TextStyle(color: Color(0xFFE5B80B), fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text("user@demo.com", style: TextStyle(color: Colors.grey)),
              currentAccountPicture: CircleAvatar(backgroundColor: Color(0xFFE5B80B), child: Icon(Icons.person, color: Colors.black, size: 40)),
            ),
            ListTile(leading: const Icon(CupertinoIcons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(CupertinoIcons.cart), title: const Text('My Cart'), onTap: () { Navigator.pop(context); Navigator.push(context, CupertinoPageRoute(builder: (_) => const CartScreen())); }),
            ListTile(leading: const Icon(CupertinoIcons.cube_box), title: const Text('My Orders'), onTap: () { Navigator.pop(context); Navigator.push(context, CupertinoPageRoute(builder: (_) => const OrdersScreen())); }),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                if (!isDemoMode) await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16), itemCount: dummyProducts.length,
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(aspectRatio: 16 / 9, child: Image.network(prod['image'], fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey.shade900))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(prod['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("₹${prod['price']}", style: const TextStyle(color: Color(0xFFE5B80B)))])),
                        IconButton(icon: const Icon(CupertinoIcons.cart_badge_plus), onPressed: () { globalCart.add(prod); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to cart!"))); })
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: Image.network(product['image'], fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product['name'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), Text("₹${product['price']}", style: const TextStyle(fontSize: 24, color: Color(0xFFE5B80B))), const SizedBox(height: 20), Text(product['desc'])]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B80B), padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () { globalCart.add(product); Navigator.pop(context); },
          child: const Text("ADD TO CART", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      body: globalCart.isEmpty ? const Center(child: Text("Cart is Empty")) : Column(
        children: [
          Expanded(child: ListView.builder(itemCount: globalCart.length, itemBuilder: (context, index) {
            return ListTile(title: Text(globalCart[index]['name']), subtitle: Text("₹${globalCart[index]['price']}"), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => globalCart.removeAt(index))));
          })),
          Container(
            padding: const EdgeInsets.all(24), color: const Color(0xFF1A1A1D),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total"), Text("₹$totalAmount", style: const TextStyle(color: Color(0xFFE5B80B), fontSize: 20, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE5B80B), minimumSize: const Size(double.infinity, 50)),
                onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => PaymentScreen(amount: totalAmount))),
                child: const Text("PROCEED TO PAY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ]),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 6. PAYMENT SCREEN (SAFE URI HANDLING)
// ==========================================
class PaymentScreen extends StatelessWidget {
  final double amount;
  const PaymentScreen({Key? key, required this.amount}) : super(key: key);

  Future<void> launchUPI(BuildContext context) async {
    Uri uri = Uri.parse("upi://pay?pa=8406962570@ybl&pn=PremiumStore&am=$amount&cu=INR");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("UPI App not found.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Total: ₹$amount", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              OutlinedButton(onPressed: () => launchUPI(context), child: const Text("1. OPEN UPI APP")),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  globalCart.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Success!")));
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                },
                child: const Text("2. I HAVE PAID (FINISH)", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. ORDERS SCREEN
// ==========================================
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("My Orders")), body: const Center(child: Text("Demo Mode: No Orders Found.")));
  }
}
