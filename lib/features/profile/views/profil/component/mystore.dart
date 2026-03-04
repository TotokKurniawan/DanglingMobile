import 'package:damping/features/profile/services/store_api.dart';
import 'package:damping/features/profile/services/seller_stats_service.dart';
import 'package:flutter/material.dart';
import 'package:damping/features/products/views/produkAdmin/ProdukListScreen.dart';
import 'package:geolocator/geolocator.dart';

enum StoreStatus { online, offline }

class MyStoreScreen extends StatefulWidget {
  const MyStoreScreen({Key? key}) : super(key: key);

  @override
  _MyStoreScreenState createState() => _MyStoreScreenState();
}

class _MyStoreScreenState extends State<MyStoreScreen> {
  StoreStatus _storeStatus = StoreStatus.offline;
  final StoreApi storeApi = StoreApi();
  final SellerStatsService _statsService = SellerStatsService();
  bool _isLoading = true;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    try {
      final isOnline = await storeApi.getStoreStatus();
      final statsData = await _statsService.getSellerStats();
      
      if (mounted) {
        setState(() {
          _storeStatus = isOnline ? StoreStatus.online : StoreStatus.offline;
          _stats = statsData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat status & data toko')),
        );
      }
    }
  }

  void _toggleStoreStatus() {
    setState(() {
      _storeStatus = _storeStatus == StoreStatus.online
          ? StoreStatus.offline
          : StoreStatus.online;
    });
    _updateStoreStatus(_storeStatus);
  }

  Future<void> _updateStoreStatus(StoreStatus status) async {
    setState(() => _isLoading = true);

    bool success = await storeApi.updateStatus(status == StoreStatus.online);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // Jika toko baru Online, perbarui lokasi GPS seller ke backend
        if (status == StoreStatus.online) {
          _updateSellerGpsLocation();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status toko berhasil diubah')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengubah status toko')),
        );
      }
    }
  }

  /// Ambil GPS saat ini dan kirim ke server sebagai lokasi pedagang
  Future<void> _updateSellerGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showGpsSnackBar('Layanan GPS tidak aktif. Lokasi tidak diperbarui.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showGpsSnackBar('Izin GPS ditolak. Lokasi tidak diperbarui.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showGpsSnackBar('Izin GPS ditolak permanen. Buka pengaturan untuk mengizinkan.');
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final bool locationUpdated = await storeApi.checkLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (mounted) {
        if (locationUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lokasi toko berhasil diperbarui.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showGpsSnackBar('Gagal memperbarui lokasi toko.');
        }
      }
    } catch (e) {
      _showGpsSnackBar('Error GPS: ${e.toString()}');
    }
  }

  void _showGpsSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Dashboard Toko", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStoreData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GreetingCard(
                      storeStatus: _storeStatus,
                      onToggleStatus: _toggleStoreStatus,
                    ),
                    const SizedBox(height: 24),
                    const Text('Statistik Penjualan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _stats == null 
                        ? const Center(child: Text('Data statistik belum tersedia'))
                        : _buildStatsSection(_stats!),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats) {
    final double revenueToday = double.tryParse(stats['today_revenue']?.toString() ?? '0') ?? 0.0;
    final double revenueTotal = double.tryParse(stats['total_revenue']?.toString() ?? '0') ?? 0.0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _StatCard(title: 'Pendapatan Hari Ini', value: 'Rp ${revenueToday.toStringAsFixed(0)}', icon: Icons.attach_money, color: Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Total Pendapatan', value: 'Rp ${revenueTotal.toStringAsFixed(0)}', icon: Icons.account_balance_wallet, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _StatCard(title: 'Order Selesai', value: '${stats['completed_orders'] ?? 0}', icon: Icons.check_circle, color: Colors.teal)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Total Order', value: '${stats['total_orders'] ?? 0}', icon: Icons.shopping_bag, color: Colors.orange)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _StatCard(
                title: 'Rating Bintang', 
                value: '${stats['rating_average'] ?? 0.0}', 
                subValue: '(${stats['rating_count']} Ulasan)',
                icon: Icons.star, 
                color: Colors.amber
              )
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Komplain', 
                value: '${stats['complaint_count'] ?? 0}', 
                icon: Icons.warning, 
                color: Colors.redAccent
              )
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, this.subValue, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(subValue!, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ]
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final StoreStatus storeStatus;
  final VoidCallback onToggleStatus;

  const _GreetingCard({
    Key? key,
    required this.storeStatus,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      shadowColor: Colors.blueAccent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat Datang di Toko Anda!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status Toko: ${storeStatus == StoreStatus.online ? 'Aktif' : 'Offline'}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: storeStatus == StoreStatus.online
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onToggleStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: storeStatus == StoreStatus.online
                        ? Colors.redAccent
                        : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(
                    storeStatus == StoreStatus.online
                        ? Icons.offline_bolt
                        : Icons.store,
                    color: Colors.white,
                  ),
                  label: Text(
                    storeStatus == StoreStatus.online
                        ? "Tutup Toko"
                        : "Buka Toko",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProdukListScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Kelola Produk"),
            ),
          ],
        ),
      ),
    );
  }
}
