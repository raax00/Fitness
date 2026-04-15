import 'package:flutter/material.dart';

void main() {
  runApp(const PremiumStoreApp());
}

// --- GLOBAL CART STATE (For simple demo purposes) ---
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
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFFD4AF37), // Gold Color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF141414),
          elevation: 0,
        ),
      ),
      home: const SubscriptionScreen(),
    );
  }
}

// ==========================================
// 1. SUBSCRIPTION SCREEN (First Screen)
// ==========================================
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedPlan = 0; // 0: Trial, 1: 1 Month, etc.

  final List<Map<String, dynamic>> plans = [
    {"title": "2-day trial", "subtitle": "Limited access", "price": "₹85 / 2 days", "tag": null},
    {"title": "12 months", "subtitle": "Full access", "price": "₹169 / month", "tag": "40% OFF"},
    {"title": "3 months", "subtitle": "Standard", "price": "₹225 / month", "tag": "20% OFF"},
    {"title": "1 month", "subtitle": "Basic", "price": "₹280 / month", "tag": null},
    {"title": "Lifetime", "subtitle": "Use forever", "price": "₹33299 / once", "tag": "Best Value"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PRO ACCESS", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text("SIGN IN", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Unlock Premium Features & E-Commerce Store",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 30),
              // Plan List
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Column(
                  children: List.generate(plans.length, (index) {
                    return RadioListTile(
                      activeColor: const Color(0xFFD4AF37),
                      value: index,
                      groupValue: selectedPlan,
                      onChanged: (val) => setState(() => selectedPlan = val as int),
                      title: Row(
                        children: [
                          Text(plans[index]['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(width: 8),
                          if (plans[index]['tag'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red.shade800, borderRadius: BorderRadius.circular(4)),
                              child: Text(plans[index]['tag'], style: const TextStyle(fontSize: 10, color: Colors.white)),
                            )
                        ],
                      ),
                      subtitle: Text(plans[index]['subtitle'], style: const TextStyle(color: Colors.grey)),
                      secondary: Text(plans[index]['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37), // Gold
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(amount: plans[selectedPlan]['price'])));
                },
                child: const Text("TRY NOW", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. PAYMENT SCREEN (UPI)
// ==========================================
class PaymentScreen extends StatelessWidget {
  final String amount;
  const PaymentScreen({Key? key, required this amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Payment")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 80, color: Color(0xFFD4AF37)),
              const SizedBox(height: 20),
              Text("Total Amount: $amount", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Pay using UPI ID:", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                child: const SelectableText("8406962570@ybl", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () {
                    // Payment Success Logic -> Go to Home
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment Successful!")));
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                  },
                  child: const Text("I Have Paid (Proceed to App)", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. HOME SCREEN (Products)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy Products (Admin panel me yahan Firebase se data aayega)
  final List<Map<String, dynamic>> products = [
    {"id": "1", "name": "Premium Wireless Headphones", "price": 2500, "image": Icons.headphones},
    {"id": "2", "name": "Smart Watch Series 8", "price": 4000, "image": Icons.watch},
    {"id": "3", "name": "Mechanical Keyboard", "price": 3200, "image": Icons.keyboard},
    {"id": "4", "name": "Gaming Mouse", "price": 1500, "image": Icons.mouse},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())).then((_) => setState((){})),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final prod = products[index];
          return Card(
            color: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(child: Icon(prod['image'], size: 60, color: Colors.grey)),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prod['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("₹${prod['price']}", style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF333333)),
                          onPressed: () {
                            globalCart.add(prod);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${prod['name']} added to cart!"), duration: const Duration(seconds: 1)));
                          },
                          child: const Text("Add", style: TextStyle(color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. CART & CHECKOUT SCREEN
// ==========================================
class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  double discount = 0;

  double get subtotal => globalCart.fold(0, (sum, item) => sum + item['price']);
  double get total => subtotal - discount;

  void applyPromo() {
    if (_promoController.text.toUpperCase() == "PRO100") {
      setState(() => discount = 100);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Promo Applied! ₹100 Off")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Promo Code")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: globalCart.isEmpty
          ? const Center(child: Text("Cart is Empty", style: TextStyle(fontSize: 18, color: Colors.grey)))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: globalCart.length,
                    itemBuilder: (context, index) {
                      final item = globalCart[index];
                      return ListTile(
                        leading: Icon(item['image'], color: Colors.grey),
                        title: Text(item['name']),
                        subtitle: Text("₹${item['price']}", style: const TextStyle(color: Color(0xFFD4AF37))),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => globalCart.removeAt(index)),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF141414),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              decoration: const InputDecoration(
                                hintText: "Promo Code (Try 'PRO100')",
                                filled: true, fillColor: Color(0xFF222222),
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(onPressed: applyPromo, child: const Text("Apply")),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Subtotal"), Text("₹$subtotal")]),
                      if (discount > 0) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Discount", style: TextStyle(color: Colors.green)), Text("-₹$discount", style: const TextStyle(color: Colors.green))]),
                      const Divider(color: Colors.grey),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text("₹$total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)))]),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), padding: const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () {
                            globalCart.clear();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed Successfully!")));
                            Navigator.pop(context);
                          },
                          child: const Text("CHECKOUT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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
// 5. AUTH SCREEN (Login / Register)
// ==========================================
class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login / Register")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(decoration: InputDecoration(labelText: "Email", filled: true, fillColor: Color(0xFF1A1A1A))),
            const SizedBox(height: 16),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: "Password", filled: true, fillColor: Color(0xFF1A1A1A))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("LOGIN"),
              ),
            ),
            TextButton(onPressed: () {}, child: const Text("Don't have an account? Register", style: TextStyle(color: Color(0xFFD4AF37))))
          ],
        ),
      ),
    );
  }
}
