import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../repositories/auth_repository.dart';
import '../widgets/auth_text_field.dart';

class RegisterDetailsScreen extends StatefulWidget {
  final String email;

  const RegisterDetailsScreen({super.key, required this.email});

  @override
  State<RegisterDetailsScreen> createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      DioClient(AppRouter.rootNavigatorKey),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.registerDetails(
        widget.email,
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo tài khoản thành công! Vui lòng đăng nhập.'),
          backgroundColor: AppColors.successColor,
        ),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Thiết lập tài khoản thất bại. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildUsernameField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorMessage(),
                  ],
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THIẾT LẬP TÀI KHOẢN',
          style: TextStyle(
            color: AppColors.primaryTextColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.email,
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return AuthTextField(
      // TODO: Thay bằng CustomTextField của Dev D
      controller: _usernameController,
      label: 'Tên tài khoản',
      hint: 'Nhập tên tài khoản',
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập tên tài khoản';
        if (value.length < 3) return 'Tên tài khoản tối thiểu 3 ký tự';
        if (value.length > 32) return 'Tên tài khoản tối đa 32 ký tự';
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
          return 'Chỉ được dùng chữ cái, số và dấu gạch dưới';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return AuthTextField(
      // TODO: Thay bằng CustomTextField của Dev D
      controller: _passwordController,
      label: 'Mật khẩu',
      hint: 'Nhập mật khẩu',
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.secondaryTextColor,
        ),
        onPressed: () =>
            setState(() => _obscurePassword = !_obscurePassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
        if (value.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
        if (!RegExp(r'^(?=.*[A-Z])(?=.*[0-9])').hasMatch(value)) {
          return 'Mật khẩu phải có ít nhất 1 chữ hoa và 1 số';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return AuthTextField(
      // TODO: Thay bằng CustomTextField của Dev D
      controller: _confirmPasswordController,
      label: 'Xác nhận mật khẩu',
      hint: 'Nhập lại mật khẩu',
      obscureText: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.secondaryTextColor,
        ),
        onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
        if (value != _passwordController.text) return 'Mật khẩu không khớp';
        return null;
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.5)),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: AppColors.errorColor, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubmitButton() {
    // TODO: Thay bằng CustomButton của Dev D
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.backgroundColor,
              ),
            )
          : const Text(
              'Hoàn tất',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}