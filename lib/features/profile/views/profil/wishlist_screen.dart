import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streetmarketid/features/profile/services/favorite_service.dart';
import 'package:streetmarketid/features/home/views/home/component/map.dart'; // Using Merchant model from here temporarily if needed
import 'package:latlong2/latlong.dart';
import 'package:streetmarketid/features/orders/views/pesanan/merchantdetailscreen.dart';

class WishlistScreen extends StatefulWidget {
  static String routeName = '/wishlistscreen';
  const WishlistScreen({super.key});

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  List<dynamic> _favoritedSellers = [];
  bool _isLoading = true;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;
      
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      print("GPS Error in wishlist: $e");
    }
  }

  Future<void> _fetchFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    final favorites = await _favoriteService.getFavorites();
    
    if (mounted) {
      setState(() {
        _favoritedSellers = favorites ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.black),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF536DFE), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Text(
            'Toko Favorit',
            style: GoogleFonts.lobster(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoritedSellers.isEmpty
              ? const Center(child: Text('Belum ada toko di wishlist.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoritedSellers.length,
                  itemBuilder: (context, index) {
                    final fav = _favoritedSellers[index];
                    final seller = fav['seller'];
                    if (seller == null) return const SizedBox.shrink();

                    final isOnline = seller['is_online'] == true;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: InkWell(
                        onTap: () {
                          final merchantLatitude = double.tryParse(seller['latitude']?.toString() ?? '0') ?? 0.0;
                          final merchantLongitude = double.tryParse(seller['longitude']?.toString() ?? '0') ?? 0.0;
                          
                          final merchant = Merchant(
                            seller['id'],
                            fav['seller_id'], 
                            seller['store_name'] ?? 'Toko',
                            LatLng(merchantLatitude, merchantLongitude),
                            'Favorit',
                            seller['photo_url'] ?? '',
                            [], // Kita belum fetch produk, biarkan kosong sementara
                          );
                          
                          Navigator.push(context, MaterialPageRoute(
                            builder: (c) => MerchantDetailScreen(
                              merchant: merchant, 
                              currentPosition: _currentPosition ?? LatLng(0,0)
                            )
                          ));
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.network(
                                seller['photo_url'] ?? 'https://via.placeholder.com/100',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.store, size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    seller['store_name'] ?? 'Toko Tidak Bernama',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${seller['rating_average'] ?? 0.0} (${seller['rating_count'] ?? 0})",
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: isOnline ? Colors.green : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isOnline ? 'Buka' : 'Tutup',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isOnline ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () async {
                                bool success = await _favoriteService.removeFromFavorites(seller['id']);
                                if (success) {
                                  _fetchFavorites(); // Refresh list
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Dihapus dari Favorit')),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
