import 'package:flutter/foundation.dart' show kIsWeb;

class ImageService {
  // Base URL for the PHP API
  static final String baseUrl = 'http://localhost:80/api';

  // Tipi di media supportati
  static const String TYPE_IMAGE = 'image';
  static const String TYPE_VIDEO = 'video';
  static const String TYPE_GALLERY = 'gallery';

  // Dimensioni predefinite per le immagini
  static const int THUMBNAIL_SIZE = 150;
  static const int MEDIUM_SIZE = 400;
  static const int LARGE_SIZE = 800;
  static const int FULL_SIZE = 1200;

  // Method to get the correct image URL based on platform
  static String getProxyImageUrl(String originalUrl, {required int width}) {
    // Usa sempre l'URL originale, anche su web
    return originalUrl;
  }

  // Ottieni URL per thumbnail
  static String getThumbnailUrl(String originalUrl) {
    return getProxyImageUrl(originalUrl, width: THUMBNAIL_SIZE);
  }

  // Ottieni URL per immagine media
  static String getMediumImageUrl(String originalUrl) {
    return getProxyImageUrl(originalUrl, width: MEDIUM_SIZE);
  }

  // Ottieni URL per immagine grande
  static String getLargeImageUrl(String originalUrl) {
    return getProxyImageUrl(originalUrl, width: LARGE_SIZE);
  }

  // Ottieni URL per immagine a dimensione piena
  static String getFullSizeImageUrl(String originalUrl) {
    return getProxyImageUrl(originalUrl, width: FULL_SIZE);
  }

  // Determina se l'URL è un'immagine
  static bool isImageUrl(String url) {
    final lowercaseUrl = url.toLowerCase();
    return lowercaseUrl.endsWith('.jpg') ||
        lowercaseUrl.endsWith('.jpeg') ||
        lowercaseUrl.endsWith('.png') ||
        lowercaseUrl.endsWith('.gif') ||
        lowercaseUrl.endsWith('.webp');
  }

  // Determina se l'URL è un video
  static bool isVideoUrl(String url) {
    final lowercaseUrl = url.toLowerCase();
    return lowercaseUrl.endsWith('.mp4') ||
        lowercaseUrl.endsWith('.webm') ||
        lowercaseUrl.endsWith('.ogg') ||
        lowercaseUrl.contains('youtube.com') ||
        lowercaseUrl.contains('youtu.be');
  }

  // Ottieni il tipo di media dall'URL
  static String getMediaType(String url) {
    if (isImageUrl(url)) return TYPE_IMAGE;
    if (isVideoUrl(url)) return TYPE_VIDEO;
    return TYPE_IMAGE; // Default a immagine
  }
}
