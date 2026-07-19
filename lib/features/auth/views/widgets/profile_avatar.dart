// TODO: Thay bằng widget của Dev D khi có UI Kit
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.username,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceColor,
        child: ClipOval(
          child: CachedNetworkImage(
            // BẮT BUỘC dùng cached_network_image theo quy tắc chung
            imageUrl: avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            // Trên Web, ảnh cross-origin (vd CDN ngoài) có thể làm crash
            // CanvasKit renderer do lỗi "tainted canvas" (CORS). Render
            // bằng thẻ <img> HTML thay vì vẽ qua canvas để tránh lỗi này.
            // (Tham số này được package tự bỏ qua trên các nền tảng khác Web.)
            imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
            placeholder: (context, url) => SizedBox(
              width: radius,
              height: radius,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
            errorWidget: (context, url, error) => _buildFallback(),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceColor,
      child: _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Text(
      username.isNotEmpty ? username[0].toUpperCase() : '?',
      style: TextStyle(
        color: AppColors.primaryColor,
        fontSize: radius * 0.8,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}