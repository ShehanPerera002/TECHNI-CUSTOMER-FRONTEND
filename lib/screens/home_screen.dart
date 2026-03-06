import 'dart:async';

import 'package:flutter/material.dart';
import '../core/assets.dart';
import '../widgets/carousel_indicators.dart';
import '../widgets/carousel_slide_card.dart';
import '../widgets/service_card.dart';
import '../widgets/service_search_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final PageController _carouselController = PageController();
  final ScrollController _scrollController = ScrollController();
  Timer? _carouselTimer;
  bool _showStickySearch = false;

  static const double _stickyScrollThreshold = 120;

  static const List<_CarouselSlideData> _carouselSlides = [
    _CarouselSlideData(Icons.bolt, "Emergency Support",
        "Need urgent help? Get a professional at your door in one tap.", "24/7"),
    _CarouselSlideData(Icons.star, "Top Rated Pros",
        "Book verified experts with 4.8+ ratings.", "Popular"),
    _CarouselSlideData(Icons.savings, "Best Prices",
        "Transparent pricing with no hidden fees.", "Save"),
    _CarouselSlideData(Icons.verified_user, "Verified Experts",
        "All technicians are background-checked and certified.", "Trusted"),
    _CarouselSlideData(Icons.schedule, "Same Day Service",
        "Book now and get help as soon as today.", "Fast"),
    _CarouselSlideData(Icons.local_offer, "Special Offers",
        "Exclusive discounts for first-time customers.", "Deals"),
    _CarouselSlideData(Icons.home_repair_service, "Full Home Services",
        "From plumbing to painting—we do it all.", "Complete"),
    _CarouselSlideData(Icons.thumb_up, "100% Satisfaction",
        "Not happy? We'll make it right, guaranteed.", "Guarantee"),
  ];

  static const List<ServiceItem> _services = [
    ServiceItem(Icons.build, "Plumber", "Leaky pipes, clogged drains."),
    ServiceItem(Icons.electrical_services, "Electrician",
        "Wiring, outlets, lighting."),
    ServiceItem(Icons.grass, "Gardener", "Lawn care, landscaping."),
    ServiceItem(Icons.handyman, "Carpenter", "Furniture, repairs, installs."),
    ServiceItem(Icons.format_paint, "Painter", "Interior and Exterior."),
    ServiceItem(Icons.ac_unit, "AC Technician",
        "Cooling, heating, service."),
    ServiceItem(Icons.security, "ELV Repairer",
        "Security, CCTV, low voltage."),
  ];

  List<ServiceItem> get _filteredServices {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return [];
    return _services
        .where((s) =>
            s.title.toLowerCase().contains(query) ||
            s.description.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _startCarouselTimer();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showSticky =
        _scrollController.offset > _stickyScrollThreshold;
    if (showSticky != _showStickySearch) {
      setState(() => _showStickySearch = showSticky);
    }
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_carouselController.hasClients) {
        final page = _carouselController.page ?? 0;
        final next = (page.round() + 1) % _carouselSlides.length;
        _carouselController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _clearSearchAndClose() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _carouselTimer?.cancel();
    _carouselController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "How Can We Help Today?",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ServiceSearchSection(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          filteredServices: _filteredServices,
                          onChanged: () => setState(() {}),
                          onServiceSelected: _clearSearchAndClose,
                        ),
                        const SizedBox(height: 24),
                        _buildCarousel(),
                        const SizedBox(height: 12),
                        CarouselIndicators(
                          pageController: _carouselController,
                          itemCount: _carouselSlides.length,
                        ),
                        const SizedBox(height: 28),
                        _buildServicesSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  if (_showStickySearch) _buildStickySearchOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Image.asset(AppAssets.welcomeLogo, height: 36),
          const SizedBox(width: 8),
          const Text(
            "TECHNI",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky search bar overlay when user scrolls past threshold.
  Widget _buildStickySearchOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ServiceSearchSection(
          controller: _searchController,
          focusNode: _searchFocusNode,
          filteredServices: _filteredServices,
          onChanged: () => setState(() {}),
          onServiceSelected: _clearSearchAndClose,
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _carouselController,
        itemCount: _carouselSlides.length,
        itemBuilder: (context, index) {
          final slide = _carouselSlides[index];
          return CarouselSlideCard(
            icon: slide.icon,
            title: slide.title,
            subtitle: slide.subtitle,
            badge: slide.badge,
          );
        },
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final item = _services[index];
            return ServiceCard(
              icon: item.icon,
              title: item.title,
              description: item.description,
            );
          },
        ),
      ],
    );
  }
}

class _CarouselSlideData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;

  const _CarouselSlideData(
      this.icon, this.title, this.subtitle, this.badge);
}
