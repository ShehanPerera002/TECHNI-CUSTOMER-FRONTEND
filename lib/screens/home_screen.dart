import 'dart:async';

import 'package:flutter/material.dart';
import '../core/assets.dart';

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

  static const List<_CarouselSlide> _carouselSlides = [
    _CarouselSlide(Icons.bolt, "Emergency Support", "Need urgent help? Get a professional at your door in one tap.", "24/7"),
    _CarouselSlide(Icons.star, "Top Rated Pros", "Book verified experts with 4.8+ ratings.", "Popular"),
    _CarouselSlide(Icons.savings, "Best Prices", "Transparent pricing with no hidden fees.", "Save"),
    _CarouselSlide(Icons.verified_user, "Verified Experts", "All technicians are background-checked and certified.", "Trusted"),
    _CarouselSlide(Icons.schedule, "Same Day Service", "Book now and get help as soon as today.", "Fast"),
    _CarouselSlide(Icons.local_offer, "Special Offers", "Exclusive discounts for first-time customers.", "Deals"),
    _CarouselSlide(Icons.home_repair_service, "Full Home Services", "From plumbing to painting—we do it all.", "Complete"),
    _CarouselSlide(Icons.thumb_up, "100% Satisfaction", "Not happy? We'll make it right, guaranteed.", "Guarantee"),
  ];

  static const List<_ServiceItem> _services = [
    _ServiceItem(Icons.build, "Plumber", "Leaky pipes, clogged drains."),
    _ServiceItem(Icons.electrical_services, "Electrician", "Wiring, outlets, lighting."),
    _ServiceItem(Icons.grass, "Gardener", "Lawn care, landscaping."),
    _ServiceItem(Icons.handyman, "Carpenter", "Furniture, repairs, installs."),
    _ServiceItem(Icons.format_paint, "Painter", "Interior and Exterior."),
    _ServiceItem(Icons.ac_unit, "AC Technician", "Cooling, heating, service."),
    _ServiceItem(Icons.security, "ELV Repairer", "Security, CCTV, low voltage."),
  ];

  List<_ServiceItem> get _filteredServices {
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
    final offset = _scrollController.offset;
    final showSticky = offset > _stickyScrollThreshold;
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
            // Header: Logo + App Name
            Padding(
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
            ),

            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // How Can We Help Today?
                    const Text(
                      "How Can We Help Today?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search Box + Dropdown Results
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        if (_searchController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildSearchDropdown(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Carousel (auto-play, 2 sec per slide)
                    SizedBox(
                      height: 180,
                      child: PageView.builder(
                        controller: _carouselController,
                        itemCount: _carouselSlides.length,
                        itemBuilder: (context, index) {
                          final slide = _carouselSlides[index];
                          return _buildCarouselCard(
                            icon: slide.icon,
                            title: slide.title,
                            subtitle: slide.subtitle,
                            badge: slide.badge,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CarouselIndicators(
                      pageController: _carouselController,
                      itemCount: _carouselSlides.length,
                    ),
                    const SizedBox(height: 28),

                    // Services Section
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
       
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Service Cards Grid (2 columns)
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
                        return _ServiceCard(
                          icon: item.icon,
                          title: item.title,
                          description: item.description,
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              if (_showStickySearch)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        if (_searchController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildSearchDropdown(),
                        ],
                      ],
                    ),
                  ),
                ),
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

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Search for a service...",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSearchDropdown() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 220),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: _filteredServices.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredServices.length,
                itemBuilder: (context, index) {
                  final item = _filteredServices[index];
                  return InkWell(
                    onTap: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  item.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCarouselCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF2563EB).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 48, color: const Color(0xFF2563EB)),
        ],
      ),
    );
  }
}

class _CarouselSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;

  const _CarouselSlide(this.icon, this.title, this.subtitle, this.badge);
}

class _CarouselIndicators extends StatefulWidget {
  final PageController pageController;
  final int itemCount;

  const _CarouselIndicators({
    required this.pageController,
    required this.itemCount,
  });

  @override
  State<_CarouselIndicators> createState() => _CarouselIndicatorsState();
}

class _CarouselIndicatorsState extends State<_CarouselIndicators> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    if (widget.pageController.hasClients) {
      final page = widget.pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.itemCount,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage ? const Color(0xFF2563EB) : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceItem(this.icon, this.title, this.description);
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF2563EB)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
