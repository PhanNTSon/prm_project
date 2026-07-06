import 'package:flutter/material.dart';

class HomeAppbar extends StatelessWidget {
  final String currentPage;

  const HomeAppbar({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF171A21),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Icon(Icons.sports_esports, color: Colors.white, size: 35),
              const SizedBox(width: 10),
              const Text(
                "MEME",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          const SizedBox(width: 40),

          // Navigation Menu
          SteamNavButton(
            title: "STORE",
            isSelected: currentPage == 'store',
            onTap: () {},
          ),
          SteamNavButton(
            title: "LIBRARY",
            isSelected: currentPage == 'library',
            onTap: () {},
          ),
          SteamNavButton(
            title: "COMMUNITY",
            isSelected: currentPage == 'community',
            onTap: () {},
          ),
          SteamNavButton(
            title: "NEWS",
            isSelected: currentPage == 'news',
            onTap: () {},
          ),

          const Spacer(),

          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {},
          ),

          const SizedBox(width: 20),

          // Search Bar
          _buildSearchBar(),

          const SizedBox(width: 20),

          // Cart
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            color: Colors.white,
            onPressed: () {},
          ),

          const SizedBox(width: 10),

          // User Profile
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text("Username", style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
        onPressed: () {},
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF66C0F4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Widget _buildSearchBar() {
  return SizedBox(
    height: 40,
    width: 300,
    child: Row(
      children: [
        Expanded(
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search games...",
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A475E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),

        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: Color(0xFF66C0F4)),
          child: const Icon(Icons.search, color: Colors.white, size: 20),
        ),
      ],
    ),
  );
}

class SteamNavButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SteamNavButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF66C0F4)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF66C0F4) : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
