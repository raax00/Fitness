import 'dart:async';
import 'dart:developer'; // Error logging ke liye
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// App start hone se pehle check karenge ki Firebase chala ya nahi
bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase initialize karne ki koshish
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    log("SUCCESS: Firebase Initialize ho gaya hai.");
  } catch (e, stackTrace) {
    // Agar Firebase fail hua toh console me red text me error aayega
    log("CRITICAL ERROR: Firebase Initialization Fail ho gaya!", error: e, stackTrace: stackTrace);
    isFirebaseInitialized = false;
  }
  
  runApp(IslamicCommunityApp(isFirebaseInitialized: isFirebaseInitialized));
}

// ==========================================
// 1. MAIN APP THEME (Premium Dark iOS)
// ==========================================
class IslamicCommunityApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  const IslamicCommunityApp({super.key, required this.isFirebaseInitialized});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deen Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black iOS
        primaryColor: const Color(0xFFD4AF37), // Premium Gold Accent
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF1C1C1E),
        ),
        fontFamily: '.SF Pro Display',
      ),
      // Agar Firebase connect nahi hua toh direct Error Screen dikhao
      home: isFirebaseInitialized ? const AuthGate() : const FirebaseErrorScreen(),
    );
  }
}

// ==========================================
// 2. FIREBASE ERROR SCREEN (Grey screen se bachane ke liye)
// ==========================================
class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 80),
              SizedBox(height: 20),
              Text("Firebase Setup Missing!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              Text(
                "App Firebase se connect nahi ho paya.\n\nKripya check karein ki aapne 'google-services.json' file ko 'android/app' folder mein add kiya hai. Terminal logs check karein.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. AUTH GATE (Login check karta hai)
// ==========================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log("Auth Stream Error", error: snapshot.error);
          return Scaffold(body: Center(child: Text("Auth Error: ${snapshot.error}", style: const TextStyle(color: Colors.red))));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CupertinoActivityIndicator(radius: 20, color: Color(0xFFD4AF37))));
        }
        if (snapshot.hasData) {
          return const MainDashboard();
        }
        return const LoginScreen();
      },
    );
  }
}

// ==========================================
// 4. LOGIN & REGISTER SCREENS
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login() async {
    setState(() => _isLoading = true);
    try {
      log("Login attempt for email: ${_emailController.text.trim()}");
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      log("Login Successful!");
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuth Error during Login: ${e.code}", error: e.message);
      _showErrorDialog(e.message ?? "Login Failed. Check email/password.");
    } catch (e, stack) {
      log("Unknown Error during Login", error: e, stackTrace: stack);
      _showErrorDialog("An unexpected error occurred.");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Notice"),
        content: Text(message),
        actions: [CupertinoDialogAction(child: const Text("OK", style: TextStyle(color: Color(0xFFD4AF37))), onPressed: () => Navigator.pop(ctx))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Center(child: Icon(CupertinoIcons.book_circle_fill, color: Color(0xFFD4AF37), size: 80)),
              const SizedBox(height: 30),
              const Text("Bismillah,", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text("Sign in to read daily Ayahs and Farman.", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 50),
              CupertinoTextField(
                controller: _emailController,
                padding: const EdgeInsets.all(18),
                placeholder: "Email Address",
                placeholderStyle: const TextStyle(color: Colors.white30),
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16)),
                keyboardType: TextInputType.emailAddress,
                prefix: const Padding(padding: EdgeInsets.only(left: 15), child: Icon(CupertinoIcons.mail, color: Colors.grey)),
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: _passwordController,
                padding: const EdgeInsets.all(18),
                placeholder: "Password",
                obscureText: true,
                placeholderStyle: const TextStyle(color: Colors.white30),
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16)),
                prefix: const Padding(padding: EdgeInsets.only(left: 15), child: Icon(CupertinoIcons.lock, color: Colors.grey)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: CupertinoButton(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(16),
                  onPressed: _isLoading ? null : login,
                  child: _isLoading
                      ? const CupertinoActivityIndicator(color: Colors.black)
                      : const Text("Sign In", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CupertinoButton(
                  child: const Text("Create a New Account", style: TextStyle(color: Color(0xFFD4AF37))),
                  onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const RegisterScreen())),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> register() async {
    setState(() => _isLoading = true);
    try {
      log("Register attempt for email: ${_emailController.text.trim()}");
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      log("Registration Successful!");
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuth Error during Register: ${e.code}", error: e.message);
      _showErrorDialog(e.message ?? "Registration Failed");
    } catch (e, stack) {
      log("Unknown Error during Register", error: e, stackTrace: stack);
      _showErrorDialog("An unexpected error occurred.");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Notice"),
        content: Text(message),
        actions: [CupertinoDialogAction(child: const Text("OK", style: TextStyle(color: Color(0xFFD4AF37))), onPressed: () => Navigator.pop(ctx))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(backgroundColor: Colors.black, border: null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Join Community", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text("Connect with the Deen.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 40),
            CupertinoTextField(
              controller: _emailController,
              padding: const EdgeInsets.all(18),
              placeholder: "Email Address",
              style: const TextStyle(color: Colors.white),
              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16)),
            ),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: _passwordController,
              padding: const EdgeInsets.all(18),
              placeholder: "Password (Min 6 chars)",
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: CupertinoButton(
                color: const Color(0xFFD4AF37),
                borderRadius: BorderRadius.circular(16),
                onPressed: _isLoading ? null : register,
                child: _isLoading
                    ? const CupertinoActivityIndicator(color: Colors.black)
                    : const Text("Sign Up", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. MAIN DASHBOARD (BOTTOM NAV)
// ==========================================
class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: Colors.black,
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.95),
        activeColor: const Color(0xFFD4AF37),
        inactiveColor: CupertinoColors.systemGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.quote_bubble_fill), label: "Farman"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bookmark_solid), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_solid), label: "Profile"),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0: return const HomeTab();
          case 1: return const FeedTab();
          case 2: return const SavedTab();
          case 3: return const ProfileTab();
          default: return const HomeTab();
        }
      },
    );
  }
}

// ==========================================
// 6. HOME TAB
// ==========================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Assalamu Alaikum", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text("Daily Inspiration", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(CupertinoIcons.moon_stars_fill, color: Color(0xFFD4AF37), size: 32),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text("Ayah of the Day", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                SizedBox(height: 20),
                Text("فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ", textAlign: TextAlign.center, style: TextStyle(fontSize: 26, color: Colors.white, height: 1.5)),
                SizedBox(height: 15),
                Text("\"So remember Me; I will remember you. And be grateful to Me and do not deny Me.\"", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4, fontStyle: FontStyle.italic)),
                SizedBox(height: 15),
                Text("— Surah Al-Baqarah [2:152]", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text("Explore", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ExploreCard(icon: CupertinoIcons.book, title: "Quran", color: Colors.blueAccent),
              ExploreCard(icon: CupertinoIcons.mic_solid, title: "Hadith", color: Colors.green),
              ExploreCard(icon: CupertinoIcons.heart_fill, title: "Duas", color: Colors.redAccent),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ==========================================
// 7. FEED TAB (Community)
// ==========================================
class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> posts = [
      {"author": "Allah's Farman", "text": "And whoever puts their trust in Allah, then He alone is sufficient for them.", "reference": "Surah At-Talaq [65:3]"},
      {"author": "Prophetic Guidance", "text": "The best among you are those who have the best manners and character.", "reference": "Sahih al-Bukhari"},
      {"author": "Allah's Farman", "text": "Do not lose hope, nor be sad.", "reference": "Surah Ali 'Imran [3:139]"}
    ];

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return const Padding(padding: EdgeInsets.only(bottom: 20), child: Text("Community & Quotes", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)));
          final post = posts[index - 1];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Color(0xFFD4AF37), radius: 16, child: Icon(CupertinoIcons.quote_bubble_fill, color: Colors.black, size: 16)),
                    const SizedBox(width: 12),
                    Text(post["author"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 15),
                Text(post["text"]!, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(post["reference"]!, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
                    const Icon(CupertinoIcons.bookmark, color: Colors.grey, size: 20),
                  ],
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
// 8. SAVED TAB & PROFILE TAB
// ==========================================
class SavedTab extends StatelessWidget {
  const SavedTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.bookmark_solid, color: Color(0xFFD4AF37), size: 60),
            SizedBox(height: 20),
            Text("Your Saved Ayahs", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Items you bookmark will appear here.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFF2C2C2E), child: Icon(CupertinoIcons.person_solid, size: 50, color: Color(0xFFD4AF37))),
            const SizedBox(height: 15),
            Text(user?.email ?? "User Email", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildProfileOption(CupertinoIcons.bell_fill, "Notification Settings"),
                  const Divider(color: Colors.white10, height: 1),
                  _buildProfileOption(CupertinoIcons.info_circle_fill, "About App"),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: Colors.redAccent.withOpacity(0.15),
                onPressed: () async {
                  log("User logging out: ${user?.email}");
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(leading: Icon(icon, color: Colors.white70), title: Text(title, style: const TextStyle(color: Colors.white)), trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 20));
  }
}

class ExploreCard extends StatelessWidget {
  final IconData icon; final String title; final Color color;
  const ExploreCard({super.key, required this.icon, required this.title, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)), 
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
