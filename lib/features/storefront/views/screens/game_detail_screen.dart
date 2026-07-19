import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/game_detail_model.dart';
import '../../providers/game_detail_provider.dart';
import 'package:prm_project/features/cart_payment/providers/cart_provider.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;
  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameDetailProvider>().loadGame(widget.gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B2838),
      body: Consumer<GameDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF66C0F4)),
            );
          }

          if (provider.status == GameDetailStatus.error || !provider.hasData) {
            return _buildError(provider.errorMessage);
          }

          return _buildContent(provider.game!);
        },
      ),
    );
  }

  Widget _buildError(String? message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF66C0F4), size: 48),
          const SizedBox(height: 12),
          Text(
            message ?? 'Không tải được thông tin game.',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => context.read<GameDetailProvider>().loadGame(widget.gameId),
            icon: const Icon(Icons.refresh, color: Color(0xFF66C0F4)),
            label: const Text('Thử lại', style: TextStyle(color: Color(0xFF66C0F4))),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(GameDetailModel game) {
    return CustomScrollView(
      slivers: [
        // ── Sliver App Bar với ảnh header ─────────────────────────────────
        _buildSliverAppBar(game),

        // ── Nội dung phía dưới ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên game + tags
                _buildTitleSection(game),
                const SizedBox(height: 16),

                // Giá + nút Add to Cart
                _buildPriceAndCart(game),
                const SizedBox(height: 24),

                // Thông tin publisher/developer
                _buildInfoRow(game),
                const SizedBox(height: 24),

                // Mô tả
                if (game.description != null && game.description!.isNotEmpty) ...[
                  _buildSectionTitle('About This Game'),
                  const SizedBox(height: 8),
                  Text(
                    game.description!,
                    style: const TextStyle(
                      color: Color(0xFFACDBF5),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Screenshots
                if (game.screenshots.isNotEmpty) ...[
                  _buildSectionTitle('Screenshots'),
                  const SizedBox(height: 12),
                  _buildScreenshots(game.screenshots),
                  const SizedBox(height: 24),
                ],

                // Tags
                if (game.tags.isNotEmpty) ...[
                  _buildSectionTitle('Tags'),
                  const SizedBox(height: 8),
                  _buildTags(game),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── SLIVER APP BAR ──────────────────────────────────────────────────────────

  Widget _buildSliverAppBar(GameDetailModel game) {
    final headerUrl = game.headerImageUrl ?? game.imageUrl;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF171A21),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white70),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Header image
            if (headerUrl != null)
              CachedNetworkImage(
                imageUrl: headerUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFF16202D)),
                errorWidget: (_, __, ___) => _buildHeaderFallback(game.title),
              )
            else
              _buildHeaderFallback(game.title),

            // Gradient fade bottom
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1.0],
                  colors: [
                    Colors.transparent,
                    const Color(0xFF1B2838).withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderFallback(String title) {
    return Container(
      color: const Color(0xFF16202D),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_esports, color: Color(0xFF2A475E), size: 64),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF4A6B8A), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── TITLE ───────────────────────────────────────────────────────────────────

  Widget _buildTitleSection(GameDetailModel game) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail nhỏ bên trái
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: 72,
            height: 54,
            child: game.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: game.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: const Color(0xFF2A475E)),
                  )
                : Container(color: const Color(0xFF2A475E)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (game.rating != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      game.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Color(0xFFFFD700), fontSize: 13),
                    ),
                    if (game.reviewCount != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${_formatCount(game.reviewCount!)} reviews)',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── PRICE + ADD TO CART ──────────────────────────────────────────────────────

  Widget _buildPriceAndCart(GameDetailModel game) {
    final isInCart = context.watch<CartProvider>().items
        .any((item) => item.gameId == game.id);
    final provider = context.watch<GameDetailProvider>();
    final isOwned = provider.isOwned;
    final isCheckingOwnership = provider.isCheckingOwnership;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16202D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A475E), width: 1),
      ),
      child: Row(
        children: [
          // Giá
          Expanded(child: _buildPriceWidget(game)),

          const SizedBox(width: 12),

          // Nút — ưu tiên: In Library > In Cart > Add to Cart
          if (isCheckingOwnership)
            const SizedBox(
              width: 160,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF66C0F4),
                  ),
                ),
              ),
            )
          else if (isOwned)
            _buildInLibraryButton()
          else
            _buildCartButton(game, isInCart),
        ],
      ),
    );
  }

  Widget _buildPriceWidget(GameDetailModel game) {
    if (game.price <= 0) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('FREE TO PLAY',
              style: TextStyle(
                  color: Color(0xFFBEEE11),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      );
    }

    if (game.isOnSale) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C6B22),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '-${game.discountPercent}%',
                  style: const TextStyle(
                      color: Color(0xFFBEEE11),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${game.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '\$${game.displayPrice.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return Text(
      '\$${game.price.toStringAsFixed(2)}',
      style: const TextStyle(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  /// Nút "In Library" — hiển thị khi user đã sở hữu game.
  Widget _buildInLibraryButton() {
    return SizedBox(
      width: 160,
      child: OutlinedButton.icon(
        onPressed: () => context.go('/library'),
        icon: const Icon(Icons.check_circle_outline,
            size: 16, color: Color(0xFFBEEE11)),
        label: const Text(
          'In Library',
          style: TextStyle(
            color: Color(0xFFBEEE11),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFBEEE11)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildCartButton(GameDetailModel game, bool isInCart) {
    if (isInCart) {
      return SizedBox(
        width: 160,
        child: OutlinedButton.icon(
          onPressed: () => context.go('/cart'),
          icon: const Icon(Icons.check, size: 16, color: Color(0xFF66C0F4)),
          label: const Text('In Cart',
              style: TextStyle(color: Color(0xFF66C0F4), fontSize: 13)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF66C0F4)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4)),
          ),
        ),
      );
    }

    return SizedBox(
      width: 160,
      child: ElevatedButton.icon(
        onPressed: _addingToCart ? null : () => _handleAddToCart(game),
        icon: _addingToCart
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.add_shopping_cart, size: 16),
        label: Text(_addingToCart ? 'Adding...' : 'Add to Cart',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C6B22),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF2A3F15),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Future<void> _handleAddToCart(GameDetailModel game) async {
    setState(() => _addingToCart = true);
    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.addToCart(game.id);
    if (mounted) {
      setState(() => _addingToCart = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${game.title} added to cart!'),
            backgroundColor: const Color(0xFF4C6B22),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'VIEW CART',
              textColor: const Color(0xFFBEEE11),
              onPressed: () => context.go('/cart'),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cartProvider.errorMessage ?? 'Failed to add to cart.'),
            backgroundColor: const Color(0xFF8B0000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── INFO ROW ────────────────────────────────────────────────────────────────

  Widget _buildInfoRow(GameDetailModel game) {
    final entries = <_InfoEntry>[];
    if (game.developer != null) {
      entries.add(_InfoEntry('Developer', game.developer!));
    }
    if (game.publisher != null) {
      entries.add(_InfoEntry('Publisher', game.publisher!));
    }
    if (game.releaseDate != null) {
      entries.add(_InfoEntry('Release Date', game.releaseDate!));
    }
    if (entries.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 24,
      runSpacing: 8,
      children: entries
          .map((e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.label,
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(e.value,
                      style: const TextStyle(
                          color: Color(0xFF66C0F4), fontSize: 13)),
                ],
              ))
          .toList(),
    );
  }

  // ── SCREENSHOTS ─────────────────────────────────────────────────────────────

  Widget _buildScreenshots(List<String> urls) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedNetworkImage(
            imageUrl: urls[index],
            width: 220,
            height: 140,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              width: 220,
              color: const Color(0xFF16202D),
              child: const Icon(Icons.image_not_supported,
                  color: Color(0xFF2A475E)),
            ),
          ),
        ),
      ),
    );
  }

  // ── TAGS ────────────────────────────────────────────────────────────────────

  Widget _buildTags(GameDetailModel game) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: game.tags
          .map((tag) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A475E),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(tag.tagName,
                    style: const TextStyle(
                        color: Color(0xFFACDBF5), fontSize: 12)),
              ))
          .toList(),
    );
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _InfoEntry {
  final String label;
  final String value;
  _InfoEntry(this.label, this.value);
}
