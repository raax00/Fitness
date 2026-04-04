import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool isFirebaseInitialized = false;
String firebaseErrorMessage = "";

// Global State for Saved Bookmarks (Bina kisi extra package ke)
ValueNotifier<List<Map<String, String>>> savedItemsNotifier = ValueNotifier([]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // 🔥 Firebase Keys Auto-Injected 🔥
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBC9XDg_EtjjF7rQ55toFgFuEgHgnRB_Kc",
        appId: "1:57317479451:android:ac4a807e791711c8aed4be",
        messagingSenderId: "57317479451",
        projectId: "raax-3f71a",
      ),
    );
    isFirebaseInitialized = true;
    log("SUCCESS: Firebase Initialize ho gaya hai.");
  } catch (e, stackTrace) {
    log("CRITICAL ERROR", error: e, stackTrace: stackTrace);
    firebaseErrorMessage = e.toString();
    isFirebaseInitialized = false;
  }

  runApp(IslamicCommunityApp(
      isFirebaseInitialized: isFirebaseInitialized,
      errorMessage: firebaseErrorMessage));
}

// ==========================================
// 1. MAIN APP THEME
// ==========================================
class IslamicCommunityApp extends StatelessWidget {
  final bool isFirebaseInitialized;
  final String errorMessage;
  const IslamicCommunityApp(
      {super.key,
      required this.isFirebaseInitialized,
      required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deen Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black iOS
        primaryColor: const Color(0xFFD4AF37), // Premium Gold
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          surface: Color(0xFF1C1C1E),
        ),
        fontFamily: '.SF Pro Display',
      ),
      // App Start Hote Hi Onboarding Screen Aayegi
      home: isFirebaseInitialized
          ? const OnboardingScreen()
          : FirebaseErrorScreen(errorText: errorMessage),
    );
  }
}

// ==========================================
// 2. ONBOARDING & LANGUAGE SCREEN
// ==========================================
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(CupertinoIcons.moon_stars_fill,
                  color: Color(0xFFD4AF37), size: 100),
              const SizedBox(height: 40),
              const Text("Welcome to\nDeen Connect",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2)),
              const SizedBox(height: 20),
              const Text(
                "Read Daily Ayahs, Farman, and connect with your faith beautifully.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: CupertinoButton(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(16),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const LanguageScreen()));
                  },
                  child: const Text("Get Started",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
        backgroundColor: Colors.black,
        border: null,
        middle: Text("Choose Language", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Preferred Language",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 10),
              const Text("You can read Farman in your selected language.",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 40),
              _buildLangOption(context, "English", "Read in standard English"),
              const SizedBox(height: 15),
              _buildLangOption(context, "Roman Urdu/Hindi", "Jaise hum type karte hain"),
              const SizedBox(height: 15),
              _buildLangOption(context, "हिंदी", "देवनागरी लिपि में पढ़ें"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangOption(BuildContext context, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(context,
            CupertinoPageRoute(builder: (context) => const AuthGate()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const Icon(CupertinoIcons.chevron_right, color: Color(0xFFD4AF37)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. AUTH GATE & LOGIN
// ==========================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(
                  child: CupertinoActivityIndicator(
                      radius: 20, color: Color(0xFFD4AF37))));
        }
        if (snapshot.hasData) {
          return const MainDashboard();
        }
        return const LoginScreen();
      },
    );
  }
}

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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "Login Failed.");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Notice"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
              child: const Text("OK", style: TextStyle(color: Color(0xFFD4AF37))),
              onPressed: () => Navigator.pop(ctx))
        ],
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
              const SizedBox(height: 30),
              const Center(
                  child: Icon(CupertinoIcons.book_circle_fill,
                      color: Color(0xFFD4AF37), size: 80)),
              const SizedBox(height: 30),
              const Text("Bismillah,",
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Text("Sign in to continue.",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 40),
              CupertinoTextField(
                controller: _emailController,
                padding: const EdgeInsets.all(18),
                placeholder: "Email Address",
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16)),
                prefix: const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(CupertinoIcons.mail, color: Colors.grey)),
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: _passwordController,
                padding: const EdgeInsets.all(18),
                placeholder: "Password",
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16)),
                prefix: const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Icon(CupertinoIcons.lock, color: Colors.grey)),
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
                      : const Text("Sign In",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CupertinoButton(
                  child: const Text("Create a New Account",
                      style: TextStyle(color: Color(0xFFD4AF37))),
                  onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const RegisterScreen())),
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
                title: const Text("Error"),
                content: Text(e.message ?? "Registration Failed"),
                actions: [
                  CupertinoDialogAction(
                      child: const Text("OK"),
                      onPressed: () => Navigator.pop(ctx))
                ],
              ));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CupertinoNavigationBar(
          backgroundColor: Colors.black, border: null),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Join Community",
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 30),
            CupertinoTextField(
                controller: _emailController,
                padding: const EdgeInsets.all(18),
                placeholder: "Email Address",
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 20),
            CupertinoTextField(
                controller: _passwordController,
                padding: const EdgeInsets.all(18),
                placeholder: "Password",
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 40),
            SizedBox(
                width: double.infinity,
                height: 55,
                child: CupertinoButton(
                    color: const Color(0xFFD4AF37),
                    onPressed: _isLoading ? null : register,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: Colors.black)
                        : const Text("Sign Up",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. MAIN DASHBOARD
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
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.quote_bubble_fill), label: "Farman"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.bookmark_solid), label: "Saved"),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_solid), label: "Profile"),
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
// 5. HOME TAB (With Responsive YouTube Style Videos)
// ==========================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
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
          ),
          const SizedBox(height: 30),

          // Daily Ayah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
              ),
              child: Column(
                children: const [
                  Text("Ayah of the Day", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                  SizedBox(height: 20),
                  Text("فَاذْكُرُونِي أَذْكُرْكُمْ", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, color: Colors.white, height: 1.5, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text("\"So remember Me; I will remember you.\"", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic)),
                  SizedBox(height: 15),
                  Text("— Surah Al-Baqarah [2:152]", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 35),

          // YouTube Style Videos Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text("Islamic Videos", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 15),
          
          // Responsive Horizontal List
          SizedBox(
            height: 240,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildVideoCard(context, "Life of Prophet Muhammad (PBUH)", "Mufti Menk", "https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?q=80&w=600"),
                _buildVideoCard(context, "Beautiful Quran Recitation", "Mishary Alafasy", "https://images.unsplash.com/photo-1609599006353-e629aaab31ce?q=80&w=600"),
                _buildVideoCard(context, "How to pray Tahajjud", "Islamic Guidance", "https://images.unsplash.com/photo-1564683214965-3619addd900d?q=80&w=600"),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, String title, String channel, String imgUrl) {
    // Making it responsive based on screen width
    double cardWidth = MediaQuery.of(context).size.width * 0.8; 
    
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Image with Play Button
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imgUrl, height: 170, width: cardWidth, fit: BoxFit.cover),
              ),
              Container(
                height: 170,
                width: cardWidth,
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(16)),
              ),
              const Icon(CupertinoIcons.play_circle_fill, color: Colors.white, size: 60),
              Positioned(
                bottom: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
                  child: const Text("12:45", style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          // Title and Channel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 18, backgroundColor: Color(0xFFD4AF37), child: Icon(CupertinoIcons.person_fill, color: Colors.black, size: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("$channel • 14K views", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ==========================================
// 6. FEED TAB (Farman in Arabic & Roman) + SAVE LOGIC
// ==========================================
class FeedTab extends StatefulWidget {
  const FeedTab({super.key});
  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  final List<Map<String, String>> posts = [
    {
      "id": "1",
      "author": "Allah's Farman",
      "arabic": "لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا",
      "roman": "La tahzan innallaha ma'ana",
      "translation": "Do not be sad, indeed Allah is with us.",
      "reference": "Surah At-Tawbah [9:40]"
    },
    {
      "id": "2",
      "author": "Prophetic Guidance",
      "arabic": "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
      "roman": "Khairukum man ta'allamal Qur'ana wa 'allamahu",
      "translation": "The best among you are those who learn the Quran and teach it.",
      "reference": "Sahih al-Bukhari"
    },
    {
      "id": "3",
      "author": "Allah's Farman",
      "arabic": "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
      "roman": "Fa inna ma'al 'usri yusra",
      "translation": "For indeed, with hardship [will be] ease.",
      "reference": "Surah Ash-Sharh [94:5]"
    }
  ];

  void toggleBookmark(Map<String, String> post) {
    final currentSaved = List<Map<String, String>>.from(savedItemsNotifier.value);
    bool isSaved = currentSaved.any((item) => item['id'] == post['id']);
    
    if (isSaved) {
      currentSaved.removeWhere((item) => item['id'] == post['id']);
    } else {
      currentSaved.add(post);
    }
    savedItemsNotifier.value = currentSaved; // Trigger UI update globally
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return const Padding(padding: EdgeInsets.only(bottom: 20), child: Text("Farman & Hadith", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)));
          
          final post = posts[index - 1];
          
          return ValueListenableBuilder<List<Map<String, String>>>(
            valueListenable: savedItemsNotifier,
            builder: (context, savedItems, child) {
              bool isSaved = savedItems.any((item) => item['id'] == post['id']);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(backgroundColor: Color(0xFFD4AF37), radius: 14, child: Icon(CupertinoIcons.quote_bubble_fill, color: Colors.black, size: 14)),
                        const SizedBox(width: 10),
                        Text(post["author"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Arabic Text
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(post["arabic"]!, style: const TextStyle(color: Colors.white, fontSize: 28, height: 1.5, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                    ),
                    const SizedBox(height: 15),
                    
                    // Roman & Translation
                    Text(post["roman"]!, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 5),
                    Text(post["translation"]!, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.4)),
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white10, height: 1)),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(post["reference"]!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        GestureDetector(
                          onTap: () => toggleBookmark(post),
                          child: Icon(isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark, color: isSaved ? const Color(0xFFD4AF37) : Colors.grey, size: 24),
                        )
                      ],
                    )
                  ],
                ),
              );
            }
          );
        },
      ),
    );
  }
}

// ==========================================
// 7. SAVED TAB (100% Working)
// ==========================================
class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<List<Map<String, String>>>(
        valueListenable: savedItemsNotifier,
        builder: (context, savedItems, child) {
          if (savedItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(CupertinoIcons.bookmark, color: Colors.grey, size: 80),
                  SizedBox(height: 20),
                  Text("No Saved Items", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Bookmark Farman to read them later.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: savedItems.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return const Padding(padding: EdgeInsets.only(bottom: 20), child: Text("Saved Farman", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)));
              final post = savedItems[index - 1];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post["arabic"]!, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textDirection: TextDirection.rtl),
                    const SizedBox(height: 10),
                    Text(post["roman"]!, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(post["reference"]!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        GestureDetector(
                          onTap: () {
                             final currentList = List<Map<String, String>>.from(savedItemsNotifier.value);
                             currentList.removeWhere((item) => item['id'] == post['id']);
                             savedItemsNotifier.value = currentList;
                          },
                          child: const Icon(CupertinoIcons.trash, color: Colors.redAccent, size: 20),
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 8. PROFILE TAB (Manage & iOS Logout)
// ==========================================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _showLogoutSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Confirm Logout'),
        message: const Text('Are you sure you want to log out of Deen Connect?'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context); // close sheet
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Log Out'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Profile", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Color(0xFF2C2C2E), child: Icon(CupertinoIcons.person_solid, size: 50, color: Color(0xFFD4AF37))),
                  const SizedBox(height: 15),
                  Text(user?.email ?? "User Email", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            const Text("ACCOUNT", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildProfileOption(CupertinoIcons.person_crop_circle, "Manage Account"),
                  const Divider(color: Colors.white10, height: 1, indent: 50),
                  _buildProfileOption(CupertinoIcons.globe, "Change Language"),
                  const Divider(color: Colors.white10, height: 1, indent: 50),
                  _buildProfileOption(CupertinoIcons.bell_fill, "Notifications"),
                ],
              ),
            ),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: CupertinoButton(
                color: const Color(0xFF1C1C1E),
                onPressed: () => _showLogoutSheet(context),
                child: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white), 
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)), 
      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 20)
    );
  }
}

// ==========================================
// ERROR SCREEN 
// ==========================================
class FirebaseErrorScreen extends StatelessWidget {
  final String errorText;
  const FirebaseErrorScreen({super.key, required this.errorText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 80),
              const SizedBox(height: 20),
              const Text("Error!", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Text(errorText, textAlign: TextAlign.center, style: const TextStyle(color: Colors.yellow, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
