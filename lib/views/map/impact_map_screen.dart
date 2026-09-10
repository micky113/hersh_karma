import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_action.dart';

class ImpactMapScreen extends StatelessWidget {
  const ImpactMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🌍 ', style: TextStyle(fontSize: 20)),
            Text('Live Impact Map & Node Radar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
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
  KarmaAction? _selectedAction;
  String? _selectedCategoryFilter;

  Offset _projectCoordinates(double lat, double lng, Size canvasSize, List<KarmaAction> allPins) {
    if (allPins.isEmpty) {
      return Offset(canvasSize.width / 2, canvasSize.height / 2);
    }

    double minLat = allPins.first.latitude!;
    double maxLat = allPins.first.latitude!;
    double minLng = allPins.first.longitude!;
    double maxLng = allPins.first.longitude!;

    for (final pin in allPins) {
      if (pin.latitude! < minLat) minLat = pin.latitude!;
      if (pin.latitude! > maxLat) maxLat = pin.latitude!;
      if (pin.longitude! < minLng) minLng = pin.longitude!;
      if (pin.longitude! > maxLng) maxLng = pin.longitude!;
    }

    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();

    final safeLatSpan = latSpan < 0.01 ? 0.03 : latSpan * 1.4;
    final safeLngSpan = lngSpan < 0.01 ? 0.03 : lngSpan * 1.4;

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    final relativeX = (lng - centerLng) / (safeLngSpan / 2);
    final relativeY = (lat - centerLat) / (safeLatSpan / 2);

    final x = (canvasSize.width / 2) + (relativeX * (canvasSize.width * 0.40));
    final y = (canvasSize.height / 2) - (relativeY * (canvasSize.height * 0.38));

    return Offset(
      x.clamp(22.0, canvasSize.width - 22.0),
      y.clamp(28.0, canvasSize.height - 28.0),
    );
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

    final mapCanvas = LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = widget.isFullScreen ? 340.0 : widget.height;

        return Container(
          height: canvasHeight,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFF00B074).withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Digital Grid Radar Background
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    painter: MapGridPainter(theme: theme),
                  ),
                ),
              ),

              // 2. Header Stats Overlay
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black87 : Colors.white).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00B074).withOpacity(0.3)),
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
                            'Active Network: ${filteredPins.length} Nodes',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isFullScreen)
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/impact-map'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B074).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00B074).withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fullscreen_rounded, size: 14, color: Color(0xFF00B074)),
                              SizedBox(width: 4),
                              Text(
                                'Full Screen',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00B074),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 3. Render Coordinate Pins
              ...filteredPins.map((action) {
                final size = Size(canvasWidth, canvasHeight);
                final offset = _projectCoordinates(action.latitude!, action.longitude!, size, allPins);
                final isSelected = _selectedAction?.id == action.id;

                return Positioned(
                  left: offset.dx - 18,
                  top: offset.dy - 36,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAction = action;
                      });
                    },
                    child: AnimatedScale(
                      scale: isSelected ? 1.3 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 34,
                            color: action.status == DeedStatus.verified
                                ? action.category.color
                                : Colors.orangeAccent,
                          ),
                          Positioned(
                            top: 5,
                            child: CircleAvatar(
                              radius: 6.5,
                              backgroundColor: Colors.white,
                              child: Text(
                                action.category.icon,
                                style: const TextStyle(fontSize: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // 4. Selected Pin Details Card
              if (_selectedAction != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Card(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: const Color(0xFF00B074).withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedAction!.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _selectedAction = null),
                                child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${_selectedAction!.category.icon} ${_selectedAction!.userName}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              const Spacer(),
                              Text(
                                '+${_selectedAction!.creditsAwarded} Karma',
                                style: const TextStyle(
                                  color: Color(0xFF00B074),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAction!.description,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.gps_fixed_rounded, color: Color(0xFF00B074), size: 10),
                              const SizedBox(width: 4),
                              Text(
                                'Lat: ${_selectedAction!.latitude!.toStringAsFixed(4)}, Lon: ${_selectedAction!.longitude!.toStringAsFixed(4)}',
                                style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.blueGrey),
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
        );
      },
    );

    if (!widget.isFullScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          mapCanvas,
        ],
      );
    }

    // Full Screen Layout with Live Ticker Feed
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          mapCanvas,
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              children: [
                const Icon(Icons.sensors_rounded, color: Colors.redAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  'GLOBAL ACTION TICKER (LIVE)',
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
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: action.category.color.withOpacity(0.12),
                  child: Text(action.category.icon, style: const TextStyle(fontSize: 12)),
                ),
                title: Text(
                  '${action.userName}: ${action.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
                subtitle: Text(
                  isVerified ? 'Geotagged & Consensus Verified' : 'Awaiting Validator Consensus',
                  style: TextStyle(fontSize: 9.5, color: isVerified ? const Color(0xFF00B074) : Colors.orange),
                ),
                trailing: Text(
                  '+${action.creditsAwarded} CR',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00B074), fontSize: 11),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Custom Painter to draw a clean digital node grid
class MapGridPainter extends CustomPainter {
  final ThemeData theme;
  MapGridPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = theme.dividerColor.withOpacity(0.04)
      ..strokeWidth = 1.0;

    const double step = 20.0;
    
    // Draw vertical lines
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintGrid);
    }
    // Draw horizontal lines
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paintGrid);
    }

    // Draw grid radar overlay center circle
    final center = Offset(size.width / 2, size.height / 2);
    final paintRadar = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, size.height * 0.25, paintRadar);
    canvas.drawCircle(center, size.height * 0.40, paintRadar);
    canvas.drawLine(
      Offset(center.dx - 10, center.dy),
      Offset(center.dx + 10, center.dy),
      paintRadar..color = theme.colorScheme.primary.withOpacity(0.2),
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      paintRadar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
