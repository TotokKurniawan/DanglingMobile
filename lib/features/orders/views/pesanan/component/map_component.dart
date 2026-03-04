// File: lib/screen/pesanan/component/map_component.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MerchantMap extends StatelessWidget {
  final MapController mapController;
  final LatLng currentPosition;
  final LatLng merchantPosition;

  const MerchantMap({
    Key? key,
    required this.mapController,
    required this.currentPosition,
    required this.merchantPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(
                (currentPosition.latitude + merchantPosition.latitude) / 2,
                (currentPosition.longitude + merchantPosition.longitude) / 2,
              ),
              zoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition,
                    builder: (ctx) => const Icon(
                      Icons.location_on,
                      color: Colors.yellow,
                      size: 30,
                    ),
                  ),
                  // Marker(
                  //   point: merchantPosition,
                  //   builder: (ctx) => CircleAvatar(
                  //     radius: 20, // Ukuran bubble (sesuaikan sesuai kebutuhan)
                  //     backgroundColor: Colors.white,
                  //     child: ClipOval(
                  //       child: Image.network(
                  //         merchantProfileImageUrl, // Gantilah dengan URL atau path foto profil pedagang
                  //         width: 40, // Sesuaikan ukuran gambar
                  //         height: 40,
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Marker(
                    point: merchantPosition,
                    builder: (ctx) => CircleAvatar(
                      radius: 20, // Ukuran bubble
                      backgroundColor: Colors.blueAccent, // Warna bubble
                      child: Icon(
                        Icons.store, // Ikon default
                        color: Colors.white, // Warna ikon
                        size: 24, // Ukuran ikon
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                mapController.move(currentPosition, 14.0);
              },
              tooltip: 'Fokus pada lokasi saya',
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
