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

  Offset _projectCoordinates(double lat, double lng, Size canvasSize) {
    // Standard Global Equirectangular Projection
    // Longitude: -180 to 180 -> X: 0 to canvasWidth
    // Latitude: 80 (North) to -60 (South) -> Y: 0 to canvasHeight
    final clampedLng = lng.clamp(-180.0, 180.0);
    final clampedLat = lat.clamp(-60.0, 80.0);

    final normalizedX = (clampedLng + 180.0) / 360.0;
    // Map latitude with Mercator/Equirectangular compression for visual harmony
    final normalizedY = (80.0 - clampedLat) / 140.0;

    final x = normalizedX * canvasSize.width;
    final y = normalizedY * canvasSize.height;

    return Offset(
      x.clamp(14.0, canvasSize.width - 14.0),
      y.clamp(18.0, canvasSize.height - 18.0),
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
            color: isDark ? const Color(0xFF0B132B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFF00B074).withOpacity(0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Vector World Map Silhouette & Grid Canvas
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomPaint(
                    painter: WorldMapSilhouettePainter(theme: theme, isDark: isDark),
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
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF00B074).withOpacity(0.4)),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00B074),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Global Ledger Nodes: ${filteredPins.length}',
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
                            color: const Color(0xFF00B074).withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00B074).withOpacity(0.5)),
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

              // 3. Render Coordinate Pins over Continents
              ...filteredPins.map((action) {
                final size = Size(canvasWidth, canvasHeight);
                final offset = _projectCoordinates(action.latitude!, action.longitude!, size);
                final isSelected = _selectedAction?.id == action.id;

                return Positioned(
                  left: offset.dx - 16,
                  top: offset.dy - 30,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAction = action;
                      });
                    },
                    child: AnimatedScale(
                      scale: isSelected ? 1.35 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 32,
                            color: action.status == DeedStatus.verified
                                ? action.category.color
                                : Colors.orangeAccent,
                          ),
                          Positioned(
                            top: 5,
                            child: CircleAvatar(
                              radius: 6,
                              backgroundColor: Colors.white,
                              child: Text(
                                action.category.icon,
                                style: const TextStyle(fontSize: 7.5),
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

// Vector World Map Silhouette Painter
class WorldMapSilhouettePainter extends CustomPainter {
  final ThemeData theme;
  final bool isDark;

  WorldMapSilhouettePainter({required this.theme, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Dotted / Subtle Latitude & Longitude Coordinate Lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.cyanAccent : const Color(0xFF00B074)).withOpacity(0.06)
      ..strokeWidth = 1.0;

    // Horizontal lines (Equator, Tropics, Arctic)
    canvas.drawLine(Offset(0, h * 0.28), Offset(w, h * 0.28), gridPaint); // Tropic of Cancer ~23.5° N
    canvas.drawLine(Offset(0, h * 0.44), Offset(w, h * 0.44), gridPaint..strokeWidth = 1.2); // Equator 0°
    canvas.drawLine(Offset(0, h * 0.60), Offset(w, h * 0.60), gridPaint..strokeWidth = 1.0); // Tropic of Capricorn ~23.5° S

    // Vertical lines (Prime Meridian, Pacific, Asia)
    canvas.drawLine(Offset(w * 0.50, 0), Offset(w * 0.50, h), gridPaint); // Prime Meridian 0°
    canvas.drawLine(Offset(w * 0.25, 0), Offset(w * 0.25, h), gridPaint); // -90° W
    canvas.drawLine(Offset(w * 0.75, 0), Offset(w * 0.75, h), gridPaint); // +90° E

    // 2. Continent Landmass Silhouette Path
    final landPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E293B).withOpacity(0.9)
          : const Color(0xFFCBD5E1).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final landBorderPaint = Paint()
      ..color = (isDark ? const Color(0xFF00B074) : const Color(0xFF00B074)).withOpacity(isDark ? 0.35 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path worldPath = Path();

    // NORTH AMERICA
    final Path naPath = Path()
      ..moveTo(w * 0.08, h * 0.16) // Alaska
      ..lineTo(w * 0.14, h * 0.12)
      ..lineTo(w * 0.24, h * 0.14) // Northern Canada
      ..lineTo(w * 0.30, h * 0.18) // Hudson Bay
      ..lineTo(w * 0.34, h * 0.24) // Newfoundland / East Coast
      ..lineTo(w * 0.31, h * 0.34) // US East Coast
      ..lineTo(w * 0.28, h * 0.39) // Florida
      ..lineTo(w * 0.24, h * 0.39) // Gulf of Mexico
      ..lineTo(w * 0.21, h * 0.46) // Mexico
      ..lineTo(w * 0.24, h * 0.48) // Central America
      ..lineTo(w * 0.20, h * 0.42) // Baja California
      ..lineTo(w * 0.15, h * 0.32) // California West Coast
      ..lineTo(w * 0.11, h * 0.22) // Pacific Northwest
      ..close();
    worldPath.addPath(naPath, Offset.zero);

    // GREENLAND
    final Path greenlandPath = Path()
      ..moveTo(w * 0.35, h * 0.08)
      ..lineTo(w * 0.41, h * 0.07)
      ..lineTo(w * 0.43, h * 0.14)
      ..lineTo(w * 0.38, h * 0.18)
      ..close();
    worldPath.addPath(greenlandPath, Offset.zero);

    // SOUTH AMERICA
    final Path saPath = Path()
      ..moveTo(w * 0.25, h * 0.48) // Colombia / Venezuela
      ..lineTo(w * 0.32, h * 0.49)
      ..lineTo(w * 0.39, h * 0.56) // Brazil East Bulge
      ..lineTo(w * 0.35, h * 0.72) // Argentina / Uruguay
      ..lineTo(w * 0.30, h * 0.86) // Tierra del Fuego / Cape Horn
      ..lineTo(w * 0.27, h * 0.76) // Chile
      ..lineTo(w * 0.26, h * 0.60) // Peru
      ..close();
    worldPath.addPath(saPath, Offset.zero);

    // EUROPE
    final Path europePath = Path()
      ..moveTo(w * 0.46, h * 0.32) // Iberian Peninsula (Spain/Portugal)
      ..lineTo(w * 0.48, h * 0.24) // France / West Europe
      ..lineTo(w * 0.53, h * 0.13) // Scandinavia
      ..lineTo(w * 0.58, h * 0.14)
      ..lineTo(w * 0.60, h * 0.22) // Eastern Europe / Baltic
      ..lineTo(w * 0.56, h * 0.32) // Balkans / Greece
      ..lineTo(w * 0.52, h * 0.34) // Italy
      ..close();
    worldPath.addPath(europePath, Offset.zero);

    // BRITISH ISLES
    final Path ukPath = Path()
      ..moveTo(w * 0.47, h * 0.21)
      ..lineTo(w * 0.49, h * 0.20)
      ..lineTo(w * 0.49, h * 0.25)
      ..lineTo(w * 0.47, h * 0.24)
      ..close();
    worldPath.addPath(ukPath, Offset.zero);

    // AFRICA
    final Path africaPath = Path()
      ..moveTo(w * 0.45, h * 0.36) // Morocco / North Africa
      ..lineTo(w * 0.58, h * 0.36) // Egypt / Suez
      ..lineTo(w * 0.63, h * 0.48) // Horn of Africa (Somalia)
      ..lineTo(w * 0.60, h * 0.65) // East Africa / Mozambique
      ..lineTo(w * 0.54, h * 0.76) // South Africa
      ..lineTo(w * 0.50, h * 0.66) // Namibia / Angola
      ..lineTo(w * 0.46, h * 0.52) // Gulf of Guinea / West Africa
      ..lineTo(w * 0.43, h * 0.44) // Senegal
      ..close();
    worldPath.addPath(africaPath, Offset.zero);

    // MADAGASCAR
    final Path madagascarPath = Path()
      ..moveTo(w * 0.62, h * 0.65)
      ..lineTo(w * 0.64, h * 0.65)
      ..lineTo(w * 0.63, h * 0.73)
      ..lineTo(w * 0.61, h * 0.72)
      ..close();
    worldPath.addPath(madagascarPath, Offset.zero);

    // ASIA & SIBERIA
    final Path asiaPath = Path()
      ..moveTo(w * 0.59, h * 0.36) // Middle East / Turkey
      ..lineTo(w * 0.63, h * 0.38) // Arabian Peninsula
      ..lineTo(w * 0.61, h * 0.46) // Yemen / Oman
      ..lineTo(w * 0.67, h * 0.40) // Iran / Pakistan
      ..lineTo(w * 0.70, h * 0.44) // North India
      ..lineTo(w * 0.72, h * 0.54) // South India (Cape Comorin)
      ..lineTo(w * 0.75, h * 0.44) // Bay of Bengal / East India
      ..lineTo(w * 0.78, h * 0.50) // Southeast Asia / Indochina
      ..lineTo(w * 0.82, h * 0.44) // South China Coast
      ..lineTo(w * 0.85, h * 0.35) // East China / Korea
      ..lineTo(w * 0.89, h * 0.22) // Russian Far East / Kamchatka
      ..lineTo(w * 0.82, h * 0.12) // Arctic Siberia
      ..lineTo(w * 0.65, h * 0.12) // Ural Mountains
      ..lineTo(w * 0.60, h * 0.24) // Central Asia / Caspian
      ..close();
    worldPath.addPath(asiaPath, Offset.zero);

    // SRI LANKA
    final Path sriLankaPath = Path()
      ..moveTo(w * 0.72, h * 0.56)
      ..lineTo(w * 0.73, h * 0.56)
      ..lineTo(w * 0.725, h * 0.58)
      ..close();
    worldPath.addPath(sriLankaPath, Offset.zero);

    // JAPAN
    final Path japanPath = Path()
      ..moveTo(w * 0.86, h * 0.28)
      ..lineTo(w * 0.88, h * 0.31)
      ..lineTo(w * 0.86, h * 0.36)
      ..lineTo(w * 0.85, h * 0.33)
      ..close();
    worldPath.addPath(japanPath, Offset.zero);

    // INDONESIA & PHILIPPINES
    final Path seAsiaIslands = Path()
      ..moveTo(w * 0.79, h * 0.56)
      ..lineTo(w * 0.83, h * 0.56)
      ..lineTo(w * 0.85, h * 0.59)
      ..lineTo(w * 0.80, h * 0.58)
      ..close();
    worldPath.addPath(seAsiaIslands, Offset.zero);

    // AUSTRALIA
    final Path australiaPath = Path()
      ..moveTo(w * 0.81, h * 0.69) // Northwest Australia
      ..lineTo(w * 0.86, h * 0.67) // Darwin / North
      ..lineTo(w * 0.89, h * 0.72) // Queensland / East Coast
      ..lineTo(w * 0.88, h * 0.81) // Sydney / Melbourne
      ..lineTo(w * 0.82, h * 0.80) // Adelaide / South Coast
      ..lineTo(w * 0.79, h * 0.75) // Perth / West Coast
      ..close();
    worldPath.addPath(australiaPath, Offset.zero);

    // NEW ZEALAND
    final Path nzPath = Path()
      ..moveTo(w * 0.92, h * 0.79)
      ..lineTo(w * 0.94, h * 0.82)
      ..lineTo(w * 0.93, h * 0.85)
      ..lineTo(w * 0.91, h * 0.82)
      ..close();
    worldPath.addPath(nzPath, Offset.zero);

    // 3. Draw Continents with Glow Effect
    canvas.drawPath(worldPath, landPaint);
    canvas.drawPath(worldPath, landBorderPaint);

    // 4. Solarpunk / Cyber Radar Nodes Pulse
    final radarPaint = Paint()
      ..color = const Color(0xFF00B074).withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(w * 0.72, h * 0.50), 22, radarPaint); // India node pulse
    canvas.drawCircle(Offset(w * 0.20, h * 0.35), 22, radarPaint); // US node pulse
    canvas.drawCircle(Offset(w * 0.51, h * 0.26), 18, radarPaint); // Europe node pulse
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
