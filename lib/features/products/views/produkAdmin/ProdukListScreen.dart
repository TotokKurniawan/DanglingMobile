import 'package:flutter/material.dart';
import '../../services/product_api.dart';
import 'FormProdukScreen.dart';

class ProdukListScreen extends StatefulWidget {
  const ProdukListScreen({Key? key}) : super(key: key);

  @override
  _ProdukListScreenState createState() => _ProdukListScreenState();
}

class _ProdukListScreenState extends State<ProdukListScreen> {
  final ProductApi _productApi = ProductApi();
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final products = await _productApi.getProducts();
    setState(() {
      _products = products ?? [];
      _isLoading = false;
    });
  }

  Future<void> _deleteProduct(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    final success = await _productApi.deleteProduct(id);
    Navigator.pop(context); // close loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produk berhasil dihapus!")));
      _fetchProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus produk.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Produk"),
        backgroundColor: Colors.indigoAccent,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _products.isEmpty 
          ? const Center(child: Text("Belum ada produk. Tambahkan produk pertama Anda!"))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: product['photo_url'] != null
                        ? Image.network(product['photo_url'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                        : const Icon(Icons.inventory, size: 50),
                    title: Text(product['name'] ?? 'Produk'),
                    subtitle: Text("Rp ${product['price'] ?? 0}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: product['is_active'] == 1 || product['is_active'] == true,
                            activeColor: Colors.green,
                            onChanged: (val) async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(child: CircularProgressIndicator()),
                              );
                              final success = await _productApi.toggleActive(product['id']);
                              Navigator.pop(context); // close dialog
                              if (success) {
                                _fetchProducts();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val ? "Produk diaktifkan" : "Produk dinonaktifkan")));
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FormProdukScreen(initialProduct: product)),
                            ).then((value) => _fetchProducts());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Hapus Produk"),
                                content: const Text("Yakin ingin menghapus produk ini?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _deleteProduct(product['id']);
                                    }, 
                                    child: const Text("Hapus", style: TextStyle(color: Colors.red))
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigoAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormProdukScreen()),
          ).then((value) => _fetchProducts()); // Reload when returning
        },
      ),
    );
  }
}
