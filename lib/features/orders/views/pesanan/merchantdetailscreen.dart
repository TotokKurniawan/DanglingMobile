import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:damping/features/home/views/home/component/map.dart';
import 'package:damping/features/orders/views/pesanan/component/map_component.dart';
import 'package:damping/core/providers/cart_provider.dart';
import 'package:damping/features/orders/views/checkout/checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:damping/features/chats/services/chat_service.dart';
import 'package:damping/features/chats/views/message/message.dart';
import 'package:damping/features/profile/services/favorite_service.dart';

class MerchantDetailScreen extends StatefulWidget {
  final Merchant merchant;
  final LatLng currentPosition;

  const MerchantDetailScreen({
    Key? key,
    required this.merchant,
    required this.currentPosition,
  }) : super(key: key);

  @override
  _MerchantDetailScreenState createState() => _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> {
  final MapController _mapController = MapController();
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorited = false;
  bool _isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final favorites = await _favoriteService.getFavorites();
    if (favorites != null) {
      if (mounted) {
        setState(() {
          _isFavorited = favorites.any((fav) => fav['seller_id'] == widget.merchant.id);
          _isLoadingFavorite = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isLoadingFavorite = true;
    });

    bool success;
    if (_isFavorited) {
      success = await _favoriteService.removeFromFavorites(widget.merchant.id);
    } else {
      success = await _favoriteService.addToFavorites(widget.merchant.id);
    }

    if (success) {
      setState(() {
        _isFavorited = !_isFavorited;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isFavorited ? 'Ditambahkan ke Favorit' : 'Dihapus dari Favorit')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui Favorit')),
        );
      }
    }

    setState(() {
      _isLoadingFavorite = false;
    });
  }

  // Menghitung jarak
  double _calculateDistance() {
    return Geolocator.distanceBetween(
          widget.currentPosition.latitude,
          widget.currentPosition.longitude,
          widget.merchant.location.latitude,
          widget.merchant.location.longitude,
        ) /
        1000;
  }

  @override
  Widget build(BuildContext context) {
    double distanceInKm = _calculateDistance();
    double screenWidth = MediaQuery.of(context).size.width;
    
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.merchant.namaToko),
        actions: [
          _isLoadingFavorite 
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
              )
            : IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.red : Colors.black54,
                ),
                tooltip: 'Favorit',
                onPressed: _toggleFavorite,
              ),
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Chat Penjual',
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              
              final chatService = ChatService();
              final convId = await chatService.createConversation(widget.merchant.userId);
              
              Navigator.pop(context); // Close loading
              
              if (convId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageScreen(
                      conversationId: convId,
                      chatName: widget.merchant.namaToko,
                      avatarUrl: widget.merchant.fotoPedagang.isNotEmpty ? widget.merchant.fotoPedagang : null,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memulai obrolan')));
              }
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF536DFE), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            // Gambar Toko
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: screenWidth,
                  height: screenWidth * 0.4,
                  child: Image.network(
                    widget.merchant.fotoPedagang.isNotEmpty
                        ? widget.merchant.fotoPedagang
                        : 'https://via.placeholder.com/400x200',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.store,
                      size: screenWidth * 0.4,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            // Map
            MerchantMap(
              mapController: _mapController,
              currentPosition: widget.currentPosition,
              merchantPosition: widget.merchant.location,
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    widget.merchant.namaToko,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text("Jarak: ${distanceInKm.toStringAsFixed(2)} km"),
                  SizedBox(height: screenWidth * 0.03),
                  Divider(),
                  Text(
                    "Katalog Menu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  widget.merchant.products.isEmpty 
                    ? const Center(child: Text("Tidak ada produk."))
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: widget.merchant.products.length,
                        itemBuilder: (context, index) {
                          final product = widget.merchant.products[index];
                          // Format currency
                          final price = double.tryParse(product['price'].toString()) ?? 0.0;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product['photo_url'] ?? 'https://via.placeholder.com/80',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 40),
                                ),
                              ),
                              title: Text(product['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                "Rp ${price.toStringAsFixed(0)}\n${product['category'] ?? ''}",
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                                onPressed: () {
                                  cartProvider.addToCart(widget.merchant, product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${product['name']} ditambahkan ke keranjang"),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                    )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: cartProvider.totalQuantity > 0 ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CheckoutScreen()),
          );
        },
        label: Text('Keranjang (${cartProvider.totalQuantity}) - Rp ${cartProvider.totalPrice.toStringAsFixed(0)}'),
        icon: const Icon(Icons.shopping_cart),
        backgroundColor: Colors.blueAccent,
      ) : null,
    );
  }
}

