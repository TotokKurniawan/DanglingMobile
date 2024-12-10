import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:damping/service/ApiService.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = '/historyscreen';
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _orderHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() {
      _isLoading =
          true; // Mengatur loading menjadi true saat memulai pemanggilan API
    });
    try {
      final orders = await _apiService.orderHistory();

      // Debugging log untuk memastikan data yang diterima
      print("Data histori pesanan: $orders");

      setState(() {
        if (orders.isNotEmpty) {
          _orderHistory = orders.map((order) {
            return {
              'orderId': order['orderId'] ?? 'No ID',
              'status': order['status'] ?? 'No Status',
              'date': order['date'] ?? 'No Date',
            };
          }).toList();
        } else {
          _orderHistory = []; // Jika tidak ada data histori
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching order history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF536DFE),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'History Pemesanan',
                style: GoogleFonts.lobster(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orderHistory.isEmpty
              ? const Center(child: Text("Tidak ada riwayat pemesanan."))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ..._orderHistory.map((order) {
                        return _buildOrderHistoryCard(
                          order['orderId'],
                          order['status'],
                          order['date'],
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
    );
  }

  // Fungsi untuk membangun card untuk history pemesanan
  Widget _buildOrderHistoryCard(String orderId, String status, String date) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderId,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: status == 'Status: Selesai'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  date,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey,
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
