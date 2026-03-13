import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streetmarketid/core/providers/cart_provider.dart';
import 'package:streetmarketid/features/orders/services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  String _paymentMethod = 'CASH';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _voucherController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    _voucherController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final merchant = cartProvider.currentMerchant;
    if (merchant == null || cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang belanja Anda kosong.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      "seller_id": merchant.id,
      "payment_method": _paymentMethod,
      "notes": _notesController.text.trim(),
      "voucher_code": _voucherController.text.trim().isNotEmpty
          ? _voucherController.text.trim()
          : null,
      "items": cartProvider.items.map((item) => {
            "product_id": item.product['id'],
            "quantity": item.quantity,
          }).toList(),
    };

    final result = await _orderService.createOrder(payload);

    if (mounted) {
      setState(() => _isLoading = false);

      if (result != null) {
        cartProvider.clearCart();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Column(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 60),
                SizedBox(height: 8),
                Text('Pesanan Berhasil!', textAlign: TextAlign.center),
              ],
            ),
            content: const Text(
              'Pesanan Anda telah dikirim. Tunggu konfirmasi dari pedagang.',
              textAlign: TextAlign.center,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent),
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // back from checkout
                  },
                  child: const Text('Lihat Pesanan',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat pesanan. Silakan coba lagi.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final merchant = cartProvider.currentMerchant;

        if (merchant == null || cartProvider.items.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Checkout'),
              backgroundColor: Colors.indigoAccent,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Keranjang Anda masih kosong',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent),
                    child: const Text('Mulai Belanja',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        final double subtotal = cartProvider.totalPrice;
        const double adminFee = 1000.0;
        final double total = subtotal + adminFee;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
            backgroundColor: Colors.indigoAccent,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.indigoAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: Colors.indigoAccent),
                      const SizedBox(width: 8),
                      Text(
                        merchant.namaToko,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Order items
                const Text('Pesanan Anda:',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...cartProvider.items.map((item) {
                  final price =
                      double.tryParse(item.product['price'].toString()) ?? 0.0;
                  final itemSubtotal = price * item.quantity;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product['name'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                    'Rp ${price.toStringAsFixed(0)} / pcs',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          // Qty controls
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    cartProvider.removeFromCart(item.product),
                                iconSize: 22,
                              ),
                              Text('${item.quantity}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    color: Colors.green),
                                onPressed: () =>
                                    cartProvider.addToCart(merchant, item.product),
                                iconSize: 22,
                              ),
                            ],
                          ),
                          // Subtotal
                          SizedBox(
                            width: 80,
                            child: Text(
                              'Rp ${itemSubtotal.toStringAsFixed(0)}',
                              textAlign: TextAlign.right,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                // Price summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                          label: 'Subtotal',
                          value: 'Rp ${subtotal.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _SummaryRow(
                          label: 'Biaya Aplikasi',
                          value: 'Rp ${adminFee.toStringAsFixed(0)}'),
                      const Divider(height: 16),
                      _SummaryRow(
                        label: 'Total Pembayaran',
                        value: 'Rp ${total.toStringAsFixed(0)}',
                        isBold: true,
                        valueColor: Colors.indigoAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Notes
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Catatan untuk pedagang (opsional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Voucher
                TextField(
                  controller: _voucherController,
                  decoration: InputDecoration(
                    labelText: 'Kode Voucher (opsional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.discount_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Payment method
                const Text('Metode Pembayaran:',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PaymentMethodCard(
                        label: 'CASH',
                        icon: Icons.money,
                        isSelected: _paymentMethod == 'CASH',
                        onTap: () =>
                            setState(() => _paymentMethod = 'CASH'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PaymentMethodCard(
                        label: 'TRANSFER',
                        icon: Icons.account_balance,
                        isSelected: _paymentMethod == 'TRANSFER',
                        onTap: () =>
                            setState(() => _paymentMethod = 'TRANSFER'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, -2))
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _submitOrder,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Buat Pesanan · Rp ${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow(
      {required this.label,
      required this.value,
      this.isBold = false,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor)),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigoAccent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.indigoAccent : Colors.grey,
                size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.indigoAccent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
