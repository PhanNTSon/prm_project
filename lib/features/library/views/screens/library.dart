import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/library_provider.dart';
import '../../../../core/widgets/library_page/empty_library.dart';
import '../../../../core/widgets/library_page/library_header.dart';
import '../../../../core/widgets/library_page/library_searchbar.dart';
import '../../../../core/widgets/library_page/owned_game_tile.dart';
import '../../../../core/widgets/loading/shimmer_game_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final searchController = TextEditingController();

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LibraryProvider>().loadLibrary(refresh: true);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final provider = context.read<LibraryProvider>();

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      provider.loadLibrary();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Consumer<LibraryProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.all(12),
                child: ShimmerGameCard(),
              ),
            );
          }

          if (provider.isError && provider.games.isEmpty) {
            return const Center(child: Text('Failed to load library'));
          }
          if (provider.games.isEmpty) {
            return const EmptyLibrary();
          }

          return Column(
            children: [
              const LibraryHeader(),

              LibrarySearchBar(controller: searchController),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.builder(
                  itemCount: provider.sortedGames.length,

                  itemBuilder: (_, index) {
                    final game = provider.sortedGames[index];

                    return OwnedGameTile(game: game);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
