import 'package:flutter/material.dart';

/// Search bar with dropdown showing filtered services.
/// Displays "No results found" when no services match the query.
class ServiceSearchSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<ServiceItem> filteredServices;
  final VoidCallback onChanged;
  final void Function(ServiceItem item)? onServiceSelected;

  const ServiceSearchSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.filteredServices,
    required this.onChanged,
    this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        if (hasQuery) ...[const SizedBox(height: 8), _buildDropdown()],
      ],
    );
  }

  Widget _buildSearchBar() {
    final hasQuery = controller.text.trim().isNotEmpty;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: (_) => onChanged(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: "Search for a service...",
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
        suffixIcon: hasQuery
            ? IconButton(
                icon: Icon(Icons.close, color: Colors.grey.shade600),
                onPressed: () {
                  controller.clear();
                  focusNode.unfocus();
                  onChanged();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
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
        child: filteredServices.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    "No results found",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: filteredServices.length,
                itemBuilder: (context, index) {
                  final item = filteredServices[index];
                  return InkWell(
                    onTap: () => onServiceSelected?.call(item),
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
}

/// Data model for a service category.
class ServiceItem {
  final IconData icon;
  final String title;
  final String description;

  const ServiceItem(this.icon, this.title, this.description);
}
