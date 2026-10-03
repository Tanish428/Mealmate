import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repos/profile_repo.dart';

/// Cached resolved logo URL across the app session
String? _cachedDynamicLogoUrl;
bool _hasFetchedCachedLogo = false;

/// DynamicIn-App Mess Logo Branding Widget.
///
/// If user is not logged in:
///   Displays 'assets/images/MealMate_logo.png'.
/// If user is logged in:
///   Displays the owner's avatar (for owner) or the joined mess owner's avatar (for member).
///   Falls back to 'assets/images/MealMate_logo.png' if URL is null, empty, or fails to load.
class DynamicMessLogo extends StatefulWidget {
  final double size;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final String? logoUrl;
  final VoidCallback? onTap;

  const DynamicMessLogo({
    super.key,
    this.size = 40.0,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.border,
    this.logoUrl,
    this.onTap,
  });

  /// Invalidate session cache when user updates their profile avatar
  static void invalidateCache() {
    _cachedDynamicLogoUrl = null;
    _hasFetchedCachedLogo = false;
  }

  @override
  State<DynamicMessLogo> createState() => _DynamicMessLogoState();
}

class _DynamicMessLogoState extends State<DynamicMessLogo> {
  String? _resolvedUrl;

  @override
  void initState() {
    super.initState();
    _resolveLogoUrl();
  }

  @override
  void didUpdateWidget(covariant DynamicMessLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logoUrl != oldWidget.logoUrl) {
      _resolveLogoUrl();
    }
  }

  void _resolveLogoUrl() {
    if (widget.logoUrl != null && widget.logoUrl!.trim().isNotEmpty) {
      _resolvedUrl = widget.logoUrl!.trim();
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _resolvedUrl = null;
      return;
    }

    if (_hasFetchedCachedLogo) {
      _resolvedUrl = _cachedDynamicLogoUrl;
      return;
    }

    ProfileRepository().getMemberProfileDetails().then((profile) {
      if (!mounted) return;
      final logo = profile?['mess_logo_url']?.toString() ??
          profile?['avatar_url']?.toString();
      _cachedDynamicLogoUrl = logo;
      _hasFetchedCachedLogo = true;
      setState(() {
        _resolvedUrl = logo;
      });
    }).catchError((_) {});
  }

  Widget _buildFallbackAsset() {
    return Image.asset(
      'assets/images/MealMate_logo.png',
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = widget.shape == BoxShape.circle
        ? BorderRadius.circular(widget.size / 2)
        : (widget.borderRadius ?? BorderRadius.circular(8.0));

    Widget content;
    final url = widget.logoUrl ?? _resolvedUrl;

    if (url != null && url.isNotEmpty) {
      content = Image.network(
        url,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAsset(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: widget.size,
            height: widget.size,
            color: Colors.grey.shade100,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    } else {
      content = _buildFallbackAsset();
    }

    Widget decorated = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: widget.shape,
        borderRadius: widget.shape == BoxShape.circle ? null : effectiveBorderRadius,
        border: widget.border,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: content,
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: decorated,
      );
    }

    return decorated;
  }
}
