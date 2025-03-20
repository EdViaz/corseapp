import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageService {
  // Base URL for the PHP API
  static final String baseUrl = 'http://localhost/backend/api';
  
  // Method to get the correct image URL based on platform
  static String getProxyImageUrl(String originalUrl, {required int width}) {
    // Only use proxy for web platform
    if (kIsWeb) {
      // Encode the URL to make it safe for query parameters
      final encodedUrl = Uri.encodeComponent(originalUrl);
      return '$baseUrl/image_proxy.php?url=$encodedUrl';
    }
    
    // For mobile platforms, return the original URL
    return originalUrl;
  }
}