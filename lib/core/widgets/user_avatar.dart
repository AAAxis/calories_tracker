import 'package:flutter/material.dart';
import 'package:calories_tracker/core/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  
  const UserAvatar({
    super.key,
    this.size = 40.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'U';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: user != null 
              ? StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    String? photoURL = user.photoURL;
                    
                    // Get the latest photoURL from Firestore if available
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null && data['photoURL'] != null) {
                        photoURL = data['photoURL'];
                      }
                    }
                    
                    return photoURL != null && photoURL.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: photoURL,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _buildPlaceholder(displayName),
                            errorWidget: (context, url, error) => _buildPlaceholder(displayName),
                          )
                        : _buildPlaceholder(displayName);
                  },
                )
              : _buildPlaceholder(displayName),
        ),
      ),
    );
  }
  
  Widget _buildPlaceholder(String displayName) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.grey[600],
      ),
    );
  }
} 