import 'package:flutter/material.dart';

class PromoCarousel extends StatefulWidget {
  @override
  _PromoCarouselState createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final List<Map<String, String>> merchantAds = [
    {
      "image": "assets/images/merchant1.jpg",
      "merchantName": "Bakso Pak Joko",
      "productName": "Bakso Urat Spesial",
      "description": "Bakso urat lezat dengan potongan daging istimewa!"
    },
    {
      "image": "assets/images/merchant2.jpg",
      "merchantName": "Warung Nasi Goreng Bu Rani",
      "productName": "Nasi Goreng Pedas",
      "description": "Nasi goreng pedas yang bikin nagih!"
    },
    {
      "image": "assets/images/merchant3.jpg",
      "merchantName": "Jajanan Manis Mbak Ani",
      "productName": "Kue Cubit Lumer",
      "description": "Kue cubit lumer dengan topping favorit!"
    },
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), _autoSlide);
    });
  }

  void _autoSlide() {
    if (_pageController.hasClients) {
      setState(() {
        _currentPage = (_currentPage + 1) % merchantAds.length;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      // Schedule the next slide
      Future.delayed(Duration(seconds: 3), _autoSlide);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: merchantAds.length,
        itemBuilder: (context, index) {
          final ad = merchantAds[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(ad["image"]!),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad["merchantName"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ad["productName"]!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ad["description"]!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
