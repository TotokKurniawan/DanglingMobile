import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streetmarketid/features/orders/services/review_service.dart';

class ReviewScreen extends StatefulWidget {
  final int orderId;
  final int sellerId;
  final String sellerName;

  const ReviewScreen({
    super.key,
    required this.orderId,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _textController = TextEditingController();
  
  int _rating = 5;
  bool _isSubmitting = false;

  Future<void> _submit(bool isComplaint) async {
    final text = _textController.text.trim();
    
    if (isComplaint && text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi harus diisi untuk komplain.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    bool success;
    if (isComplaint) {
      success = await _reviewService.submitComplaint(
        orderId: widget.orderId,
        sellerId: widget.sellerId,
        rating: _rating,
        description: text,
      );
    } else {
      success = await _reviewService.submitReview(
        orderId: widget.orderId,
        rating: _rating,
        comment: text,
      );
    }

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isComplaint ? 'Komplain berhasil dikirim' : 'Review berhasil dikirim')),
      );
      Navigator.pop(context, true); // return true indicating success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim data. Mungkin pesanan ini sudah direview sebelumnya.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nilai Pesanan',
          style: GoogleFonts.lobster(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Toko: ${widget.sellerName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${widget.orderId}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Beri Bintang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            
            const SizedBox(height: 32),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis komentar atau keluhan Anda di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            
            const SizedBox(height: 32),
            
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton(
                onPressed: () => _submit(false),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kirim Ulasan', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _submit(true),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ajukan Komplain', style: TextStyle(fontSize: 16, color: Colors.redAccent)),
              ),
              const SizedBox(height: 8),
              const Text(
                '*Komplain harus disertai dengan deskripsi keluhan.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
