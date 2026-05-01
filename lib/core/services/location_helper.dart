import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationHelper {
  /// Request permission, get current position, and reverse-geocode to city name.
  /// Returns a record of (latitude, longitude, cityName) or null on failure.
  static Future<({double lat, double lng, String name})?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to open location settings on Android
        await Geolocator.openLocationSettings();
        // Re-check after user returns
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          Get.snackbar(
            'الموقع غير مفعّل',
            'يرجى تفعيل خدمات الموقع ثم حاول مرة أخرى',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade50,
            colorText: Colors.orange.shade800,
          );
          return null;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'الإذن مرفوض',
            'يرجى السماح بالوصول للموقع',
            snackPosition: SnackPosition.BOTTOM,
          );
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        Get.snackbar(
          'الإذن مرفوض نهائياً',
          'يرجى تفعيل إذن الموقع من إعدادات التطبيق',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      // Try high accuracy first with a timeout, fall back to low accuracy
      Position pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        // High accuracy timed out — try with low accuracy
        try {
          pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
          ).timeout(const Duration(seconds: 10));
        } catch (_) {
          // Last resort: try last known position
          final Position? lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos == null) {
            Get.snackbar(
              'خطأ',
              'تعذر الحصول على الموقع. تأكد من تفعيل GPS وحاول مرة أخرى',
              snackPosition: SnackPosition.BOTTOM,
            );
            return null;
          }
          pos = lastPos;
        }
      }

      String cityName = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      try {
        final List<Placemark> placemarks =
            await placemarkFromCoordinates(pos.latitude, pos.longitude)
                .timeout(const Duration(seconds: 5));
        if (placemarks.isNotEmpty) {
          final Placemark p = placemarks.first;
          final List<String> parts = <String>[
            if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
            if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty)
              p.administrativeArea!,
            if (p.country != null && p.country!.isNotEmpty) p.country!,
          ];
          if (parts.isNotEmpty) cityName = parts.join('، ');
        }
      } catch (_) {
        // Geocoding failed, use coordinates
      }

      return (lat: pos.latitude, lng: pos.longitude, name: cityName);
    } catch (e) {
      debugPrint('LocationHelper error: $e');
      Get.snackbar(
        'خطأ',
        'تعذر الحصول على الموقع الحالي. حاول مرة أخرى',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}

