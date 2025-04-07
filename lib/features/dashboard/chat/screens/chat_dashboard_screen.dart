import 'package:flutter/material.dart';

class ChatDashboard extends StatefulWidget {
  const ChatDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatDashboardState createState() => _ChatDashboardState();
}

class _ChatDashboardState extends State<ChatDashboard> {
  int? _hoveredIndex; // Tracks the index of the hovered item
  bool _isHovering = false; // Tracks if the mouse is still hovering
  final Map<int, GlobalKey> _itemKeys = {}; // Keys for each list item
  Offset? _hoveredItemPosition; // Position of the hovered item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Dismiss the container when tapping anywhere outside
          setState(() {
            _hoveredIndex = null;
            _hoveredItemPosition = null;
            _isHovering = false;
          });
        },
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: true,
                  pinned: true,
                  snap: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Chat Dashboard'),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Handle search action
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        // Handle settings action
                      },
                    ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      // Create a unique key for each list item
                      if (!_itemKeys.containsKey(index)) {
                        _itemKeys[index] = GlobalKey();
                      }

                      return MouseRegion(
                        cursor: SystemMouseCursors.help,
                        onEnter: (_) {
                          final renderBox = _itemKeys[index]!
                              .currentContext!
                              .findRenderObject() as RenderBox;
                          final position =
                              renderBox.localToGlobal(Offset.zero);

                          setState(() {
                            _hoveredIndex = index;
                            _hoveredItemPosition = position;
                            _isHovering = true;
                          });
                        },
                        onExit: (_) {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (!_isHovering) {
                              setState(() {
                                _hoveredIndex = null;
                                _hoveredItemPosition = null;
                              });
                            }
                          });
                        },
                        child: ListTile(
                          key: _itemKeys[index], // Assign key to each ListTile
                          title: Text('Chat Item $index'),
                          subtitle: const Text('Subtitle'),
                          onTap: () {
                            // Handle chat item tap
                          },
                        ),
                      );
                    },
                    childCount: 20, // Number of chat items
                  ),
                ),
              ],
            ),
            if (_hoveredIndex != null && _hoveredItemPosition != null)
              Positioned(
                top:
                    _hoveredItemPosition!.dy + 60, // Place container below the item
                left:
                    MediaQuery.of(context).size.width / 2 - 100, // Center horizontally
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() => _isHovering = true);
                  },
                  onExit: (_) {
                    setState(() => _isHovering = false);
                  },
                  child: Container(
                    height: 300,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hovered Item $_hoveredIndex',
                            style:
                                const TextStyle(color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Additional Info Here',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
