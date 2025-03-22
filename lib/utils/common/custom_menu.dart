import 'dart:math';
import 'package:flutter/material.dart';

class CircularMenu extends StatefulWidget {
  final List<IconData> menuItems;
  final Color mainButtonColor;
  final Color itemButtonColor;
  final Color iconColor;
  final double buttonSize;
  final double itemButtonSize;

  const CircularMenu({
    super.key,
    required this.menuItems,
    this.mainButtonColor = Colors.blue,
    this.itemButtonColor = Colors.white,
    this.iconColor = Colors.blue,
    this.buttonSize = 60.0,
    this.itemButtonSize = 50.0,
  });

  @override
  State<CircularMenu> createState() => _CircularMenuState();
}

class _CircularMenuState extends State<CircularMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.buttonSize * 4,
      height: widget.buttonSize * 4,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Menu items
          ..._buildMenuItems(),
          
          // Main button
          Tooltip(
            margin: const EdgeInsets.all(10.0),
            message: 'Accessibility Menu',
            child: InkWell(
              hoverColor: Colors.transparent  ,
              onTap: _toggleMenu,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // button rotation-animation
                  return Transform.rotate(
                    angle: _rotationAnimation.value * pi * 2,
                    child: Container(
                      width: widget.buttonSize,
                      height: widget.buttonSize,
                      decoration: BoxDecoration(
                        color: widget.mainButtonColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isOpen ? Icons.close : Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> items = [];
    final int count = widget.menuItems.length;
    
    // We want to spread the items in a semi-circle (180 degrees)
    final double angleBetweenItems = pi / (count + 1);
    final double radius = widget.buttonSize * 1.5;

    for (int i = 0; i < count; i++) {
      final double angle = pi - (i + 2.5) * angleBetweenItems;
      
      items.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                -radius * sin(angle) * _scaleAnimation.value,
                -radius * cos(angle) * _scaleAnimation.value,
              ),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _scaleAnimation.value,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      print('Tapped item ${i + 1}');
                      _toggleMenu();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10.0),
                      width: widget.itemButtonSize,
                      height: widget.itemButtonSize,
                      decoration: BoxDecoration(
                        color: widget.itemButtonColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.menuItems[i],
                        color: widget.iconColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return items;
  }
}
