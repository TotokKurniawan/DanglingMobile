import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:damping/screen/home/component/map.dart';
import 'package:damping/screen/pesanan/component/carapembayaran.dart';
import 'package:damping/screen/pesanan/VendorMapScreen.dart';
import 'package:damping/screen/pesanan/component/rincian_harga_card.dart';
import 'package:damping/screen/pesanan/component/map_component.dart';

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
  final int adminFee = 1000;
  String selectedPaymentMethod = '';

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

  // Menghitung biaya total
  double _calculateTotalCost() {
    // Pastikan konversi ke double
    return (widget.merchant.hargaProduk.toDouble() + adminFee.toDouble());
  }

  void _showPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PilihMetodePembayaranDialog(
          selectedPaymentMethod: selectedPaymentMethod,
          onMethodSelected: (String method) {
            setState(() {
              selectedPaymentMethod = method;
            });
          },
        );
      },
    );
  }

  // Memeriksa metode pembayaran dan melanjutkan ke halaman berikutnya
  void _checkPaymentMethodAndProceed() {
    if (selectedPaymentMethod.isEmpty) {
      _showPaymentWarningDialog();
    } else {
      _navigateToVendorMapScreen();
    }
  }

  // Menampilkan peringatan jika metode pembayaran belum dipilih
  void _showPaymentWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Peringatan'),
          content:
              const Text('Silakan pilih metode pembayaran terlebih dahulu.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Navigasi ke halaman VendorMapScreen
  void _navigateToVendorMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorMapScreen(
          vendorPosition: widget.merchant.location,
          currentPosition: widget.currentPosition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double distanceInKm = _calculateDistance();
    double totalCost = _calculateTotalCost();

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.merchant.namaProduk),
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
            // Mengubah ukuran gambar agar seukuran dengan map
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    12), // Memberikan sudut melengkung pada gambar
                child: Container(
                  width:
                      screenWidth, // Menggunakan lebar layar yang sama dengan map
                  height: screenWidth * 0.5,
                  child: Image.network(
                    widget.merchant.fotoProduk,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      size: screenWidth * 0.6,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
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
                  // Rincian nama, kategori, dan jarak
                  Text(
                    widget.merchant.namaProduk,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    "Kategori: ${widget.merchant.kategori_produk}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    "Info: ${widget.merchant.info}",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    "Jarak: ${distanceInKm.toStringAsFixed(2)} km",
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  RincianHargaCard(
                    basePrice: widget.merchant.hargaProduk.toDouble(),
                    adminFee: adminFee.toDouble(),
                    totalCost: totalCost,
                    selectedPaymentMethod: selectedPaymentMethod,
                    onPaymentMethodTap: _showPaymentMethodDialog,
                    onConfirmTap: _checkPaymentMethodAndProceed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
