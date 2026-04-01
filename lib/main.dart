import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase (Make sure you have run flutterfire configure)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }
  runApp(const FitnessApp());
}

// ==========================================
// 1. MAIN APP THEME
// ==========================================
class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desi Fitness Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure Black iOS
        primaryColor: const Color(0xFFFF9F0A), // Orange
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9F0A),
          surface: Color(0xFF1C1C1E),
        ),
        fontFamily: '.SF Pro Display',
      ),
      home: const AuthGate(), // Check login status first
    );
  }
}

// ==========================================
// 2. AUTH GATE (Checks if user is logged in)
// ==========================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CupertinoActivityIndicator(radius: 20)));
        }
        // If user is logged in, show Dashboard, else show Login
        if (snapshot.hasData) {
          return const MainDashboard();
        }
        return const LoginScreen();
      },
    );
  }
}

// ==========================================
// 3. LOGIN & REGISTER SCREENS (iOS UI)
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "Login Failed");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [CupertinoDialogAction(child: const Text("OK"), onPressed: () => Navigator.pop(ctx))],
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
              const Icon(CupertinoIcons.flame_fill, color: Color(0xFFFF9F0A), size: 60),
              const SizedBox(height: 20),
              const Text("Welcome Back,", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text("Sign in to continue your fitness journey.", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 50),
              
              // Custom iOS TextFields
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
                  color: const Color(0xFFFF9F0A),
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
                  child: const Text("Create an Account", style: TextStyle(color: Color(0xFFFF9F0A))),
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
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if(mounted) Navigator.pop(context); // Go back to login after register
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "Registration Failed");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [CupertinoDialogAction(child: const Text("OK"), onPressed: () => Navigator.pop(ctx))],
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
            const Text("Create Account", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text("Start transforming your body today.", style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                color: const Color(0xFFFF9F0A),
                borderRadius: BorderRadius.circular(16),
                onPressed: _isLoading ? null : register,
                child: _isLoading ? const CupertinoActivityIndicator() : const Text("Sign Up", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. MAIN DASHBOARD (BOTTOM NAV)
// ==========================================
class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: Colors.black,
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.9),
        activeColor: const Color(0xFFFF9F0A),
        inactiveColor: CupertinoColors.systemGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_grid_2x2), label: "Plans"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.leaf_arrow_circlepath), label: "Diet"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person_solid), label: "Profile"),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0: return const HomeTab();
          case 1: return const PlansTab();
          case 2: return const DietTab();
          case 3: return const ProfileTab();
          default: return const HomeTab();
        }
      },
    );
  }
}

// ==========================================
// 5. HOME TAB (Advanced Features Added)
// ==========================================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int waterGlasses = 2; // Advanced Feature: Water Tracker

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
                  Text("Ready for action?", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  Text("Let's Go! 🔥", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              const CircleAvatar(radius: 25, backgroundImage: NetworkImage("https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=200&auto=format&fit=crop")),
            ],
          ),
          const SizedBox(height: 30),
          
          // Daily Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              StatCard(icon: CupertinoIcons.flame_fill, title: "Calories", value: "450", color: Colors.orange),
              StatCard(icon: CupertinoIcons.time, title: "Minutes", value: "45", color: Colors.blueAccent),
              StatCard(icon: CupertinoIcons.heart_fill, title: "BPM", value: "112", color: Colors.redAccent),
            ],
          ),
          const SizedBox(height: 30),

          // WATER TRACKER (New Feature)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Daily Hydration", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("$waterGlasses / 8 Glasses", style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 14)),
                  ],
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(10),
                  color: Colors.lightBlueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    if (waterGlasses < 8) setState(() => waterGlasses++);
                  },
                  child: const Icon(CupertinoIcons.add, color: Colors.lightBlueAccent),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),

          const Text("Today's Target", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),
          const WorkoutChallengeCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ==========================================
// 6. ACTIVE WORKOUT SCREEN (Timer + Checker)
// ==========================================
// (Previous awesome code logic retained here)
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});
  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}
class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Timer? _timer;
  int _seconds = 0;
  final List<Map<String, dynamic>> exercises = [
    {"name": "Push-ups", "reps": "3 x 15 Reps", "image": "https://images.unsplash.com/photo-1598971639058-fab3c3109a00?q=80&w=200", "done": false},
    {"name": "Squats", "reps": "3 x 20 Reps", "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=200", "done": false},
    {"name": "Plank", "reps": "60 Seconds", "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=200", "done": false},
  ];

  @override
  void initState() { super.initState(); _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _seconds++)); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void finishWorkout() {
    _timer?.cancel();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Workout Completed! 🎉"),
        content: Text("Great job. You worked out for ${_seconds ~/ 60} mins."),
        actions: [CupertinoDialogAction(child: const Text("Awesome"), onPressed: () { Navigator.pop(ctx); Navigator.pop(context); })],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CupertinoNavigationBar(backgroundColor: Colors.black, middle: const Text("Live Workout", style: TextStyle(color: Colors.white))),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 60, color: Color(0xFFFF9F0A), fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: exercises.length,
              itemBuilder: (ctx, i) {
                var ex = exercises[i];
                return GestureDetector(
                  onTap: () => setState(() => ex['done'] = !ex['done']),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: ex['done'] ? Colors.green.withOpacity(0.1) : const Color(0xFF1C1C1E),
                      border: Border.all(color: ex['done'] ? Colors.green : Colors.transparent),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(ex['image'], width: 60, height: 60, fit: BoxFit.cover)),
                        const SizedBox(width: 15),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(ex['name'], style: TextStyle(fontSize: 18, color: Colors.white, decoration: ex['done'] ? TextDecoration.lineThrough : null)),
                          Text(ex['reps'], style: const TextStyle(color: Colors.grey)),
                        ])),
                        Icon(ex['done'] ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle, color: ex['done'] ? Colors.green : Colors.grey, size: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: CupertinoButton(color: const Color(0xFFFF9F0A), onPressed: finishWorkout, child: const Center(child: Text("Finish Workout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 7. DIET TAB (New Premium Content)
// ==========================================
class DietTab extends StatelessWidget {
  const DietTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Nutrition & Diet", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          _buildDietCard("High Protein Bulk", "₹50/Day • Gain Muscle", Colors.orange),
          const SizedBox(height: 15),
          _buildDietCard("Keto Fat Loss", "₹100/Day • Burn Fat Fast", Colors.redAccent),
          const SizedBox(height: 15),
          _buildDietCard("Desi Budget Diet", "₹25/Day • Pure Veg", Colors.green),
        ],
      ),
    );
  }

  Widget _buildDietCard(String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle), child: Icon(CupertinoIcons.leaf_arrow_circlepath, color: color)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(color: Colors.grey))])),
          const Icon(CupertinoIcons.chevron_right, color: Colors.grey)
        ],
      ),
    );
  }
}

// ==========================================
// 8. PROFILE TAB (Logout & Firebase Info)
// ==========================================
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
            const CircleAvatar(radius: 50, backgroundImage: NetworkImage("https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=200")),
            const SizedBox(height: 15),
            Text(user?.email ?? "User Email", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("Premium Member", style: TextStyle(color: Color(0xFFFF9F0A), fontSize: 14)),
            const SizedBox(height: 40),
            
            Container(
              decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildProfileOption(CupertinoIcons.person, "Personal Data"),
                  const Divider(color: Colors.white10, height: 1),
                  _buildProfileOption(CupertinoIcons.graph_square, "Workout History"),
                  const Divider(color: Colors.white10, height: 1),
                  _buildProfileOption(CupertinoIcons.settings, "Settings"),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: Colors.redAccent.withOpacity(0.2),
                onPressed: () => FirebaseAuth.instance.signOut(), // Firebase SignOut
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
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}

// ==========================================
// REUSABLE UI COMPONENTS
// ==========================================
class StatCard extends StatelessWidget {
  final IconData icon; final String title, value; final Color color;
  const StatCard({super.key, required this.icon, required this.title, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Icon(icon, color: color, size: 28), const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    );
  }
}

class WorkoutChallengeCard extends StatelessWidget {
  const WorkoutChallengeCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Full Body Blast", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          const Text("3 Exercises • Approx 20 Mins", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: const Color(0xFFFF9F0A),
              borderRadius: BorderRadius.circular(16),
              onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (ctx) => const ActiveWorkoutScreen())),
              child: const Text("Start Workout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class PlansTab extends StatelessWidget {
  const PlansTab({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Plans List Here", style: TextStyle(color: Colors.white)));
  }
}