import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class SplashContent extends StatelessWidget {
  final String? image;
  final String? text;

  const SplashContent({super.key, this.image, this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center, // Mengatur posisi konten agar terpusat
      children: <Widget>[
        // Menambahkan teks "DangLing" dengan font dari Google Fonts
        Text(
          "DangLing",
          style: GoogleFonts.lobster(
            // Menggunakan font Google Fonts
            textStyle: const TextStyle(
              fontSize: 40,
              color: Colors.white, // Warna putih agar kontras dengan background
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Pedagang Keliling",
          style: GoogleFonts.lobster(
            // Menggunakan font Google Fonts
            textStyle: const TextStyle(
              fontSize: 15,
              color: Colors.white, // Warna putih agar kontras dengan background
            ),
          ),
        ),
        const SizedBox(
            height: 20), // Memberikan jarak antara teks "DangLing" dan gambar
        // Menampilkan gambar yang diberikan
        Image.asset(
          image!, // Memastikan image tidak null
          height: 270, // Sesuaikan ukuran gambar
          width: 270, // Sesuaikan ukuran gambar
        ),
        const SizedBox(
            height: 10), // Memberikan jarak antara gambar dan teks berikutnya
        // Menampilkan teks yang diberikan (dari splashData)
        Text(
          text!, // Teks yang berasal dari splashData
          textAlign: TextAlign.center, // Membuat teks terpusat
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Warna teks
          ),
        ),
      ],
    );
  }
}
