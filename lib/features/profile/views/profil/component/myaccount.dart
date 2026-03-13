import 'package:streetmarketid/features/profile/views/profil/component/updateaccount.dart';
import 'package:streetmarketid/features/profile/views/profil/component/changepassword.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streetmarketid/core/providers/sharedProvider.dart';
import 'package:streetmarketid/features/profile/services/profile_service.dart';
import 'package:streetmarketid/features/authentication/views/sign_in/sign_in_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  Widget _buildProfileItem(String label, String? text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: Colors.indigoAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: ${text ?? 'Not available'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    // Langkah 1: konfirmasi pertama
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Hapus Akun?'),
          ],
        ),
        content: const Text(
          'Akun Anda akan dihapus secara permanen beserta seluruh data yang terkait. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lanjutkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    // Langkah 2: konfirmasi kedua (ketik "HAPUS")
    final controller = TextEditingController();
    final secondConfirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Terakhir', style: TextStyle(color: Colors.redAccent)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ketik HAPUS untuk mengkonfirmasi penghapusan akun Anda:'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'HAPUS',
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.text == 'HAPUS'
                    ? Colors.redAccent
                    : Colors.grey,
              ),
              onPressed: controller.text == 'HAPUS'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: const Text('Hapus Akun Saya', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (secondConfirm != true) return;

    // Proses penghapusan
    final profileService = ProfileService();
    final success = await profileService.deleteAccount();

    if (!context.mounted) return;

    if (success) {
      final sharedProvider = Provider.of<Sharedprovider>(context, listen: false);
      await sharedProvider.clearProfile();
      Navigator.pushNamedAndRemoveUntil(context, SignInScreen.routeName, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus akun. Coba lagi nanti.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<Sharedprovider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.indigoAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.indigoAccent.shade100,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 25),
            _buildProfileItem('Name', sharedProvider.nama),
            _buildProfileItem('Email', sharedProvider.email),
            _buildProfileItem('Password', sharedProvider.password),
            _buildProfileItem('Role', sharedProvider.role),
            const SizedBox(height: 24),

            // Update Profile
            _ActionButton(
              label: 'Update Profile',
              icon: Icons.edit,
              color: Colors.indigoAccent,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UpdateProfileForm()),
              ),
            ),
            const SizedBox(height: 12),

            // Ganti Password
            _ActionButton(
              label: 'Ganti Password',
              icon: Icons.lock_outline,
              color: Colors.orangeAccent,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
              ),
            ),
            const SizedBox(height: 24),

            const Divider(thickness: 1),
            const SizedBox(height: 8),

            // Hapus Akun
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                label: const Text(
                  'Hapus Akun',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _confirmDeleteAccount(context),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Penghapusan akun bersifat permanen dan tidak dapat dipulihkan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable action button untuk halaman My Account
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
