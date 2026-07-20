import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/game_search_provider.dart';
import '../widgets/game_search_result_item.dart';

/// Màn hình tìm kiếm game fullscreen.
/// Thiết kế theo phong cách Steam: nền tối, thanh search trên cùng.
class GameSearchScreen extends StatefulWidget {
  const GameSearchScreen({super.key});

  @override
  State<GameSearchScreen> createState() => _GameSearchScreenState();
}

class _GameSearchScreenState extends State<GameSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      // === APPBAR: Thanh tìm kiếm ===
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        elevation: 0,
        // Nút back
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Xóa kết quả trước khi thoát
            context.read<GameSearchProvider>().clearSearch();
            context.pop();
          },
        ),
        // Thanh search
        title: TextField(
          controller: _searchController,
          autofocus: true, // Tự động mở bàn phím
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm game...',
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            // Gọi search với debounce
            context.read<GameSearchProvider>().search(value);
          },
        ),
        // Nút xóa text
        actions: [
          Consumer<GameSearchProvider>(
            builder: (context, provider, child) {
              if (provider.currentTerm.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    provider.clearSearch();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),

      // === BODY: Kết quả tìm kiếm ===
      body: Consumer<GameSearchProvider>(
        builder: (context, provider, child) {
          return _buildBody(provider);
        },
      ),
    );
  }

  /// Hiển thị body dựa trên trạng thái hiện tại
  Widget _buildBody(GameSearchProvider provider) {
    // 1. Đang loading
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF66C0F4),
        ),
      );
    }

    // 2. Có lỗi
    if (provider.errorMessage != null) {
      return _buildMessageView(
        icon: Icons.error_outline,
        message: provider.errorMessage!,
        color: Colors.redAccent,
      );
    }

    // 3. Chưa gõ gì
    if (!provider.hasSearched) {
      return _buildMessageView(
        icon: Icons.search,
        message: 'Nhập tên game để tìm kiếm',
        color: const Color(0xFF8F98A0),
      );
    }

    // 4. Không tìm thấy kết quả
    if (!provider.hasResults) {
      return _buildMessageView(
        icon: Icons.search_off,
        message: 'Không tìm thấy game nào\ncho "${provider.currentTerm}"',
        color: const Color(0xFF8F98A0),
      );
    }

    // 5. Có kết quả → Hiển thị danh sách
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: số kết quả
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            '${provider.searchResults.length} kết quả',
            style: const TextStyle(
              color: Color(0xFF8F98A0),
              fontSize: 13,
            ),
          ),
        ),

        // Danh sách game
        Expanded(
          child: ListView.builder(
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final game = provider.searchResults[index];
              return GameSearchResultItem(
                game: game,
                onTap: () => context.push('/game-detail/${game.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Widget hiển thị thông báo (chưa search, không kết quả, lỗi)
  Widget _buildMessageView({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
