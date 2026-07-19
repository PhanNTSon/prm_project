import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../repositories/auth_repository.dart';
import '../widgets/auth_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpCode =>
      _otpControllers.map((c) => c.text).join();

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _handleReset() async {
    if (_otpCode.length < 6) {
      setState(() => _errorMessage = 'Vui lòng nhập đủ 6 chữ số OTP');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.resetPassword(
        email: widget.email,
        otp: _otpCode,
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.'),
          backgroundColor: AppColors.successColor,
        ),
      );
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Mã OTP không hợp lệ hoặc đã hết hạn.';
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
                  _buildOtpSection(),
                  const SizedBox(height: 24),
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
          'ĐẶT LẠI MẬT KHẨU',
          style: TextStyle(
            color: AppColors.primaryTextColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.secondaryTextColor,
              fontSize: 14,
            ),
            children: [
              const TextSpan(text: 'Nhập mã OTP đã gửi đến\n'),
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mã OTP',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOtpBox(index)),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          color: AppColors.primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.inputFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: AppColors.primaryColor),
          ),
        ),
        onChanged: (value) => _onOtpChanged(value, index),
      ),
    );
  }

  Widget _buildPasswordField() {
    return AuthTextField(
      // TODO: Thay bằng CustomTextField của Dev D
      controller: _passwordController,
      label: 'Mật khẩu mới',
      hint: 'Nhập mật khẩu mới',
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
        if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu mới';
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
      label: 'Xác nhận mật khẩu mới',
      hint: 'Nhập lại mật khẩu mới',
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
      onPressed: _isLoading ? null : _handleReset,
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
              'Xác nhận',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}