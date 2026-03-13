import 'package:flutter/material.dart';
import 'package:streetmarketid/features/orders/services/order_service.dart';

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final OrderService _orderService = OrderService();
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    final orders = await _orderService.getPendingOrders();
    setState(() {
      _orders = orders ?? [];
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(int orderId, String action, String message) async {
    // Show loading
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator())
    );

    final success = await _orderService.updateOrderStatus(orderId, action);
    
    Navigator.pop(context); // Close loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _fetchOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memperbarui status pesanan.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Belum ada pesanan tertunda."),
      ));
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        final orderId = order['id'];
        final status = order['status'] ?? 'UNKNOWN';
        final buyerName = order['buyer']?['name'] ?? 'Pelanggan';
        final totalAmount = double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0.0;
        final isTransfer = order['payment_method'] == 'TRANSFER';
        final paymentStatus = order['payment_status'] ?? 'UNKNOWN';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$buyerName (Order #$orderId)",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text("Total: Rp ${totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 14)),
                          Text(
                            "Status: $status",
                            style: TextStyle(
                              fontSize: 14,
                              color: status == 'PENDING' ? Colors.orange : Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (status == 'PENDING' && isTransfer) ...[
                            Text("Bayar (Transfer): $paymentStatus", style: const TextStyle(color: Colors.red)),
                          ]
                        ],
                      ),
                    ),
                    
                    // Action Buttons based on Status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (status == 'PENDING') ...[
                          ElevatedButton(
                            onPressed: () => _updateStatus(orderId, 'accept', 'Pesanan diterima!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: const Size(80, 32),
                            ),
                            child: const Text("Terima", style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _updateStatus(orderId, 'reject', 'Pesanan ditolak!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(80, 32),
                            ),
                            child: const Text("Tolak", style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ] else if (status == 'PROCESSING') ...[
                          ElevatedButton(
                            onPressed: () => _updateStatus(orderId, 'complete', 'Pesanan diselesaikan!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              minimumSize: const Size(80, 32),
                            ),
                            child: const Text("Selesaikan", style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
