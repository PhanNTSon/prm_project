import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../models/profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../widgets/profile_avatar.dart';
import '../../../profile/providers/wallet_provider.dart';
import '../../../cart_payment/providers/payment_provider.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({super.key});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  late final ProfileRepository _profileRepository;

  ProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepository(
      DioClient(AppRouter.rootNavigatorKey),
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = context.read<AuthProvider>().currentUser?.userId ?? '';
      final profile = await _profileRepository.getUserProfile(userId);
      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });

      // ← Sync balance từ PaymentProvider để đồng bộ với WalletScreen của Dev C
      if (mounted) {
        await context.read<PaymentProvider>().loadBalance();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể tải thông tin tài khoản.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thông tin tài khoản',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
      ),
      body: _buildBody(),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAvatarSection(),
          const SizedBox(height: 24),
          _buildStoreSection(),
          const SizedBox(height: 16),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          ProfileAvatar(
            avatarUrl: _profile!.avatarUrl,
            username: _profile!.username,
            radius: 52,
          ),
          const SizedBox(height: 8),
          Text(
            _profile!.displayName,
            style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
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
              Icons.edit,
              size: 16,
              color: AppColors.primaryColor,
            ),
            label: const Text(
              'Chỉnh sửa hồ sơ',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection() {
    return _buildCard(
      title: 'CỬA HÀNG & LỊCH SỬ GIAO DỊCH',
      children: [
        _buildWalletRow(),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // TODO: context.push('/account/history') khi Dev C làm xong
          },
          child: const Text(
            'Xem lịch sử giao dịch',
            style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletRow() {
    return Consumer<PaymentProvider>(
      builder: (context, paymentProvider, _) {
        return Row(
          children: [
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
                          '\$${paymentProvider.balance.toStringAsFixed(2)}', // ← theo Dev C: USD
                          style: const TextStyle(
                            color: AppColors.primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text('Nạp tiền'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactSection() {
    return _buildCard(
      title: 'THÔNG TIN LIÊN HỆ',
      children: [
        _buildInfoRow(label: 'Email', value: _profile!.email),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // TODO: context.push('/change-email')
          },
          child: const Text(
            'Quản lý email',
            style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.push('/change-password'),
          child: const Text(
            'Đổi mật khẩu',
            style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.primaryTextColor,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
