/* 
Student Numbers: 223046876, 223000460, 223050336, 223040081, 224000274, 224027806
Student Names: Lehlogonolo Moshoeu, Asanda Sithole, Sandile Pheko, Mvelo Masinga, Mponisi Nkuna, Cedric Motone
Questions: StorageService class handles all interactions with Supabase Storage, including uploading documents and profile pictures.
*/ 

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../config/supabase_config.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // For mobile/desktop: User upload using XFile
  Future<String?> uploadDocument(String userId, String documentType, XFile file) async {
    try {
      debugPrint('========== UPLOADING $documentType ==========');
      debugPrint('User ID: $userId');
      
      final fileExt = file.name.split('.').last;
      final fileName = '$userId/$documentType/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      final bytes = await file.readAsBytes();
      
      await _supabase.storage
          .from(SupabaseConfig.documentsBucket)
          .uploadBinary(fileName, bytes);

      final publicUrl = _supabase.storage
          .from(SupabaseConfig.documentsBucket)
          .getPublicUrl(fileName);
      
      debugPrint('✅ Upload successful!');
      debugPrint('📎 Public URL: $publicUrl');
      
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }
// In uploadDocumentBytes method, use the actual userId:

Future<String?> uploadDocumentBytes(
  String userId, 
  String documentType, 
  Uint8List bytes, 
  String fileName
) async {
  try {
    debugPrint('========== UPLOADING $documentType (Web) ==========');
    debugPrint('User ID: $userId');
    
    if (userId == 'unknown' || userId.isEmpty) {
      debugPrint('❌ Invalid user ID! Cannot upload without valid user ID');
      return null;
    }
    
    final fileExt = fileName.split('.').last;
    final storageFileName = '$userId/$documentType/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    
    await _supabase.storage
        .from(SupabaseConfig.documentsBucket)
        .uploadBinary(storageFileName, bytes);

    final publicUrl = _supabase.storage
        .from(SupabaseConfig.documentsBucket)
        .getPublicUrl(storageFileName);
    
    debugPrint('✅ Upload successful!');
    debugPrint('📎 Public URL: $publicUrl');
    
    return publicUrl;
  } catch (e) {
    debugPrint('❌ Upload error: $e');
    return null;
  }
}
  // Upload profile picture (works on web and mobile)
  Future<String?> uploadProfilePicture(String userId, XFile imageFile) async {
    try {
      final fileExt = imageFile.name.split('.').last;
      final fileName = '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      final bytes = await imageFile.readAsBytes();
      
      await _supabase.storage
          .from(SupabaseConfig.profilesBucket)
          .uploadBinary(fileName, bytes);

      final publicUrl = _supabase.storage
          .from(SupabaseConfig.profilesBucket)
          .getPublicUrl(fileName);
      
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Profile upload error: $e');
      return null;
    }
  }

  // Upload profile picture from bytes (for web)
  Future<String?> uploadProfilePictureBytes(
    String userId, 
    Uint8List bytes, 
    String fileName
  ) async {
    try {
      final fileExt = fileName.split('.').last;
      final storageFileName = '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      await _supabase.storage
          .from(SupabaseConfig.profilesBucket)
          .uploadBinary(storageFileName, bytes);

      final publicUrl = _supabase.storage
          .from(SupabaseConfig.profilesBucket)
          .getPublicUrl(storageFileName);
      
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Profile upload error: $e');
      return null;
    }
  }

  // Pick image from gallery or camera (works on web and mobile)
  static Future<XFile?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      return await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
    } catch (e) {
      debugPrint('❌ Image picker error: $e');
      return null;
    }
  }
}