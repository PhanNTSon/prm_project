import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _profileNameController;
  late final TextEditingController _summaryController;

  static const List<String> _countries = [
    'Việt Nam', 'Hoa Kỳ', 'Nhật Bản',
    'Hàn Quốc', 'Trung Quốc', 'Anh',
    'Pháp', 'Đức', 'Úc', 'Canada',
  ];
  static const List<String> _genders = ['Nam', 'Nữ', 'Khác'];

  late String _selectedCountry;
  late String _selectedGender;
  DateTime? _selectedDob;

  late final ProfileRepository _profileRepository;

  bool _isSaving = false;
  bool _savedSuccessfully = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepository(
      DioClient(AppRouter.rootNavigatorKey),
    );

    _profileNameController =
        TextEditingController(text: widget.profile.displayName);
    _summaryController = TextEditingController(text: widget.profile.summary ?? '');

    _selectedCountry = _countries.contains(widget.profile.country)
        ? widget.profile.country!
        : _countries.first;
    _selectedGender = _genders.contains(widget.profile.gender)
        ? widget.profile.gender!
        : _genders.first;
    _selectedDob = _parseDob(widget.profile.dob);
  }

  DateTime? _parseDob(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    return DateTime.tryParse(dob);
  }

  @override
  void dispose() {
    _profileNameController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now, // Không cho chọn ngày trong tương lai (E2 trong RDS)
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryColor,
              surface: AppColors.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDob = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      setState(() => _errorMessage = 'Vui lòng chọn ngày sinh');
      return;
    }
    if (_selectedDob!.isAfter(DateTime.now())) {
      setState(() => _errorMessage = 'Ngày sinh không được ở tương lai');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _savedSuccessfully = false;
    });

    try {
      final userId = context.read<AuthProvider>().currentUser?.userId ?? '';
      final dobString =
          '${_selectedDob!.year.toString().padLeft(4, '0')}-'
          '${_selectedDob!.month.toString().padLeft(2, '0')}-'
          '${_selectedDob!.day.toString().padLeft(2, '0')}';

      final updated = await _profileRepository.updateProfile(
        userId: userId,
        profileName: _profileNameController.text.trim(),
        country: _selectedCountry,
        gender: _selectedGender,
        dob: dobString,
        summary: _summaryController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _savedSuccessfully = true;
      });
      // Trả profile mới về cho AccountDetailScreen để cập nhật lại UI
      context.pop(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Cập nhật hồ sơ thất bại. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(color: AppColors.primaryTextColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 24),
                _buildProfileNameField(),
                const SizedBox(height: 16),
                _buildCountryDropdown(),
                const SizedBox(height: 16),
                _buildGenderDropdown(),
                const SizedBox(height: 16),
                _buildDobPicker(),
                const SizedBox(height: 16),
                _buildSummaryField(),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.errorColor, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSaveRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          ProfileAvatar(
            avatarUrl: widget.profile.avatarUrl,
            username: widget.profile.username,
            radius: 48,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng tải ảnh đại diện sẽ được bổ sung sau'),
                ),
              );
            },
            child: const Text('Tải ảnh lên',
                style: TextStyle(color: AppColors.primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileNameField() {
    return AuthTextField(
      controller: _profileNameController,
      label: 'Tên hiển thị',
      hint: 'Tên hiển thị với người dùng khác',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Tên hiển thị không được để trống';
        }
        return null;
      },
    );
  }

  Widget _buildCountryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCountry,
      dropdownColor: AppColors.cardColor,
      style: const TextStyle(color: AppColors.primaryTextColor),
      decoration: const InputDecoration(
        labelText: 'Quốc gia',
        labelStyle: TextStyle(color: AppColors.secondaryTextColor),
      ),
      items: _countries
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedCountry = value);
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      dropdownColor: AppColors.cardColor,
      style: const TextStyle(color: AppColors.primaryTextColor),
      decoration: const InputDecoration(
        labelText: 'Giới tính',
        labelStyle: TextStyle(color: AppColors.secondaryTextColor),
      ),
      items: _genders
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _selectedGender = value);
      },
    );
  }

  Widget _buildDobPicker() {
    final label = _selectedDob == null
        ? 'Chọn ngày sinh'
        : '${_selectedDob!.day.toString().padLeft(2, '0')}/'
            '${_selectedDob!.month.toString().padLeft(2, '0')}/'
            '${_selectedDob!.year}';

    return InkWell(
      onTap: _pickDob,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ngày sinh',
          labelStyle: TextStyle(color: AppColors.secondaryTextColor),
          suffixIcon: Icon(Icons.calendar_today,
              color: AppColors.secondaryTextColor, size: 18),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.primaryTextColor),
        ),
      ),
    );
  }

  Widget _buildSummaryField() {
    return AuthTextField(
      controller: _summaryController,
      label: 'Giới thiệu bản thân',
      hint: 'Cho người khác biết một chút về bạn',
    );
  }

  Widget _buildSaveRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.backgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.backgroundColor,
                    ),
                  )
                : const Text('Lưu thay đổi',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        if (_savedSuccessfully) ...[
          const SizedBox(width: 12),
          const Icon(Icons.check_circle, color: AppColors.successColor),
        ],
      ],
    );
  }
}