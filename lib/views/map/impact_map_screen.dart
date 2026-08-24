import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/karma_provider.dart';
import '../../models/karma_action.dart';

class ImpactMapScreen extends StatefulWidget {
  const ImpactMapScreen({super.key});

  @override
  State<ImpactMapScreen> createState() => _ImpactMapScreenState();
}

class _ImpactMapScreenState extends State<ImpactMapScreen> {
  KarmaAction? _selectedAction;

  // Custom coordinate projections to fit the canvas card
  // Map longitude to X coordinate [-180, 180] -> [20, canvasWidth - 20]
  // Map latitude to Y coordinate [-90, 90] -> [canvasHeight - 20, 20]
  Offset _projectCoordinates(double lat, double lng, Size canvasSize) {
    // Offset baseline for mock visual center
    // Let's standardise our coordinates around John/Jane seeds (37.77, -122.41 SF area)
    // We want a zoomed-in focus around the Bay Area/California to make the pins separate beautifully!
    // Center point: (37.775, -122.418)
    const centerLat = 37.7750;
    const centerLng = -122.4190;
    
    // Zoom factor: degree of coordinates mapped to canvas pixels
    const latSpan = 0.005; // 0.005 degrees span
    const lngSpan = 0.006;
    
    final relativeX = (lng - centerLng) / lngSpan; // value in range [-1, 1] approximately
    final relativeY = (lat - centerLat) / latSpan; // value in range [-1, 1] approximately
    
    final x = (canvasSize.width / 2) + (relativeX * (canvasSize.width * 0.4));
    final y = (canvasSize.height / 2) - (relativeY * (canvasSize.height * 0.4));
    
    return Offset(
      x.clamp(15.0, canvasSize.width - 15.0),
      y.clamp(15.0, canvasSize.height - 15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karmaProvider = Provider.of<KarmaProvider>(context);

    // Filter only verified actions containing coordinates
    final verifiedPins = karmaProvider.allActions
        .where((e) => e.status == DeedStatus.verified && e.latitude != null && e.longitude != null)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasHeight = constraints.maxHeight * 0.55;
        final listHeight = constraints.maxHeight * 0.40;

        return Column(
          children: [
            // Map Canvas Container
            Container(
              height: canvasHeight,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Stack(
                children: [
                  // Stylized Grid Canvas background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MapGridPainter(theme: theme),
                    ),
                  ),

                  // Overlay Header showing stats
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.cardColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hub_rounded, color: Color(0xFF00B074), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Active Area Network: ${verifiedPins.length} Nodes',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Draw Pins
                  ...verifiedPins.map((action) {
                    final size = Size(constraints.maxWidth - 24, canvasHeight);
                    final offset = _projectCoordinates(action.latitude!, action.longitude!, size);
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
                                size: 36,
                                color: action.category.color,
                              ),
                              Positioned(
                                top: 6,
                                child: CircleAvatar(
                                  radius: 7,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    action.category.icon,
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Selected Pin Detail Overlay Card
                  if (_selectedAction != null)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Card(
                        color: theme.cardColor.withOpacity(0.95),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'By ${_selectedAction!.userName} • ${_selectedAction!.category.icon} ${_selectedAction!.category.label}',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '+${_selectedAction!.creditsAwarded} Credits',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedAction!.description,
                                style: const TextStyle(fontSize: 11),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.gps_fixed_rounded, color: theme.colorScheme.primary, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    'GPS Coords: ${_selectedAction!.latitude!.toStringAsFixed(4)}, ${_selectedAction!.longitude!.toStringAsFixed(4)}',
                                    style: const TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.blueGrey),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Live Action Ticker list header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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

            // Live list stream
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: karmaProvider.allActions.length,
                itemBuilder: (context, index) {
                  final action = karmaProvider.allActions[index];
                  final isVerified = action.status == DeedStatus.verified;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: action.category.color.withOpacity(0.12),
                        child: Text(action.category.icon, style: const TextStyle(fontSize: 14)),
                      ),
                      title: Text(
                        '${action.userName} logged "${action.title}"',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      subtitle: Text(
                        isVerified
                            ? 'Consensus reached. Block minted, reputation boosted +2.'
                            : 'Awaiting node witnesses inside the community validator pool.',
                        style: TextStyle(fontSize: 10, color: isVerified ? const Color(0xFF00B074) : Colors.orange),
                      ),
                      trailing: Text(
                        isVerified ? '+${action.creditsAwarded} CR' : 'PENDING',
                        style: TextStyle(
                          color: isVerified ? const Color(0xFF00B074) : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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
