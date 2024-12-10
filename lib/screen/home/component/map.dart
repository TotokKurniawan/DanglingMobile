import 'dart:async';

import 'package:damping/service/ApiService.dart';
import 'package:damping/service/sharedProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'merchant_card.dart';

class Merchant {
  final String namaProduk;
  final LatLng location;
  final String info;
  final String kategori_produk;
  final String fotoProduk;
  final String fotoPedagang;
  final int hargaProduk;

  Merchant(this.namaProduk, this.location, this.info, this.kategori_produk,
      this.fotoProduk, this.fotoPedagang, this.hargaProduk);
}

class MapSection extends StatefulWidget {
  final Function(Merchant) onMerchantSelected;

  const MapSection({super.key, required this.onMerchantSelected});

  @override
  _MapSectionState createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  late MapController _mapController;
  LatLng? _currentPosition;
  final double _currentZoom = 13.5;
  final double _radius = 2000;

  late ApiService _apiService;
  List<Merchant> _merchants = [];

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isFetching = false;

  // Stream subscription for location updates
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _mapController = MapController();
    _startLocationUpdates(); // Start location updates
    _startFetchingMerchants(); // Start fetching merchants
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _isFetching = false;
    super.dispose();
  }

  // Start listening to location updates
  void _startLocationUpdates() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Set accuracy
      distanceFilter: 3, // Update every 10 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings, // Pass settings
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, _currentZoom);
      }
    });
  }

  // Stop location updates
  void _stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_currentPosition!, _currentZoom);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Lokasi tidak aktif.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak secara permanen.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _startFetchingMerchants() {
    _isFetching = true;
    Future.delayed(Duration.zero, _fetchMerchantsLoop);
  }

  Future<void> _fetchMerchantsLoop() async {
    if (!_isFetching) return;

    await _fetchOnlineMerchants();

    if (_merchants.isNotEmpty) {
      setState(() {
        _isFetching = false;
      });
      return;
    }
    await Future.delayed(Duration(seconds: 1));

    if (mounted) {
      _fetchMerchantsLoop();
    }
  }

  Future<void> _fetchOnlineMerchants() async {
    final sharedProvider = Provider.of<Sharedprovider>(context, listen: false);
    String token = sharedProvider.token ?? '';

    // Ambil data pedagang dari API
    List<Map<String, dynamic>>? pedagangData =
        await _apiService.getOnlinePedagang(ApiService.baseUrl, token);

    if (pedagangData != null) {
      setState(() {
        // Memproses data pedagang menjadi daftar objek Merchant
        _merchants = pedagangData
            .map((pedagang) {
              final namaProduk =
                  pedagang['name'] ?? 'Nama produk tidak tersedia';
              final kategoriProduk =
                  pedagang['kategori_produk'] ?? 'Kategori tidak tersedia';

              String fotoProduk = pedagang['fotoProduk'] ?? '';
              String fotoPedagang = pedagang['fotoPedagang'] ?? '';

              double merchantLatitude = pedagang['latitude'] ?? 0.0;
              double merchantLongitude = pedagang['longitude'] ?? 0.0;

              if (merchantLatitude == 0.0 || merchantLongitude == 0.0) {
                print('Warning: Merchant tanpa koordinat valid.');
                return null; // Skip merchant tanpa koordinat valid
              }

              String distance = pedagang['distance'] ?? '0.00 km';

              int hargaProduk =
                  pedagang['hargaProduk'] ?? 0; // Jika null, gunakan 0

              return Merchant(
                namaProduk,
                LatLng(merchantLatitude, merchantLongitude),
                'Jarak: $distance',
                kategoriProduk,
                fotoProduk,
                fotoPedagang,
                hargaProduk,
              );
            })
            .whereType<Merchant>() // Hapus data null akibat return null
            .toList();
      });
    } else {
      // Tangani jika data pedagang tidak berhasil diambil
      print("Gagal mengambil data pedagang.");
    }
  }

  List<Merchant> _getFilteredMerchants() {
    return _merchants.where((merchant) {
      final matchesCategory = _selectedCategory == 'All' ||
          merchant.kategori_produk == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          merchant.namaProduk
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Fungsi untuk menghitung jarak antara pengguna dan pedagang
  double _calculateDistanceFromMerchant(
      LatLng userLocation, LatLng merchantLocation) {
    return Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      merchantLocation.latitude,
      merchantLocation.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Merchant> nearbyMerchants = _getFilteredMerchants().where((merchant) {
      if (_currentPosition != null) {
        double distanceInMeters = _calculateDistanceFromMerchant(
          _currentPosition!,
          merchant.location,
        );
        return distanceInMeters <= _radius;
      }
      return false;
    }).toList();

    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              SizedBox(
                height: 200,
                child: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: _currentPosition,
                          zoom: _currentZoom,
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
                                point: _currentPosition!,
                                width: 80.0,
                                height: 80.0,
                                builder: (ctx) => const Icon(
                                  Icons.location_on,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                              ),
                              ...nearbyMerchants.map((merchant) => Marker(
                                    point: merchant.location,
                                    width: 80.0,
                                    height: 80.0,
                                    builder: (ctx) => GestureDetector(
                                      onTap: () {
                                        widget.onMerchantSelected(merchant);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blueAccent,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.store,
                                              color: Colors.white,
                                              size: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: _currentPosition!,
                                color: Colors.blue.withOpacity(0.3),
                                borderStrokeWidth: 2.0,
                                useRadiusInMeter: true,
                                radius: _radius,
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton(
                  onPressed: () {
                    if (_currentPosition != null) {
                      _mapController.move(_currentPosition!, _currentZoom);
                    }
                  },
                  tooltip: 'Fokus pada lokasi saya',
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        MerchantCard(
          nearbyMerchants: nearbyMerchants,
          onMerchantSelected: widget.onMerchantSelected,
        ),
      ],
    );
  }
}
