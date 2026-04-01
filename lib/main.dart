import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessApp());
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desi Fitness iOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // iOS Deep Black
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9F0A), // iOS Accent Orange
          surface: Color(0xFF1C1C1E), // iOS Card Grey
        ),
        fontFamily: 'San Francisco', // Default sans-serif gives iOS feel
      ),
      home: const FitnessScreen(),
    );
  }
}

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // iOS Style Large Title
              const Padding(
                padding: EdgeInsets.only(top: 16, bottom: 24),
                child: Text(
                  "Fitness",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Section 1: 30 Days Challenge
              const SectionTitle(title: "Today's Workout"),
              const WorkoutChallengeCard(),
              const SizedBox(height: 24),

              // Section 2: Diet Plan
              const SectionTitle(title: "Budget Diet Plan"),
              const DietPlanCard(),
              const SizedBox(height: 24),

              // Section 3: Paid Promotion / Supplements (Horizontal Scroll)
              const SectionTitle(title: "Recommended For You"),
              const SupplementsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Day 1 of 30",
                style: TextStyle(color: Color(0xFFFF9F0A), fontWeight: FontWeight.bold),
              ),
              Text(
                "🔥 45 Mins",
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Chest & Triceps Build",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "• 3x15 Normal Push-ups\n• 3x10 Incline Push-ups\n• 3x12 Chair Dips",
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Workout Started!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F0A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Start Workout", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "₹25/Day Protein Plan",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            "🍳 Morning:\n125g Sprouted Chana (20g Protein)\n\n🍛 Lunch/Dinner:\n60g Soya Chunks (30g Protein)",
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

class SupplementsSection extends StatelessWidget {
  const SupplementsSection({super.key});

  final List<Map<String, String>> supplements = const [
    {"name": "Whey Protein", "price": "₹1,999", "icon": "💊"},
    {"name": "Creatine", "price": "₹499", "icon": "⚡"},
    {"name": "Pre-Workout", "price": "₹899", "icon": "🚀"},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: supplements.length,
        itemBuilder: (context, index) {
          final item = supplements[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Redirecting to buy ${item['name']}...")),
              );
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text("Ads", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ),
                  const Spacer(),
                  Text(item['icon']!, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    item['name']!,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['price']!,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF9F0A)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
