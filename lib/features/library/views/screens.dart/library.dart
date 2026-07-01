import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/auth/providers/library_provider.dart';
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<LibraryProvider>().loadLibrary();
    });
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
                  itemCount: provider.games.length,

                  itemBuilder: (_, index) {
                    return OwnedGameTile(game: provider.games[index]);
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
