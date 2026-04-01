import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desi Fitness Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // iOS Deep Black
        primaryColor: const Color(0xFFFF9F0A), // iOS Accent Orange
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9F0A),
          surface: Color(0xFF1C1C1E),
        ),
        fontFamily: 'San Francisco', // Standard iOS font feel
      ),
      home: const MainDashboard(),
    );
  }
}

// ==========================================
// 1. BOTTOM NAVIGATION & DASHBOARD (MENU)
// ==========================================
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const PlansTab(), // New Screen from your screenshot
    const Center(child: Text("Diet Plans", style: TextStyle(fontSize: 24, color: Colors.white))),
    const Center(child: Text("Profile", style: TextStyle(fontSize: 24, color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF111111),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFFFF9F0A),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_grid_2x2), label: "Plans"),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.leaf_arrow_circlepath), label: "Diet"),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 2. HOME TAB (Original Enhanced)
// ==========================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // iOS bounce effect
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: Text(
                "Fitness",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SectionTitle(title: "Today's Workout"),
            const WorkoutChallengeCard(),
            const SizedBox(height: 24),
            const SectionTitle(title: "Budget Diet Plan"),
            const DietPlanCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. PLANS TAB (From Screenshot 2)
// ==========================================
class PlansTab extends StatelessWidget {
  const PlansTab({super.key});

  final List<Map<String, dynamic>> plans = const [
    {
      "title": "BODY BUILDER",
      "duration": "3 Months",
      "tag": "(free)",
      "isPremium": false,
      "tagColor": Color(0xFFFFCC00),
      "image": "https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=400&auto=format&fit=crop"
    },
    {
      "title": "BODYBUILDER",
      "duration": "5 months",
      "tag": "",
      "isPremium": true,
      "tagColor": Colors.white,
      "image": "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=400&auto=format&fit=crop"
    },
    {
      "title": "FAT DESTROYER",
      "duration": "12 Weeks",
      "tag": "Fat",
      "isPremium": true,
      "tagColor": Color(0xFFFFCC00),
      "image": "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=400&auto=format&fit=crop"
    },
    {
      "title": "BELLY FAT LOSS",
      "duration": "8 Weeks",
      "tag": "",
      "isPremium": true,
      "tagColor": Color(0xFFFFCC00),
      "image": "https://images.unsplash.com/photo-1518611012118-696072aa579a?q=80&w=400&auto=format&fit=crop"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Dozens Of WORKOUT PLANS",
            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(
            "For Your Goal",
            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Tall cards
              ),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to details screen with iOS animation
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => PlanDetailScreen(planData: plan),
                      ),
                    );
                  },
                  child: GridPlanCard(plan: plan),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GridPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  const GridPlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              plan["image"],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
            ),
          ),
          
          // Lock Icon for Premium
          if (plan["isPremium"])
            Positioned(
              top: 10,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.6),
                radius: 14,
                child: const Icon(CupertinoIcons.lock_fill, color: Colors.white, size: 14),
              ),
            ),

          // Bottom Banner overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: plan["tagColor"]),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${plan['duration']} ",
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        if (plan['tag'].isNotEmpty)
                          TextSpan(
                            text: plan['tag'],
                            style: TextStyle(color: plan['tag'] == '(free)' ? Colors.red : Colors.black, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    plan['title'],
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
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
// 4. PLAN DETAIL SCREEN (From Screenshot 3)
// ==========================================
class PlanDetailScreen extends StatelessWidget {
  final Map<String, dynamic> planData;
  const PlanDetailScreen({super.key, required this.planData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Fat Loss WORKOUT PLAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // The White Card Design exactly like Screenshot
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Hero Image Area with overlapping Before/After
                  SizedBox(
                    height: 250,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Main Body Image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                          child: Image.network(
                            planData['image'],
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        // Title Banner overlapping image
                        Positioned(
                          bottom: 30,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFCC00),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(planData['duration'].toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(planData['title'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18)),
                              ],
                            ),
                          ),
                        ),
                        // 'Before' Circle
                        Positioned(
                          bottom: -20,
                          right: 10,
                          child: CircularBadge(imageLabel: "Before"),
                        ),
                        // 'After' Circle
                        Positioned(
                          bottom: -40,
                          left: 20,
                          child: CircularBadge(imageLabel: "After", isYellow: true),
                        ),
                      ],
                    ),
                  ),
                  
                  // Description & Details
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
                    child: Column(
                      children: [
                        const Text(
                          "About: Want to see complete change in your body? Use this program to tone down the extra fat by working out for 4 days a week. By following this program you can lose atleast 20 pounds of fat and even gain lean muscle mass.",
                          style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow("Duration:", "3 months"),
                        _buildDetailRow("Goal:", "Lose fat"),
                        _buildDetailRow("Requirements:", "Beginners"),
                        _buildDetailRow("Target Group:", "Men and women"),
                        const SizedBox(height: 30),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C2C2E), // Dark Grey
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Get this plan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C2C2E),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text("Get Premium", style: TextStyle(color: Color(0xFFFF9F0A), fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        ],
      ),
    );
  }
}

// Widget for the circular Before/After images
class CircularBadge extends StatelessWidget {
  final String imageLabel;
  final bool isYellow;
  
  const CircularBadge({super.key, required this.imageLabel, this.isYellow = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: Colors.grey[300],
            image: const DecorationImage(
              image: NetworkImage("https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=200&auto=format&fit=crop"), // Placeholder abs image
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          transform: Matrix4.translationValues(0, -15, 0), // Pull badge up slightly
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isYellow ? const Color(0xFFFFCC00) : const Color(0xFFFFCC00).withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(imageLabel, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }
}

// ==========================================
// Reusable UI Components for Home Tab
// ==========================================
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24), // iOS Smooth Corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Day 1 of 30", style: TextStyle(color: Color(0xFFFF9F0A), fontWeight: FontWeight.bold, fontSize: 16)),
              Text("🔥 45 Mins", style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Chest & Triceps Build", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 12),
          Text(
            "• 3x15 Normal Push-ups\n• 3x10 Incline Push-ups\n• 3x12 Chair Dips",
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F0A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("₹25/Day Protein Plan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          Text(
            "🍳 Morning:\n125g Sprouted Chana (20g Protein)\n\n🍛 Lunch/Dinner:\n60g Soya Chunks (30g Protein)",
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}
