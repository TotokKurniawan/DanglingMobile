import 'package:damping/screen/home/component/map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:damping/screen/pesanan/merchantdetailscreen.dart';

class MerchantCard extends StatefulWidget {
  final List<Merchant> nearbyMerchants;
  final Function(Merchant) onMerchantSelected;

  const MerchantCard({
    Key? key,
    required this.nearbyMerchants,
    required this.onMerchantSelected,
  }) : super(key: key);

  @override
  _MerchantCardState createState() => _MerchantCardState();
}

class _MerchantCardState extends State<MerchantCard> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Layanan lokasi tidak aktif')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak')),
        );
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      labelText: 'Cari Pedagang',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: 'All',
                  onChanged: (value) {},
                  items: ['All', 'Jasa', 'Makanan Ringan', 'Makanan Berat']
                      .map((kategori_produk) => DropdownMenuItem(
                            value: kategori_produk,
                            child: Text(kategori_produk),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : widget.nearbyMerchants.isEmpty
                    ? const Center(
                        child: Text('Tidak ada pedagang dalam radius.'),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: widget.nearbyMerchants.map((merchant) {
                            double distanceInKm = Geolocator.distanceBetween(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                  merchant.location.latitude,
                                  merchant.location.longitude,
                                ) /
                                1000;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              leading: CircleAvatar(
                                radius: 30, // Ukuran lebih besar
                                backgroundImage: NetworkImage(
                                  merchant.fotoPedagang.isNotEmpty
                                      ? merchant.fotoPedagang
                                      : 'https://via.placeholder.com/150',
                                ),
                              ),
                              title: Text(
                                merchant.namaProduk.isNotEmpty
                                    ? merchant.namaProduk
                                    : 'Nama tidak tersedia',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Text(
                                '${distanceInKm.toStringAsFixed(2)} km dari lokasi Anda',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              trailing: SizedBox(
                                width: 80, // Memperbesar ruang gambar produk
                                height: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    merchant.fotoProduk.isNotEmpty
                                        ? merchant.fotoProduk
                                        : 'https://via.placeholder.com/150', // Gambar placeholder
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(50),
                                    ),
                                  ),
                                  builder: (BuildContext context) {
                                    return MerchantDetailScreen(
                                      merchant: merchant,
                                      currentPosition: LatLng(
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
