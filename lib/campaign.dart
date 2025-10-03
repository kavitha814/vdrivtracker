import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class CampaignDashboard extends StatefulWidget {
  @override
  _CampaignDashboardState createState() => _CampaignDashboardState();
}

class _CampaignDashboardState extends State<CampaignDashboard> {
  bool _isSwitchOn = false;
  Timer? _locationTimer;

  /// Mocked driver details
  String driverName = "Kavitha"; 
  String driverId = "DRV101";  

  Future<void> _sendLocationToServer(Position position) async {
    final url = Uri.parse("https://yourserver.com/api/location");

    final body = {
      "driver_id": driverId,
      "latitude": position.latitude,
      "longitude": position.longitude,
      "timestamp": DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Location sent: $body");
      } else {
        print("Server error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("Failed to send location: $e");
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _sendLocationToServer(position);
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
    print("Location sharing stopped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: Text(
          'VDriv',
          style: GoogleFonts.ibmPlexSansKr(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👇 Driver info
            Text(
              "Hello, $driverName 👋",
              style: GoogleFonts.ibmPlexSansKr(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Driver ID: $driverId",
              style: GoogleFonts.ibmPlexSansKr(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // 👇 Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Share Location",
                  style: GoogleFonts.ibmPlexSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: _isSwitchOn,
                    onChanged: (bool value) {
                      setState(() {
                        _isSwitchOn = value;
                      });

                      if (value) {
                        print("Location sharing started");
                        _startLocationUpdates();
                      } else {
                        _stopLocationUpdates();
                      }
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    activeColor: Colors.transparent,
                    activeTrackColor: const Color(0xff000000),
                    inactiveTrackColor:
                        const Color.fromARGB(255, 201, 200, 200),
                    thumbColor:
                        const WidgetStatePropertyAll<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
