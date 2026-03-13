import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streetmarketid/features/orders/services/order_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:streetmarketid/features/orders/views/history/review_screen.dart';

class HistoryScreen extends StatefulWidget {
  static String routeName = '/historyscreen';
  final String role; // 'buyer' or 'seller'
  final bool showAppBar;

  const HistoryScreen({super.key, this.role = 'buyer', this.showAppBar = true});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final OrderService _orderService = OrderService();
  List<dynamic> _orderHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderHistory();
  }

  Future<void> _fetchOrderHistory() async {
    setState(() {
      _isLoading = true; 
    });
    try {
      final orders = await _orderService.getOrderHistory(role: widget.role);
      
      setState(() {
        _orderHistory = orders ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error fetching order history: $e");
    }
  }

  Future<void> _uploadBukti(int orderId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      bool success = await _orderService.confirmPayment(orderId, pickedFile.path);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti pembayaran berhasil diupload (UI)')),
        );
        _fetchOrderHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupload bukti pembayaran.')),
        );
      }
    }
  }

  Future<void> _reorder(int orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    bool success = await _orderService.reorder(orderId);
    Navigator.pop(context); // close loading
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibuat ulang! (Silakan cek tab pesanan)')),
      );
      _fetchOrderHistory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal pesan ulang.')),
      );
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    String reason = '';
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batal Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Alasan Pembatalan',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => reason = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (reason.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alasan pembatalan harus diisi.')),
        );
        return;
      }
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      final success = await _orderService.cancelByBuyer(orderId, reason);
      
      if (!mounted) return;
      Navigator.pop(context); // close loading
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibatalkan.')),
        );
        _fetchOrderHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membatalkan pesanan.')),
        );
      }
    }
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_orderHistory.isEmpty) return const Center(child: Text("Tidak ada riwayat pemesanan."));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orderHistory.length,
      itemBuilder: (context, index) {
        final order = _orderHistory[index];
        return _buildOrderHistoryCard(order);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      return Container(
        color: Colors.white,
        child: _buildBody(),
      );
    }

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
      body: _buildBody(),
    );
  }

  Widget _buildOrderHistoryCard(dynamic order) {
    final orderId = order['id'] ?? 0;
    final status = order['status'] ?? 'UNKNOWN';
    final paymentStatus = order['payment_status'] ?? 'UNKNOWN';
    final paymentMethod = order['payment_method'] ?? 'UNKNOWN';
    final date = order['created_at'] != null 
        ? order['created_at'].toString().split('T')[0] 
        : 'Tanggal tidak ada';
    final totalAmount = order['total_amount'] != null
        ? double.tryParse(order['total_amount'].toString()) ?? 0.0
        : 0.0;
        
    final sellerName = order['seller']?['store_name'] ?? 'Toko Tidak Bernama';
    final buyerName = order['buyer']?['user']?['name'] ?? 'Pembeli Tidak Diketahui';

    bool isPendingTransfer = (widget.role == 'buyer' && paymentStatus == 'PENDING' && paymentMethod == 'TRANSFER');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #$orderId",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.role == 'seller' ? 'Pembeli: $buyerName' : 'Toko: $sellerName', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Status: $status'),
            Text('Pembayaran: $paymentMethod ($paymentStatus)', 
              style: TextStyle(
                color: paymentStatus == 'PAID' ? Colors.green : Colors.orange,
              )
            ),
            const SizedBox(height: 4),
            Text('Total: Rp ${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            
            if (isPendingTransfer) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _uploadBukti(orderId),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Bukti Pembayaran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            if (widget.role == 'buyer' && status == 'PENDING') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelOrder(orderId),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Batalkan Pesanan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
            
            if (widget.role == 'buyer' && (status == 'COMPLETED' || status == 'CANCELLED')) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _reorder(orderId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Pesan Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (status == 'COMPLETED') ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final sellerId = order['seller']?['id'] ?? 0;
                          final bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                orderId: orderId,
                                sellerId: sellerId,
                                sellerName: sellerName,
                              ),
                            ),
                          );
                          if (result == true) {
                            _fetchOrderHistory(); // Refresh to reflect any UI changes if needed
                          }
                        },
                        icon: const Icon(Icons.star_rate),
                        label: const Text('Nilai / Komplain'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}

