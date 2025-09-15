import 'package:enrollease_web/dev.dart';
import 'package:enrollease_web/utils/profile_pic_cache.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePic extends StatefulWidget {
  final double size;
  final Key? profileKey;

  const ProfilePic({this.size = 80, this.profileKey, super.key});

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic>
    with AutomaticKeepAliveClientMixin {
  final _cache = ProfilePicCache();
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePic();
  }

  Future<void> _loadProfilePic() async {
    try {
      await _cache.loadProfilePic(context);
      if (mounted) {
        setState(() {
          _hasError = false;
        });
      }
    } catch (e) {
      dPrint('Error loading profile picture: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void didUpdateWidget(ProfilePic oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only refresh if the profile key changes
    if (oldWidget.profileKey != widget.profileKey) {
      _cache.clearCache();
      _loadProfilePic();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ClipOval(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Container(
          color: Colors.grey.shade100,
          child: _buildProfileImage(),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_cache.isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    if (_hasError) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Center(
          child: FaIcon(
            FontAwesomeIcons.user,
            size: widget.size * 0.4,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: _cache.cachedBytes != null
            ? Image(
                fit: BoxFit.cover,
                image: MemoryImage(_cache.cachedBytes!),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.user,
                        size: widget.size * 0.4,
                        color: Colors.grey[400],
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[200],
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: widget.size * 0.4,
                    color: Colors.grey[400],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
