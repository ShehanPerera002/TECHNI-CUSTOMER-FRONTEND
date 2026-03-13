import 'dart:async';

import 'package:flutter/material.dart';
import '../core/assets.dart';
import '../models/service_detail_data.dart';
import '../widgets/carousel_indicators.dart';
import '../widgets/carousel_slide_card.dart';
import '../widgets/service_card.dart';
import '../widgets/service_search_section.dart';
import 'service_detail_screen.dart';

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
    _CarouselSlideData(
      Icons.bolt,
      "Emergency Support",
      "Need urgent help? Get a professional at your door in one tap.",
      "24/7",
    ),
    _CarouselSlideData(
      Icons.star,
      "Top Rated Pros",
      "Book verified experts with 4.8+ ratings.",
      "Popular",
    ),
    _CarouselSlideData(
      Icons.savings,
      "Best Prices",
      "Transparent pricing with no hidden fees.",
      "Save",
    ),
    _CarouselSlideData(
      Icons.verified_user,
      "Verified Experts",
      "All technicians are background-checked and certified.",
      "Trusted",
    ),
    _CarouselSlideData(
      Icons.schedule,
      "Same Day Service",
      "Book now and get help as soon as today.",
      "Fast",
    ),
    _CarouselSlideData(
      Icons.local_offer,
      "Special Offers",
      "Exclusive discounts for first-time customers.",
      "Deals",
    ),
    _CarouselSlideData(
      Icons.home_repair_service,
      "Full Home Services",
      "From plumbing to painting—we do it all.",
      "Complete",
    ),
    _CarouselSlideData(
      Icons.thumb_up,
      "100% Satisfaction",
      "Not happy? We'll make it right, guaranteed.",
      "Guarantee",
    ),
  ];

  static const List<ServiceDetailData> _services = [
    ServiceDetailData(
      icon: Icons.build,
      title: "Plumber",
      description: "Leaky pipes, clogged drains.",
      pageTitle: "Plumbing Services",
      serviceTitle: "Expert Plumbing Solutions",
      fullDescription:
          "For fixing leaky faucets, clogged drains, toilet repairs, and water heater issues. Our certified plumbers are ready to tackle any problem, big or small, ensuring your place's plumbing runs smoothly.",
      inspectionFee: "Rs 400",
      hourlyRate: "Rs 200 / hr",
      materials: "At Cost",
      ctaText: "Find a Plumber",
      issueHint:
          "Describe your plumbing issue... e.g. leaking pipe, clogged drain, toilet repair",
      exampleIssues: [
        "Leaking pipe",
        "Clogged drain",
        "Water heater not working",
        "Toilet repair",
        "Low water pressure",
      ],
    ),
    ServiceDetailData(
      icon: Icons.electrical_services,
      title: "Electrician",
      description: "Wiring, outlets, lighting.",
      pageTitle: "Electrical Services",
      serviceTitle: "Professional Electrical Solutions",
      fullDescription:
          "From wiring and outlets to lighting installations and electrical repairs. Our licensed electricians ensure safe, reliable power throughout your home or business.",
      inspectionFee: "Rs 500",
      hourlyRate: "Rs 250 / hr",
      materials: "At Cost",
      ctaText: "Find an Electrician",
      issueHint:
          "Describe your electrical issue... e.g. wiring, outlet, lighting, fuse",
      exampleIssues: [
        "Flickering lights",
        "Outlet not working",
        "Wiring repair",
        "Circuit breaker trips",
        "Light installation",
      ],
    ),
    ServiceDetailData(
      icon: Icons.grass,
      title: "Gardener",
      description: "Lawn care, landscaping.",
      pageTitle: "Gardening Services",
      serviceTitle: "Expert Lawn & Landscaping",
      fullDescription:
          "Lawn care, landscaping, pruning, and garden maintenance. Keep your outdoor space beautiful and well-maintained with our experienced gardeners.",
      inspectionFee: "Rs 350",
      hourlyRate: "Rs 180 / hr",
      materials: "At Cost",
      ctaText: "Find a Gardener",
      issueHint:
          "Describe your garden needs... e.g. lawn mowing, pruning, landscaping",
      exampleIssues: [
        "Lawn mowing",
        "Hedge pruning",
        "Weeding",
        "Garden design",
        "Plant care",
      ],
    ),
    ServiceDetailData(
      icon: Icons.handyman,
      title: "Carpenter",
      description: "Furniture, repairs, installs.",
      pageTitle: "Carpentry Services",
      serviceTitle: "Skilled Carpentry & Repairs",
      fullDescription:
          "Furniture repairs, installations, custom woodwork, and general carpentry. Our craftsmen bring quality and precision to every project.",
      inspectionFee: "Rs 450",
      hourlyRate: "Rs 220 / hr",
      materials: "At Cost",
      ctaText: "Find a Carpenter",
      issueHint:
          "Describe your carpentry need... e.g. furniture repair, door, cabinet",
      exampleIssues: [
        "Furniture repair",
        "Door installation",
        "Cabinet repair",
        "Custom shelving",
        "Wood finishing",
      ],
    ),
    ServiceDetailData(
      icon: Icons.format_paint,
      title: "Painter",
      description: "Interior and Exterior.",
      pageTitle: "Painting Services",
      serviceTitle: "Interior & Exterior Painting",
      fullDescription:
          "Transform your space with professional interior and exterior painting. From touch-ups to full repaints, we deliver a flawless finish.",
      inspectionFee: "Rs 400",
      hourlyRate: "Rs 200 / hr",
      materials: "At Cost",
      ctaText: "Find a Painter",
      issueHint: "Describe your painting need... e.g. room, exterior, touch-up",
      exampleIssues: [
        "Interior room",
        "Exterior walls",
        "Touch-up",
        "Full repaint",
        "Color change",
      ],
    ),
    ServiceDetailData(
      icon: Icons.ac_unit,
      title: "AC Technician",
      description: "Cooling, heating, service.",
      pageTitle: "AC Services",
      serviceTitle: "AC Repair & Maintenance",
      fullDescription:
          "Cooling, heating, and full AC service. Our technicians handle installations, repairs, and regular maintenance to keep you comfortable year-round.",
      inspectionFee: "Rs 500",
      hourlyRate: "Rs 250 / hr",
      materials: "At Cost",
      ctaText: "Find an AC Technician",
      issueHint: "Describe your AC issue... e.g. not cooling, leaking, noisy",
      exampleIssues: [
        "Not cooling",
        "AC leaking",
        "Noisy unit",
        "Installation",
        "Gas recharge",
      ],
    ),
    ServiceDetailData(
      icon: Icons.security,
      title: "ELV Repairer",
      description: "Security, CCTV, low voltage.",
      pageTitle: "ELV Services",
      serviceTitle: "Security & Low Voltage Solutions",
      fullDescription:
          "Security systems, CCTV installation, and low voltage repairs. Keep your property secure with our expert ELV technicians.",
      inspectionFee: "Rs 550",
      hourlyRate: "Rs 280 / hr",
      materials: "At Cost",
      ctaText: "Find an ELV Repairer",
      issueHint: "Describe your ELV issue... e.g. CCTV, alarm, doorbell",
      exampleIssues: [
        "CCTV not working",
        "Alarm repair",
        "Doorbell install",
        "Camera setup",
        "System upgrade",
      ],
    ),
  ];

  List<ServiceDetailData> get _filteredServices {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return [];
    return _services
        .where(
          (s) =>
              s.title.toLowerCase().contains(query) ||
              s.description.toLowerCase().contains(query) ||
              s.fullDescription.toLowerCase().contains(query) ||
              s.exampleIssues.any(
                (issue) => issue.toLowerCase().contains(query),
              ),
        )
        .toList();
  }

  bool get _isSearching => _searchController.text.trim().isNotEmpty;

  List<ServiceDetailData> get _gridServices {
    if (!_isSearching) return _services;
    return _filteredServices;
  }

  @override
  void initState() {
    super.initState();
    _startCarouselTimer();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final showSticky = _scrollController.offset > _stickyScrollThreshold;
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

  void _onServiceSelected(ServiceItem item) {
    if (item is ServiceDetailData) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceDetailScreen(service: item),
        ),
      );
    }
    _clearSearchAndClose();
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
    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _clearSearchAndClose();
        }
      },
      child: Scaffold(
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
                            onServiceSelected: _onServiceSelected,
                          ),
                          const SizedBox(height: 24),
                          if (!_isSearching) ...[
                            _buildCarousel(),
                            const SizedBox(height: 12),
                            CarouselIndicators(
                              pageController: _carouselController,
                              itemCount: _carouselSlides.length,
                            ),
                            const SizedBox(height: 28),
                          ],
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
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 0, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          AppAssets.welcomeLogo,
          height: 120,
          fit: BoxFit.contain,
        ),
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
          onServiceSelected: _onServiceSelected,
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
          itemCount: _gridServices.length,
          itemBuilder: (context, index) {
            final item = _gridServices[index];
            return ServiceCard(
              icon: item.icon,
              title: item.title,
              description: item.description,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailScreen(service: item),
                ),
              ),
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

  const _CarouselSlideData(this.icon, this.title, this.subtitle, this.badge);
}
