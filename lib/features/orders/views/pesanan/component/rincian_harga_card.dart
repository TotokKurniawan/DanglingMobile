import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import package intl

class RincianHargaCard extends StatelessWidget {
  final double basePrice; // Gunakan double untuk harga produk
  final double adminFee; // Gunakan double untuk biaya admin
  final double totalCost; // Gunakan double untuk total biaya
  final String selectedPaymentMethod;
  final VoidCallback onPaymentMethodTap;
  final VoidCallback onConfirmTap;

  const RincianHargaCard({
    Key? key,
    required this.basePrice,
    required this.adminFee,
    required this.totalCost,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodTap,
    required this.onConfirmTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Format harga
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(
        vertical: screenWidth * 0.02,
        horizontal: screenWidth * 0.01,
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rincian Harga",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Harga Produk:"),
                Text(currencyFormat.format(basePrice)),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Biaya Admin:"),
                Text(currencyFormat.format(adminFee)),
              ],
            ),
            Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Biaya:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
                Text(
                  currencyFormat.format(totalCost),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onPaymentMethodTap,
                  child: const Text("Cara Pembayaran"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.03,
                      horizontal: screenWidth * 0.04,
                    ),
                  ),
                ),
                if (selectedPaymentMethod.isNotEmpty) ...[
                  SizedBox(width: screenWidth * 0.07),
                  Expanded(
                    child: Text(
                      selectedPaymentMethod,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF536DFE),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: screenWidth * 0.05),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirmTap,
                child: const Text("Konfirmasi Pemesanan"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF536DFE),
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
