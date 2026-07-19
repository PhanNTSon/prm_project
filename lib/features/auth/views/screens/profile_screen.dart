import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/providers/wallet_provider.dart';
import '../../../profile/providers/notification_provider.dart';
import '../../models/profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_menu_item.dart';
import '../../../cart_payment/providers/payment_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // null = xem profile của chính mình

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileRepository _profileRepository;

  ProfileModel? _profile;
  bool _isLoading = true;
  bool? _isOwnProfileCached;
  bool get _isOwnProfile => _isOwnProfileCached ?? true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepository(
      DioClient(AppRouter.rootNavigatorKey),
    );
    // Tính _isOwnProfile 1 lần duy nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      setState(() {
        _isOwnProfileCached =
            widget.userId == null ||
            authProvider.currentUser?.userId == widget.userId;
      });
      _loadProfile();
    });
  }

  String? get _targetUserId {
    if (widget.userId != null) return widget.userId;
    final uid = context.read<AuthProvider>().currentUser?.userId;
    if (uid == null || uid.isEmpty) return null;
    return uid;
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ← Kiểm tra userId hợp lệ trước
    final userId = _targetUserId;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _errorMessage = 'Không xác định được người dùng.';
        _isLoading = false;
      });
      return;
    }

    try {
      final profile = await _profileRepository.getUserProfile(userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
      if (mounted) {
        await context.read<PaymentProvider>().loadBalance();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải thông tin profile.';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: const Text(
          'Đăng xuất',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
        content: const Text(
          'Bạn có chắc muốn đăng xuất không?',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Huỷ',
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      // Router tự redirect về /login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF171A21),
      title: Text(
        _isOwnProfile ? 'Trang cá nhân' : 'Hồ sơ người dùng',
        style: const TextStyle(color: AppColors.primaryTextColor),
      ),
      actions: _isOwnProfile
          ? [_buildNotificationBadge(), const SizedBox(width: 8)]
          : null,
    );
  }

  Widget _buildNotificationBadge() {
    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, _) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primaryTextColor,
              ),
              onPressed: () {
                // TODO: Chuyển sang màn hình Notifications
              },
            ),
            if (notifProvider.unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.errorColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    notifProvider.unreadCount > 99
                        ? '99+'
                        : '${notifProvider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.secondaryTextColor),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadProfile,
              child: const Text(
                'Thử lại',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      );
    }

    if (_profile == null) return const SizedBox.shrink();

    // ← Chỉ còn 1 return duy nhất, không còn block debug
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 12),
            if (_isOwnProfile) _buildWalletCard(),
            const SizedBox(height: 12),
            _buildStatsRow(),
            const SizedBox(height: 12),
            if (_profile!.summary?.isNotEmpty == true) _buildBioSection(),
            const SizedBox(height: 12),
            _buildMenuSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      color: AppColors.surfaceColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatar(
            avatarUrl: _profile!.avatarUrl,
            username: _profile!.username,
            radius: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _profile!.displayName,
            style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_profile!.username != _profile!.displayName) ...[
            const SizedBox(height: 4),
            Text(
              '@${_profile!.username}',
              style: const TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 13,
              ),
            ),
          ],
          if (_profile!.country?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.secondaryTextColor,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _profile!.country!,
                  style: const TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _buildRoleBadge(_profile!.role),
          if (_isOwnProfile) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final updated = await context.push(
                  '/account/edit',
                  extra: _profile,
                );
                if (updated is ProfileModel && mounted) {
                  setState(() => _profile = updated);
                }
              },
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primaryColor,
                size: 16,
              ),
              label: const Text(
                'Chỉnh sửa hồ sơ',
                style: TextStyle(color: AppColors.primaryColor),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final label = switch (role) {
      'ROLE_ADMIN' => 'Admin',
      'ROLE_PUBLISHER' => 'Publisher',
      _ => 'Người dùng',
    };
    final color = switch (role) {
      'ROLE_ADMIN' => AppColors.errorColor,
      'ROLE_PUBLISHER' => AppColors.warningColor,
      _ => AppColors.secondaryColor,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      // ← Thêm constraints rõ ràng cho Row
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildStatItem('Game', '${_profile!.totalGames}'),
            _buildStatDivider(),
            _buildStatItem('Đánh giá', '${_profile!.reviewCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      // ← Giữ Expanded nhưng Row giờ đã có SizedBox bao ngoài
      child: Column(
        mainAxisSize: MainAxisSize.min, // ← thêm dòng này
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 32, width: 1, color: AppColors.borderColor);
  }

  Widget _buildBioSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GIỚI THIỆU',
            style: TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _profile!.summary!,
            style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Số dư ví',
                  style: TextStyle(
                    color: AppColors.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                Consumer<PaymentProvider>(
                  // ← đổi sang PaymentProvider
                  builder: (context, paymentProvider, _) =>
                      paymentProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        )
                      : Text(
                          '\$${paymentProvider.balance.toStringAsFixed(2)}', // ← USD theo Dev C
                          style: const TextStyle(
                            color: AppColors.primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => context.push('/account/wallet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.backgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Nạp tiền'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isOwnProfile) ...[
            _buildSectionHeader('Tài khoản'),
            ProfileMenuItem(
              icon: Icons.manage_accounts_outlined,
              title: 'Thông tin tài khoản',
              subtitle: 'Email, mật khẩu, bảo mật',
              onTap: () => context.push('/account'),
            ),
            ProfileMenuItem(
              icon: Icons.gamepad_outlined,
              title: 'Thư viện game',
              subtitle: 'Danh sách game đã sở hữu',
              onTap: () => context.go('/library'),
            ),
            ProfileMenuItem(
              icon: Icons.history,
              title: 'Lịch sử giao dịch',
              subtitle: 'Xem các giao dịch đã thực hiện',
              onTap: () {
                // TODO: context.push('/account/history') khi Dev C làm xong
              },
            ),
            _buildSectionHeader('Khác'),
            ProfileMenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              iconColor: AppColors.errorColor,
              trailing: const SizedBox.shrink(),
              onTap: _handleLogout,
            ),
          ] else ...[
            _buildSectionHeader('Thư viện'),
            ProfileMenuItem(
              icon: Icons.gamepad_outlined,
              title: 'Xem thư viện game',
              trailing: const SizedBox.shrink(),
              onTap: () {},
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.secondaryTextColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
