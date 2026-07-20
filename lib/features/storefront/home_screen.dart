import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/widgets/appBar/home_appbar.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/features/storefront/providers/home_provider.dart';
import 'package:prm_project/features/storefront/views/widgets/featured_game_card.dart';
import 'package:prm_project/features/storefront/views/widgets/category_card.dart';
import 'package:prm_project/features/storefront/views/widgets/horizontal_game_card.dart';
import 'package:prm_project/features/storefront/providers/game_list_provider.dart';
import 'package:prm_project/features/storefront/data/models/game_basic_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _featuredScrollController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _featuredScrollController = ScrollController();
    _pageController = PageController(viewportFraction: 0.85);

    // Load dữ liệu khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HomeProvider>();
      // Chỉ load nếu chưa có dữ liệu
      if (!provider.hasFeatured && !provider.isLoading) {
        provider.loadHomeData();
      }
    });
  }

  @override
  void dispose() {
    _featuredScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      body: Column(
        children: [
          const HomeAppbar(currentPage: 'store'),
          Expanded(
            child: Consumer<HomeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && !provider.hasFeatured) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF66C0F4),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadHomeData(),
                  color: const Color(0xFF66C0F4),
                  backgroundColor: const Color(0xFF1E3144),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── SECTION: Featured ───────────────────────────────
                        _buildFeaturedSection(provider),

                        const SizedBox(height: 32),

                        // ─── SECTION: Browse by Category ─────────────────────
                        _buildCategorySection(provider),

                        const SizedBox(height: 32),

                        // ─── SECTION: Special Offers ─────────────────────────
                        if (provider.specialOffers.isNotEmpty) ...[
                          _buildHorizontalListSection(
                            title: 'Special Offers',
                            accentColor: const Color(0xFFBEEE11),
                            games: provider.specialOffers,
                          ),
                          const SizedBox(height: 32),
                        ],

                        // ─── SECTION: Under $5 ───────────────────────────────
                        if (provider.under5Games.isNotEmpty) ...[
                          _buildHorizontalListSection(
                            title: 'Under \$5',
                            accentColor: const Color(0xFFFF9900),
                            games: provider.under5Games,
                          ),
                          const SizedBox(height: 32),
                        ],

                        // ─── SECTION: Free to Play ───────────────────────────
                        if (provider.freeGames.isNotEmpty) ...[
                          _buildHorizontalListSection(
                            title: 'Free to Play',
                            accentColor: const Color(0xFF66C0F4),
                            games: provider.freeGames,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // FEATURED SECTION
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildFeaturedSection(HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              // Thanh accent bên trái
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF66C0F4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Featured & Recommended',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Nút refresh
              GestureDetector(
                onTap: () => provider.refreshFeatured(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh,
                      color: Color(0xFF66C0F4),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Refresh',
                      style: TextStyle(
                        color: Color(0xFF66C0F4),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Slider (nếu có data)
        if (provider.hasFeatured)
          SizedBox(
            height: 200,
            child: ListView.builder(
              controller: _featuredScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: provider.featuredGames.length,
              itemBuilder: (context, index) {
                final game = provider.featuredGames[index];
                return FeaturedGameCard(
                  game: game,
                  onTap: () => context.push('/game-detail/${game.id}'),
                );
              },
            ),
          )
        else
          _buildFeaturedPlaceholder(),
      ],
    );
  }

  Widget _buildFeaturedPlaceholder() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 320,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF16202D),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_esports, color: Color(0xFF2A475E), size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Đang tải...',
                    style: TextStyle(color: Color(0xFF4A6B8A)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BROWSE BY CATEGORY SECTION
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildCategorySection(HomeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C6B22),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Browse by Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Grid categories (nếu có data)
        if (provider.hasCategories)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () {
                    context.read<GameListProvider>().setFilter(
                          tagId: category.id,
                          categoryName: category.name,
                        );
                    context.push('/all-games');
                  },
                );
              },
            ),
          )
        else if (!provider.isLoading)
          _buildCategoryPlaceholder(),
      ],
    );
  }

  Widget _buildCategoryPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF16202D),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // HORIZONTAL GAME LIST SECTION HELPER
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHorizontalListSection({
    required String title,
    required Color accentColor,
    required List<GameBasicModel> games,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Horizontal List
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return HorizontalGameCard(
                game: game,
                onTap: () => context.push('/game-detail/${game.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
