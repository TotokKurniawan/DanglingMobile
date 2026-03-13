import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streetmarketid/core/providers/sharedProvider.dart';
import 'package:streetmarketid/features/orders/services/review_service.dart';

class ReviewListScreen extends StatefulWidget {
  @override
  _ReviewListScreenState createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  final ReviewService _reviewService = ReviewService();
  List<dynamic> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoading = true);
    final sharedProvider = Provider.of<Sharedprovider>(context, listen: false);
    final sellerId = sharedProvider.idPedagang;

    if (sellerId != null) {
      final data = await _reviewService.getStoreReviews(sellerId);
      if (mounted) {
        setState(() {
          _reviews = data ?? [];
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _replyDialog(int reviewId, String? existingReply) async {
    String replyText = existingReply ?? '';
    final bool? shouldReply = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Balas Ulasan'),
        content: TextField(
          controller: TextEditingController(text: replyText),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Tulis balasan Anda di sini...',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => replyText = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (shouldReply == true && replyText.isNotEmpty) {
      setState(() => _isLoading = true);
      final success = await _reviewService.replyToReview(reviewId, replyText);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Balasan berhasil dikirim!')),
          );
        }
        _fetchReviews();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengirim balasan.')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ulasan Toko", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigoAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? const Center(child: Text("Belum ada ulasan untuk toko Anda."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    final rating = review['rating'] ?? 0;
                    final comment = review['comment'] ?? 'Tidak ada komentar.';
                    final buyerName = review['buyer']?['user']?['name'] ?? 'Pembeli';
                    final sellerReply = review['seller_reply'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  buyerName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(comment),
                            const SizedBox(height: 12),
                            if (sellerReply != null && sellerReply.toString().isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Balasan Anda:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo)),
                                    const SizedBox(height: 4),
                                    Text(sellerReply, style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _replyDialog(review['id'], sellerReply?.toString()),
                                icon: const Icon(Icons.reply, size: 16),
                                label: Text(sellerReply == null ? 'Balas' : 'Edit Balasan'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
