import 'package:flutter/material.dart';

/// Page indicators for PageView carousel. Highlights the active dot based on
/// [pageController] scroll position.
class CarouselIndicators extends StatefulWidget {
  final PageController pageController;
  final int itemCount;

  const CarouselIndicators({
    super.key,
    required this.pageController,
    required this.itemCount,
  });

  @override
  State<CarouselIndicators> createState() => _CarouselIndicatorsState();
}

class _CarouselIndicatorsState extends State<CarouselIndicators> {
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
            color: i == _currentPage
                ? const Color(0xFF2563EB)
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}
