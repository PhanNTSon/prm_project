import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/game_list_provider.dart';
import '../widgets/game_search_result_item.dart';

/// Màn hình hiển thị TẤT CẢ game, sắp xếp theo tên A→Z, có phân trang.
class AllGamesScreen extends StatefulWidget {
  const AllGamesScreen({super.key});

  @override
  State<AllGamesScreen> createState() => _AllGamesScreenState();
}

class _AllGamesScreenState extends State<AllGamesScreen> {
  @override
  void initState() {
    super.initState();
    // Tải trang đầu tiên ngay khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameListProvider>().loadFirstPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),

      // === APPBAR ===
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'All Games',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        // Badge hiển thị tổng số game
        actions: [
          Consumer<GameListProvider>(
            builder: (context, provider, child) {
              if (provider.totalElements > 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      '${provider.totalElements} games',
                      style: const TextStyle(
                        color: Color(0xFF8F98A0),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),

      // === BODY ===
      body: Consumer<GameListProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Header: chỉ số A-Z
              _buildAlphabetHeader(),

              // Nội dung chính
              Expanded(child: _buildContent(provider)),

              // Footer phân trang
              if (!provider.isLoading && provider.totalPages > 1)
                _buildPagination(provider),
            ],
          );
        },
      ),
    );
  }

  /// Thanh chỉ số A-Z gợi ý visual rằng list đang sort theo tên
  Widget _buildAlphabetHeader() {
    return Container(
      color: const Color(0xFF2A475E),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.sort_by_alpha, color: Color(0xFF66C0F4), size: 16),
          const SizedBox(width: 8),
          const Text(
            'Sắp xếp theo tên: A → Z',
            style: TextStyle(
              color: Color(0xFF66C0F4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Phần hiển thị chính: loading / error / empty / list
  Widget _buildContent(GameListProvider provider) {
    // 1. Đang loading
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF66C0F4)),
      );
    }

    // 2. Có lỗi
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.white54, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66C0F4),
                foregroundColor: Colors.white,
              ),
              onPressed: () => provider.loadFirstPage(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // 3. Không có game nào
    if (provider.games.isEmpty) {
      return const Center(
        child: Text(
          'Không có game nào.',
          style: TextStyle(color: Color(0xFF8F98A0), fontSize: 16),
        ),
      );
    }

    // 4. Danh sách game
    return ListView.builder(
      itemCount: provider.games.length,
      itemBuilder: (context, index) {
        final game = provider.games[index];
        return GameSearchResultItem(
          game: game,
          onTap: () => context.push('/home/game-detail/${game.id}'),
        );
      },
    );
  }

  /// Footer phân trang: Prev | Trang X / Y | Next
  Widget _buildPagination(GameListProvider provider) {
    return Container(
      color: const Color(0xFF171A21),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nút Previous
          _PaginationButton(
            icon: Icons.chevron_left,
            label: 'Prev',
            enabled: provider.hasPreviousPage,
            onTap: () => provider.loadPreviousPage(),
          ),

          const SizedBox(width: 8),

          // Các số trang (hiển thị tối đa 5 trang quanh trang hiện tại)
          ..._buildPageNumbers(provider),

          const SizedBox(width: 8),

          // Nút Next
          _PaginationButton(
            icon: Icons.chevron_right,
            label: 'Next',
            enabled: provider.hasNextPage,
            onTap: () => provider.loadNextPage(),
          ),
        ],
      ),
    );
  }

  /// Tạo danh sách các nút số trang (hiển thị 5 trang xung quanh trang hiện tại)
  List<Widget> _buildPageNumbers(GameListProvider provider) {
    final int current = provider.currentPage;
    final int total = provider.totalPages;

    // Tính range 5 trang hiển thị
    int start = (current - 2).clamp(0, total - 1);
    int end = (start + 4).clamp(0, total - 1);
    // Điều chỉnh start nếu end đã sát cuối
    start = (end - 4).clamp(0, end);

    return List.generate(end - start + 1, (i) {
      final pageIndex = start + i;
      final isSelected = pageIndex == current;

      return GestureDetector(
        onTap: () => provider.loadPage(pageIndex),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF66C0F4) : const Color(0xFF2A475E),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            '${pageIndex + 1}', // Hiển thị 1-indexed
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF8F98A0),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}

/// Widget nút Prev/Next dùng lại được
class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF2A475E) : const Color(0xFF1B2838),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: enabled
                ? const Color(0xFF66C0F4)
                : const Color(0xFF2A475E),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.chevron_left) Icon(icon, size: 16, color: enabled ? const Color(0xFF66C0F4) : Colors.white24),
            Text(
              label,
              style: TextStyle(
                color: enabled ? const Color(0xFF66C0F4) : Colors.white24,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (icon == Icons.chevron_right) Icon(icon, size: 16, color: enabled ? const Color(0xFF66C0F4) : Colors.white24),
          ],
        ),
      ),
    );
  }
}
