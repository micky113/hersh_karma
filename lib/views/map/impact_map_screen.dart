import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_action.dart';
import '../../models/karma_category.dart';

enum MapTileStyle {
  googleRoadmap(
    label: 'Google Streets',
    shortLabel: 'Streets',
    icon: '🗺️',
    urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
    subdomains: ['0', '1', '2', '3'],
  ),
  googleSatellite(
    label: 'Google Satellite',
    shortLabel: 'Satellite',
    icon: '🛰️',
    urlTemplate: 'https://mt{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
    subdomains: ['0', '1', '2', '3'],
  ),
  googleHybrid(
    label: 'Google Hybrid',
    shortLabel: 'Hybrid',
    icon: '🌍',
    urlTemplate: 'https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
    subdomains: ['0', '1', '2', '3'],
  ),
  googleTerrain(
    label: 'Google Terrain',
    shortLabel: 'Terrain',
    icon: '🏔️',
    urlTemplate: 'https://mt{s}.google.com/vt/lyrs=p&x={x}&y={y}&z={z}',
    subdomains: ['0', '1', '2', '3'],
  ),
  darkMatter(
    label: 'Dark Mode',
    shortLabel: 'Dark',
    icon: '🌙',
    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
    subdomains: ['a', 'b', 'c', 'd'],
  );

  final String label;
  final String shortLabel;
  final String icon;
  final String urlTemplate;
  final List<String> subdomains;

  const MapTileStyle({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.urlTemplate,
    required this.subdomains,
  });
}

class ImpactMapScreen extends StatelessWidget {
  const ImpactMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🌍 ', style: TextStyle(fontSize: 20)),
            Text(
              'Google Maps Live Impact Radar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About Impact Map',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Row(
                    children: [
                      Text('🌍 ', style: TextStyle(fontSize: 20)),
                      Text('Google Maps Impact Radar'),
                    ],
                  ),
                  content: const Text(
                    'Real interactive Google Maps Roadmap, Satellite, and Hybrid imagery rendering live cryptographic deed submissions from around the world. Pan, zoom, toggle between Google Satellite & Street layers, and tap on any deed pin to view real-time proof-of-good verifications.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: const ImpactMapWidget(isFullScreen: true),
    );
  }
}

class ImpactMapWidget extends StatefulWidget {
  final bool isFullScreen;
  final double height;

  const ImpactMapWidget({
    super.key,
    this.isFullScreen = false,
    this.height = 340,
  });

  @override
  State<ImpactMapWidget> createState() => _ImpactMapWidgetState();
}

class _ImpactMapWidgetState extends State<ImpactMapWidget> {
  final MapController _mapController = MapController();
  KarmaAction? _selectedAction;
  String? _selectedCategoryFilter;
  MapTileStyle _tileStyle = MapTileStyle.googleHybrid;

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    final currentCenter = _mapController.camera.center;
    _mapController.move(currentCenter, (currentZoom + 1).clamp(2.0, 19.0));
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    final currentCenter = _mapController.camera.center;
    _mapController.move(currentCenter, (currentZoom - 1).clamp(2.0, 19.0));
  }

  void _recenterIndia() {
    _mapController.move(const LatLng(20.5937, 78.9629), 4.8);
  }

  void _recenterGlobal() {
    _mapController.move(const LatLng(20.0, 0.0), 2.5);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final karmaProvider = Provider.of<KarmaProvider>(context);

    // Filter verified or pending actions with coordinates
    final allPins = karmaProvider.allActions
        .where((e) => e.latitude != null && e.longitude != null)
        .toList();

    final filteredPins = _selectedCategoryFilter == null
        ? allPins
        : allPins.where((e) => e.category.name == _selectedCategoryFilter).toList();

    final mapBoxHeight = widget.isFullScreen ? 440.0 : widget.height;

    final mapWidget = Container(
      height: mapBoxHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B132B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFF00B074).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // 1. Google Maps FlutterMap Instance
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(20.5937, 78.9629), // Centered on India & Asia-Pacific
                initialZoom: widget.isFullScreen ? 4.0 : 3.4,
                minZoom: 2.0,
                maxZoom: 19.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (_, __) {
                  if (_selectedAction != null) {
                    setState(() {
                      _selectedAction = null;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  key: ValueKey(_tileStyle),
                  urlTemplate: _tileStyle.urlTemplate,
                  subdomains: _tileStyle.subdomains,
                  userAgentPackageName: 'com.hershkarma.app',
                  maxZoom: 20,
                  tileProvider: NetworkTileProvider(),
                ),
                MarkerLayer(
                  markers: filteredPins.map((action) {
                    final isSelected = _selectedAction?.id == action.id;
                    final isVerified = action.status == DeedStatus.verified;

                    return Marker(
                      point: LatLng(action.latitude!, action.longitude!),
                      width: isSelected ? 52 : 38,
                      height: isSelected ? 52 : 38,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAction = action;
                          });
                          _mapController.move(
                            LatLng(action.latitude!, action.longitude!),
                            _mapController.camera.zoom < 7.0 ? 7.0 : _mapController.camera.zoom,
                          );
                        },
                        child: AnimatedScale(
                          scale: isSelected ? 1.25 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isVerified ? const Color(0xFF00FF9D) : Colors.orangeAccent)
                                          .withOpacity(0.6),
                                      blurRadius: isSelected ? 14 : 6,
                                      spreadRadius: isSelected ? 4 : 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: isSelected ? 46 : 34,
                                  color: isVerified
                                      ? (isSelected ? const Color(0xFF00FF9D) : action.category.color)
                                      : Colors.orangeAccent,
                                ),
                              ),
                              Positioned(
                                top: isSelected ? 8 : 5,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
                                  ),
                                  child: Text(
                                    action.category.icon,
                                    style: TextStyle(fontSize: isSelected ? 11 : 8.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // 2. Top Header Overlay (Active Node Count & Google Maps Layer Switcher)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Active Node Count Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.94),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00B074).withOpacity(0.4)),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00B074),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Google Maps Nodes: ${filteredPins.length}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Google Maps Style Selector Dropdown / Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.94),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF00B074).withOpacity(0.35)),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: MapTileStyle.values.map((style) {
                            final isSel = _tileStyle == style;
                            return InkWell(
                              onTap: () => setState(() => _tileStyle = style),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFF00B074).withOpacity(0.2) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSel ? Border.all(color: const Color(0xFF00B074), width: 1) : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(style.icon, style: const TextStyle(fontSize: 12)),
                                    if (isSel) ...[
                                      const SizedBox(width: 3),
                                      Text(
                                        style.shortLabel,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00B074),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (!widget.isFullScreen) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/impact-map'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B074),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fullscreen_rounded, size: 15, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Full Map',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 3. Zoom & Quick Pan Controls (Right Side)
            Positioned(
              right: 10,
              bottom: _selectedAction != null ? 140 : 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlBtn(
                    icon: Icons.add_rounded,
                    tooltip: 'Zoom In',
                    onTap: _zoomIn,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _buildControlBtn(
                    icon: Icons.remove_rounded,
                    tooltip: 'Zoom Out',
                    onTap: _zoomOut,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 6),
                  _buildControlBtn(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Center India',
                    onTap: _recenterIndia,
                    isDark: isDark,
                    color: const Color(0xFF00B074),
                  ),
                  const SizedBox(height: 6),
                  _buildControlBtn(
                    icon: Icons.public_rounded,
                    tooltip: 'Global View',
                    onTap: _recenterGlobal,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // 4. Interactive Selected Deed Modal Card
            if (_selectedAction != null)
              Positioned(
                bottom: 10,
                left: 10,
                right: 56, // Leave room for side controls
                child: Card(
                  color: (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.96),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: const Color(0xFF00B074).withOpacity(0.4), width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              _selectedAction!.category.icon,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedAction!.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B074).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+${_selectedAction!.creditsAwarded} Karma',
                                style: const TextStyle(
                                  color: Color(0xFF00B074),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() => _selectedAction = null),
                              child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedAction!.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              _selectedAction!.status == DeedStatus.verified
                                  ? Icons.verified_rounded
                                  : Icons.hourglass_top_rounded,
                              color: _selectedAction!.status == DeedStatus.verified
                                  ? const Color(0xFF00B074)
                                  : Colors.orangeAccent,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedAction!.status == DeedStatus.verified
                                  ? 'Consensus Verified by ${_selectedAction!.userName}'
                                  : 'Submitted by ${_selectedAction!.userName} (Pending)',
                              style: TextStyle(
                                fontSize: 10,
                                color: _selectedAction!.status == DeedStatus.verified
                                    ? const Color(0xFF00B074)
                                    : Colors.orangeAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.gps_fixed_rounded, color: Colors.blueGrey, size: 10),
                            const SizedBox(width: 3),
                            Text(
                              '${_selectedAction!.latitude!.toStringAsFixed(3)}, ${_selectedAction!.longitude!.toStringAsFixed(3)}',
                              style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!widget.isFullScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          mapWidget,
        ],
      );
    }

    // Full Screen View with Category Filters & Live Stream Feed
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category Quick Selector Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Categories', style: TextStyle(fontSize: 11)),
                  selected: _selectedCategoryFilter == null,
                  onSelected: (val) {
                    setState(() {
                      _selectedCategoryFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 6),
                ...KarmaCategory.values.map((cat) {
                  final isSel = _selectedCategoryFilter == cat.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      avatar: Text(cat.icon, style: const TextStyle(fontSize: 11)),
                      label: Text(cat.label, style: const TextStyle(fontSize: 11)),
                      selected: isSel,
                      onSelected: (val) {
                        setState(() {
                          _selectedCategoryFilter = val ? cat.name : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          mapWidget,
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                const Icon(Icons.sensors_rounded, color: Colors.redAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'GLOBAL ACTION TICKER (LIVE STREAM)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...karmaProvider.allActions.map((action) {
            final isVerified = action.status == DeedStatus.verified;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                onTap: () {
                  if (action.latitude != null && action.longitude != null) {
                    setState(() {
                      _selectedAction = action;
                    });
                    _mapController.move(
                      LatLng(action.latitude!, action.longitude!),
                      7.0,
                    );
                  }
                },
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: action.category.color.withOpacity(0.15),
                  child: Text(action.category.icon, style: const TextStyle(fontSize: 12)),
                ),
                title: Text(
                  '${action.userName}: ${action.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
                subtitle: Text(
                  isVerified ? 'Geotagged & Consensus Verified' : 'Awaiting Validator Consensus',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isVerified ? const Color(0xFF00B074) : Colors.orange,
                  ),
                ),
                trailing: Text(
                  '+${action.creditsAwarded} CR',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B074),
                    fontSize: 11,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.92),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00B074).withOpacity(0.35)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: color ?? (isDark ? Colors.white : Colors.black87)),
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
        onPressed: onTap,
      ),
    );
  }
}
