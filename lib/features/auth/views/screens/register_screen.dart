import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/auth_repository.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();

  bool _isLoading = false;
  bool _agreedToTerms = false;
  String _selectedCountry = 'Việt Nam';
  String? _errorMessage;

  late final AuthRepository _authRepository;

  final List<String> _countries = [
    'Việt Nam', 'Hoa Kỳ', 'Nhật Bản',
    'Hàn Quốc', 'Trung Quốc', 'Anh',
    'Pháp', 'Đức', 'Úc', 'Canada',
  ];

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository(
      DioClient(AppRouter.rootNavigatorKey),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepository.register(
        _emailController.text.trim(),
        _selectedCountry,
      );

      if (!mounted) return;

      // Chuyển sang màn hình OTP, truyền email qua extra
      context.push('/verify-email', extra: _emailController.text.trim());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Đăng ký thất bại. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildConfirmEmailField(),
                  const SizedBox(height: 16),
                  _buildCountryDropdown(),
                  const SizedBox(height: 24),
                  _buildCaptchaPlaceholder(),
                  const SizedBox(height: 16),
                  _buildTermsCheckbox(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorMessage(),
                  ],
                  const SizedBox(height: 24),
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
    return Text(
      'TẠO TÀI KHOẢN CỦA BẠN',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildEmailField() {
    return AuthTextField(
      // TODO: Thay bằng CustomTextField của Dev D
      controller: _emailController,
      label: 'Địa chỉ email',
      hint: '',
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng nhập email';
        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmEmailField() {
    return AuthTextField(
      // TODO: Thay bằng CustomTextField của Dev D
      controller: _confirmEmailController,
      label: 'Xác nhận địa chỉ email của bạn',
      hint: '',
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Vui lòng xác nhận email';
        if (value != _emailController.text) return 'Email không khớp';
        return null;
      },
    );
  }

  Widget _buildCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quốc gia cư trú',
          style: TextStyle(color: AppColors.secondaryTextColor),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          dropdownColor: AppColors.surfaceColor,
          style: const TextStyle(color: AppColors.primaryTextColor),
          decoration: InputDecoration(
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: _countries
              .map((country) => DropdownMenuItem(
                    value: country,
                    child: Text(country),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedCountry = value);
          },
        ),
      ],
    );
  }

  Widget _buildCaptchaPlaceholder() {
    // TODO: Tích hợp hCaptcha thực tế nếu có package
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputFillColor,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (_) {},
            fillColor: WidgetStateProperty.all(AppColors.surfaceColor),
          ),
          const SizedBox(width: 8),
          const Text(
            'Tôi là con người',
            style: TextStyle(color: AppColors.primaryTextColor),
          ),
          const Spacer(),
          Column(
            children: [
              const Icon(Icons.back_hand_outlined,
                  color: AppColors.primaryColor),
              const Text(
                'hCaptcha',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (value) =>
              setState(() => _agreedToTerms = value ?? false),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryColor;
            }
            return AppColors.surfaceColor;
          }),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(text: 'Tôi 13 tuổi hoặc lớn hơn và đồng ý với điều khoản trong '),
                  TextSpan(
                    text: 'Thỏa thuận người đăng ký Steam',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' và '),
                  TextSpan(
                    text: 'Chính sách bảo mật của Valve',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
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
      onPressed: _isLoading ? null : _handleRegister,
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
              'Tiếp tục',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}