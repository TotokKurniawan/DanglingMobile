import 'package:flutter/material.dart';

class PilihMetodePembayaranDialog extends StatelessWidget {
  final Function(String) onMethodSelected;
  final String selectedPaymentMethod;

  const PilihMetodePembayaranDialog({
    Key? key,
    required this.onMethodSelected,
    required this.selectedPaymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 300, // Height can still be set for optimal size
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        // Make the content scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF536DFE), // Replaced orangeAccent with #536DFE
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: const Text('Cash'),
              leading: Radio<String>(
                value: 'Cash',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  if (value != null) {
                    onMethodSelected(value);
                    Navigator.of(context).pop(); // Close the bottom sheet
                  }
                },
              ),
            ),
            // ListTile(
            //   title: const Text('Dompet Digital'),
            //   leading: Radio<String>(
            //     value: 'Dompet Digital',
            //     groupValue: selectedPaymentMethod,
            //     onChanged: (value) {
            //       if (value != null) {
            //         onMethodSelected(value);
            //         Navigator.of(context).pop(); // Close the bottom sheet
            //       }
            //     },
            //   ),
            // ),
            // ListTile(
            //   title: const Text('Dana'),
            //   leading: Radio<String>(
            //     value: 'Dana',
            //     groupValue: selectedPaymentMethod,
            //     onChanged: (value) {
            //       if (value != null) {
            //         onMethodSelected(value);
            //         Navigator.of(context).pop(); // Close the bottom sheet
            //       }
            //     },
            //   ),
            // ),
            // ListTile(
            //   title: const Text('QRIS'),
            //   leading: Radio<String>(
            //     value: 'QRIS',
            //     groupValue: selectedPaymentMethod,
            //     onChanged: (value) {
            //       if (value != null) {
            //         onMethodSelected(value);
            //         Navigator.of(context).pop(); // Close the bottom sheet
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
