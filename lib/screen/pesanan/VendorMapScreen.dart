import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:damping/screen/pesanan/component/chat_screen.dart';

class VendorMapScreen extends StatelessWidget {
  final LatLng vendorPosition;
  final LatLng currentPosition;

  const VendorMapScreen({
    super.key,
    required this.vendorPosition,
    required this.currentPosition,
  });

  // Fungsi untuk menghitung jarak total dari polyline
  double calculatePolylineDistance(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  @override
  Widget build(BuildContext context) {
    final MapController mapController = MapController();

    List<LatLng> polylinePoints = [currentPosition, vendorPosition];

    double totalDistance = calculatePolylineDistance(polylinePoints);
    double distanceInKilometers = totalDistance / 1000;
    double speedKmh = 30;
    double estimatedTime =
        (distanceInKilometers / speedKmh) * 60; // Waktu estimasi dalam menit
    String estimatedTimeText = estimatedTime > 10
        ? "${estimatedTime.round()} minutes"
        : "Less than 5 minutes";

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(
                (vendorPosition.latitude + currentPosition.latitude) / 2,
                (vendorPosition.longitude + currentPosition.longitude) / 2,
              ),
              zoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition,
                    builder: (ctx) => const Icon(Icons.location_on,
                        color: Colors.yellow, size: 40),
                  ),
                  Marker(
                    point: vendorPosition,
                    builder: (ctx) => const Icon(Icons.motorcycle,
                        color: Colors.green, size: 40),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    strokeWidth: 4.0,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pedal_bike_sharp, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    "Waiting for vendor to reach location...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.pedal_bike_sharp,
                                color: Colors.green, size: 30),
                            SizedBox(width: 8),
                            Text(
                              "Vendor is on the way to you",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Estimated Arrival",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            Text(
                              estimatedTimeText,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: 0.5,
                          backgroundColor: Colors.grey[300],
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Order Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text("Cancel Order"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Add space between buttons
                    // Chat Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Show the chat screen in a bottom sheet
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) =>
                                const ChatScreen(), // Use the new ChatScreen widget
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text("Chat"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
