import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:prm_project/features/storefront/providers/game_list_provider.dart';

/// AppBar 2 dòng theo phong cách Steam:
///   Dòng 1: Logo | Search bar (chiếm toàn bộ chiều rộng còn lại) | Cart | Avatar
///   Dòng 2: Nav links (STORE, LIBRARY, ALL GAMES) | Wallet link
class HomeAppbar extends StatelessWidget {
  final String currentPage;

  const HomeAppbar({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF171A21),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dòng 1: Logo + Search + Actions ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                // Logo
                _buildLogo(),

                const SizedBox(width: 16),

                // Search bar – chiếm toàn bộ phần còn lại
                Expanded(child: _SearchBar()),

                const SizedBox(width: 8),

                // Notification
                _iconBtn(Icons.notifications_none_rounded, () {}),

                // Cart
                _iconBtn(Icons.shopping_cart_outlined, () => context.go('/cart')),

                const SizedBox(width: 4),

                // Avatar
                const _AvatarChip(),
              ],
            ),
          ),

          // Divider mỏng
          const Divider(height: 1, thickness: 1, color: Color(0xFF2A475E)),

          // ── Dòng 2: Nav links + Wallet ────────────────────────────────────
          SizedBox(
            height: 36,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _NavLink(
                    title: 'STORE',
                    isSelected: currentPage == 'store',
                    onTap: () {},
                  ),
                  _NavLink(
                    title: 'LIBRARY',
                    isSelected: currentPage == 'library',
                    onTap: () => context.push('/library'),
                  ),
                  _NavLink(
                    title: 'ALL GAMES',
                    isSelected: currentPage == 'all-games',
                    onTap: () {
                      context.read<GameListProvider>().setFilter(tagId: null, categoryName: null);
                      context.push('/all-games');
                    },
                  ),

                  const Spacer(),

                  // Wallet text link
                  _WalletLink(onTap: () => context.push('/account/wallet')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.sports_esports, color: Color(0xFF66C0F4), size: 28),
        SizedBox(width: 6),
        Text(
          'MEME',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 22),
      onPressed: onTap,
      splashRadius: 20,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }
}

// ─── Search Bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: AbsorbPointer(
        child: TextField(
          readOnly: true,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search games...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white38,
              size: 20,
            ),
            filled: true,
            fillColor: const Color(0xFF2A3F52),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF3D6680), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF66C0F4), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar chip ─────────────────────────────────────────────────────────────

class _AvatarChip extends StatelessWidget {
  const _AvatarChip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFF2A475E),
          child: Icon(Icons.person, size: 16, color: Colors.white70),
        ),
      ],
    );
  }
}

// ─── Nav Link ────────────────────────────────────────────────────────────────

class _NavLink extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavLink({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF66C0F4) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF66C0F4) : Colors.white54,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Wallet Link ─────────────────────────────────────────────────────────────

class _WalletLink extends StatelessWidget {
  final VoidCallback onTap;

  const _WalletLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFFBEEE11), size: 14),
            SizedBox(width: 4),
            Text(
              'WALLET',
              style: TextStyle(
                color: Color(0xFFBEEE11),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SteamNavButton kept for backward-compat (if used elsewhere) ──────────────

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
    return _NavLink(title: title, isSelected: isSelected, onTap: onTap);
  }
}
