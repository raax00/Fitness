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
        fontFamily: '.SF Pro Display', // Native iOS Font look
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1.0),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
          bodyMedium: TextStyle(height: 1.5, letterSpacing: 0.2), // Better Likhawat
        ),
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
    // CupertinoTabScaffold gives the native iOS blur bottom bar and keeps state
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
            return const Center(child: Text("Diet Plans", style: TextStyle(color: Colors.white, fontSize: 24)));
          case 3:
            return const Center(child: Text("Profile", style: TextStyle(color: Colors.white, fontSize: 24)));
          default:
            return const HomeTab();
        }
      },
    );
  }
}

// ==========================================
// STEP 3: HOME TAB (RESPONSIVE & MODERN)
// ==========================================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // iOS Large Expanding App Bar
          const CupertinoSliverNavigationBar(
            largeTitle: Text("Fitness", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
            border: null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SectionTitle(title: "Today's Workout"),
                  WorkoutChallengeCard(),
                  SizedBox(height: 32),
                  SectionTitle(title: "Budget Diet Plan"),
                  DietPlanCard(),
                  SizedBox(height: 100), // Padding for bottom nav
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
// STEP 4: PLANS TAB (RESPONSIVE GRID)
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
      "title": "AESTHETICS",
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
    // Get screen width to make grid responsive
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 4 : 2; // 4 columns on tablet, 2 on phone

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text("Workout Plans", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.black,
            border: null,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Better proportion for cards
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final plan = plans[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => PlanDetailScreen(planData: plan)),
                      );
                    },
                    child: GridPlanCard(plan: plan),
                  );
                },
                childCount: plans.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20), // Premium rounded corners
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with dark gradient overlay for text readability
          Image.network(
            plan["image"],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
          ),
          // Gradient for smooth blending
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          
          // Premium Lock Icon
          if (plan["isPremium"])
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.lock_fill, color: Colors.white, size: 14),
              ),
            ),

          // Bottom Info Area (Glassmorphism look)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // iOS Blur
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: plan["tagColor"].withOpacity(0.9), // Transparent color
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${plan['duration']} ${plan['tag']}",
                        style: TextStyle(
                          color: plan['tag'] == '(free)' ? Colors.red : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plan['title'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// STEP 5: PLAN DETAILS (MODERN UI WITH SLIVER)
// ==========================================
class PlanDetailScreen extends StatelessWidget {
  final Map<String, dynamic> planData;
  const PlanDetailScreen({super.key, required this.planData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // As per your screenshot requirement
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // iOS Style Parallax Header
          SliverAppBar(
            expandedHeight: 350.0,
            stretch: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(planData['image'], fit: BoxFit.cover),
                  // Gradient overlay to make back button visible
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Details Content Area
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -30, 0), // Pulls content up over image
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                child: Column(
                  children: [
                    // Title Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCC00),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text(planData['duration'].toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(planData['title'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Before / After Badges (Responsive Row)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        CircularBadge(imageLabel: "Before", isYellow: false),
                        CircularBadge(imageLabel: "After", isYellow: true),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Description
                    const Text(
                      "About: Want to see a complete change in your body? Use this program to tone down the extra fat by working out for 4 days a week. By following this program you can lose at least 20 pounds of fat and gain lean muscle mass.",
                      style: TextStyle(color: Colors.black87, fontSize: 15, height: 1.6, fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    
                    // Specs Details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F7), // iOS Light Gray
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Duration:", "3 months"),
                          const Divider(color: Colors.black12, height: 24),
                          _buildDetailRow("Goal:", "Lose fat"),
                          const Divider(color: Colors.black12, height: 24),
                          _buildDetailRow("Requirements:", "Beginners"),
                          const Divider(color: Colors.black12, height: 24),
                          _buildDetailRow("Target Group:", "Men and women"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Buttons Responsive Row
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () {},
                            child: const Text("Get Plan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CupertinoButton(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () {},
                            child: const Text("Premium", style: TextStyle(color: Color(0xFFFF9F0A), fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 15)),
        Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
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
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF2F2F7), width: 4), // Smooth border
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            image: const DecorationImage(
              image: NetworkImage("https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=200&auto=format&fit=crop"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isYellow ? const Color(0xFFFFCC00) : const Color(0xFFE5E5EA), // Standard iOS Gray
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            imageLabel, 
            style: TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.bold, 
              fontSize: 13,
              letterSpacing: 0.5
            )
          ),
        ),
      ],
    );
  }
}

// ==========================================
// REUSABLE UI COMPONENTS (HOME TAB)
// ==========================================
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
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
        color: const Color(0xFF1C1C1E), // iOS Card Color
        borderRadius: BorderRadius.circular(24), // Modern Radius
        border: Border.all(color: Colors.white.withOpacity(0.05)), // Subtle edge
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
              Row(
                children: [
                  const Icon(CupertinoIcons.flame_fill, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text("45 Mins", style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Chest & Triceps Build", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Text(
            "• 3x15 Normal Push-ups\n• 3x10 Incline Push-ups\n• 3x12 Chair Dips",
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: const Color(0xFFFF9F0A),
              borderRadius: BorderRadius.circular(16),
              onPressed: () {},
              child: const Text("Start Workout", style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold)),
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(CupertinoIcons.money_dollar_circle_fill, color: Colors.greenAccent, size: 28),
              SizedBox(width: 10),
              Text("₹25/Day Protein Plan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
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