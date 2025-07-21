import 'package:flutter/material.dart';

class CustomMainMenuCard extends StatefulWidget {
  final String title;
  final String description;
  final String imageAsset;
  final VoidCallback? onTap;

  const CustomMainMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageAsset,
    this.onTap,
  });

  @override
  State<CustomMainMenuCard> createState() => _CustomMainMenuCardState();
}

class _CustomMainMenuCardState extends State<CustomMainMenuCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.04 : 1.0,
        duration: Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          width: 400,
          height: 270,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.25 : 0.13),
                blurRadius: isHovered ? 30 : 16,
                offset: Offset(0, 8),
              ),
            ],
            // HAPUS: transform property
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Stack(
              children: [
                // Background image
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    widget.imageAsset,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // Gradient overlay (bottom for text)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        stops: [0.5, 1],
                      ),
                    ),
                  ),
                ),
                // Title & Description
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black38,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Hover effect: semi-transparent overlay
                if (isHovered)
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 120),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
