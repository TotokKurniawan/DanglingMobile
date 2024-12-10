import 'package:damping/service/ApiService.dart';
import 'package:flutter/material.dart';

enum StoreStatus { online, offline }

class MyStoreScreen extends StatefulWidget {
  const MyStoreScreen({Key? key}) : super(key: key);

  @override
  _MyStoreScreenState createState() => _MyStoreScreenState();
}

class _MyStoreScreenState extends State<MyStoreScreen> {
  StoreStatus _storeStatus = StoreStatus.offline; // Default status
  final ApiService apiService = ApiService();
  bool _isLoading = true; // Untuk loading status toko

  @override
  void initState() {
    super.initState();
    _loadStoreStatus(); // Memuat status toko saat pertama kali
  }

  Future<void> _loadStoreStatus() async {
    try {
      bool isOnline = await apiService.getStoreStatus(); // API untuk status
      setState(() {
        _storeStatus = isOnline ? StoreStatus.online : StoreStatus.offline;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat status toko')),
      );
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
    setState(() {
      _isLoading = true;
    });

    bool success = await apiService.updateStatus(status == StoreStatus.online);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status toko berhasil diubah')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengubah status toko')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Dashboard Toko"),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
        elevation: 6,
        shadowColor: Colors.grey.withOpacity(0.3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Loading indikator
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GreetingCard(
                    storeStatus: _storeStatus,
                    onToggleStatus: _toggleStoreStatus,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
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
                Navigator.pushNamed(context, '/FormProdukScreen');
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
