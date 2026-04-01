import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessApp());
}

// ==========================================
// STEP 1: MAIN APP & THEME SETUP
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
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure iOS Black
        primaryColor: const Color(0xFFFF9F0A), // iOS Accent Orange
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9F0A),
          surface: Color(0xFF1C1C1E), // iOS Dark Gray for Cards
        ),
        fontFamily: '.SF Pro Display',
      ),
      home: const MainDashboard(),
    );
  }
}

// ==========================================
// STEP 2: iOS BOTTOM NAVIGATION (DASHBOARD)
// ==========================================
class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: Colors.black,
      tabBar: CupertinoTabBar(
        backgroundColor: const Color(0xFF1C1C1E).withOpacity(0.8), // Frosted glass effect
        activeColor: const Color(0xFFFF9F0A),
        inactiveColor: CupertinoColors.systemGrey,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_grid_2x2), label: "Plans"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.leaf_arrow_circlepath), label: "Diet"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: "Profile"),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const HomeTab();
          case 1:
            return const PlansTab();
          case 2:
            return const Center(child: Text("Diet Plans Coming Soon", style: TextStyle(color: Colors.white, fontSize: 20)));
          case 3:
            return const Center(child: Text("Profile Settings", style: TextStyle(color: Colors.white, fontSize: 20)));
          default:
            return const HomeTab();
        }
      },
    );
  }
}

// ==========================================
// STEP 3: ENHANCED HOME TAB (WITH STATS)
// ==========================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting & Profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Good Morning,", style: TextStyle(color: Colors.grey, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Champion! 🔥", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage("https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=200&auto=format&fit=crop"),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Daily Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    StatCard(icon: CupertinoIcons.flame_fill, title: "Calories", value: "450", color: Colors.orange),
                    StatCard(icon: CupertinoIcons.time, title: "Minutes", value: "45", color: Colors.blueAccent),
                    StatCard(icon: CupertinoIcons.checkmark_seal_fill, title: "Workouts", value: "3/5", color: Colors.greenAccent),
                  ],
                ),
                const SizedBox(height: 32),

                const SectionTitle(title: "Today's Target"),
                const WorkoutChallengeCard(),
                const SizedBox(height: 32),

                const SectionTitle(title: "Recommended Diet"),
                const DietPlanCard(),
                const SizedBox(height: 100), // Padding for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// STEP 4: ACTIVE WORKOUT SCREEN (TIMER & CHECKMARKS)
// ==========================================
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Timer? _timer;
  int _seconds = 0;

  // Exercise List with State (Done or Not)
  final List<Map<String, dynamic>> exercises = [
    {
      "name": "Normal Push-ups",
      "reps": "3 Sets x 15 Reps",
      "image": "https://images.unsplash.com/photo-1598971639058-fab3c3109a00?q=80&w=200&auto=format&fit=crop", // Pushup posture
      "done": false
    },
    {
      "name": "Incline Push-ups",
      "reps": "3 Sets x 10 Reps",
      "image": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=200&auto=format&fit=crop",
      "done": false
    },
    {
      "name": "Chair Dips",
      "reps": "3 Sets x 12 Reps",
      "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=200&auto=format&fit=crop",
      "done": false
    },
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void toggleExercise(int index) {
    setState(() {
      exercises[index]['done'] = !exercises[index]['done'];
    });
  }

  void finishWorkout() {
    bool allDone = exercises.every((ex) => ex['done'] == true);
    if (!allDone) {
      // Show Warning
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Incomplete Workout"),
          content: const Text("You haven't finished all exercises. Are you sure you want to end?"),
          actions: [
            CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text("End Workout"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } else {
      // Show Success
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Great Job! 🎉"),
          content: Text("You completed the workout in $formattedTime."),
          actions: [
            CupertinoDialogAction(
              child: const Text("Awesome"),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CupertinoNavigationBar(
        backgroundColor: Colors.black,
        leading: CupertinoNavigationBarBackButton(color: const Color(0xFFFF9F0A), onPressed: () => Navigator.pop(context)),
        middle: const Text("Live Workout", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Live Timer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const Text("ELAPSED TIME", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 10),
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Color(0xFFFF9F0A), fontFeatures: [FontFeature.tabularFigures()]),
                ),
              ],
            ),
          ),
          
          // Exercise List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final ex = exercises[index];
                final isDone = ex['done'];

                return GestureDetector(
                  onTap: () => toggleExercise(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.green.withOpacity(0.1) : const Color(0xFF1C1C1E),
                      border: Border.all(color: isDone ? Colors.green : Colors.transparent, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // Position Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(ex['image'], width: 70, height: 70, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 16),
                        
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ex['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDone ? Colors.greenAccent : Colors.white, decoration: isDone ? TextDecoration.lineThrough : null)),
                              const SizedBox(height: 6),
                              Text(ex['reps'], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                        
                        // Checkmark
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone ? Colors.green : Colors.transparent,
                            border: Border.all(color: isDone ? Colors.green : Colors.grey, width: 2),
                          ),
                          child: isDone ? const Icon(CupertinoIcons.checkmark, color: Colors.black, size: 20) : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Finish Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: CupertinoButton(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
                onPressed: finishWorkout,
                child: const Text("Finish Workout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// STEP 5: PLANS TAB & UI COMPONENTS
// ==========================================
// Plans Tab remains unchanged from the previous premium version
class PlansTab extends StatelessWidget {
  const PlansTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Plans List (Refer to previous code)", style: TextStyle(color: Colors.white)));
  }
}

// ================= REUSABLE COMPONENTS =================

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const StatCard({super.key, required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF1C1C1E), const Color(0xFF2C2C2E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFFFF9F0A).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFF9F0A).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text("Day 1 of 30", style: TextStyle(color: Color(0xFFFF9F0A), fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const Text("🔥 45 Mins", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Chest & Triceps Build", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 8),
          const Text("3 Exercises • 3 Sets each", style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: CupertinoButton(
              color: const Color(0xFFFF9F0A),
              borderRadius: BorderRadius.circular(16),
              onPressed: () {
                // Navigate to the Live Workout Screen with animation
                Navigator.push(context, CupertinoPageRoute(builder: (context) => const ActiveWorkoutScreen()));
              },
              child: const Text("Start Workout", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class DietPlanCard extends StatelessWidget {
  const DietPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show Bottom Sheet on tap
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                const Text("Full Budget Diet Plan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                const Text("🍳 Morning (8:00 AM):\n125g Sprouted Chana, 1 Banana\n\n🍛 Lunch (1:00 PM):\n60g Soya Chunks, 2 Roti, Salad\n\n🥛 Evening (5:00 PM):\n1 Glass Milk, Handful of Peanuts", style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.6)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(color: const Color(0xFFFF9F0A), onPressed: () => Navigator.pop(context), child: const Text("Got it!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                )
              ],
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.leaf_arrow_circlepath, color: Colors.greenAccent, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("₹25/Day Protein Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text("Tap to view full meals", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}