import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

void main() {
  runApp(const TransitApp());
}

class TransitApp extends StatelessWidget {
  const TransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transit UI',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const MainScreen(),
    );
  }
}

// ------------------------------------------------------------------------
// 1. MAIN SCREEN (MAP + BOTTOM SHEET)
// ------------------------------------------------------------------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // LAYER 1: Organic City Map Painter
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 4.0,
              minScale: 0.5,
              boundaryMargin: const EdgeInsets.all(800),
              constrained: false,
              child: SizedBox(
                width: 2000,
                height: 2000,
                child: CustomPaint(painter: GridMapPainter()),
              ),
            ),
          ),

          // LAYER 2: Floating Map Controls
          Positioned(
            top: 60,
            left: 16,
            child: _buildTogglePill(icon: Icons.threed_rotation, label: '3D'),
          ),
          Positioned(
            bottom: 350,
            left: 0,
            right: 0,
            child: Center(
              child: _buildTogglePill(
                icon: Icons.directions_bus,
                label: 'Bus Tracking live',
              ),
            ),
          ),

          // LAYER 3: Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 20),
                          Icon(Icons.search, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Search "Bus Route"',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTransportIcon(
                          Icons.directions_bus,
                          'Bus',
                          Colors.amber[200]!,
                        ),
                        _buildTransportIcon(
                          Icons.train,
                          'Train',
                          Colors.green[200]!,
                        ),
                        _buildTransportIcon(
                          Icons.tram,
                          'Metro',
                          Colors.blue[200]!,
                        ),
                        _buildTransportIcon(
                          Icons.local_taxi,
                          'Auto/Cab',
                          Colors.purple[200]!,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      // LAYER 4: Custom Floating Action Button (Navigates to Manual Entry)
      floatingActionButton: SizedBox(
        width: 120,
        height: 60,
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () {
            // TRIGGER NAVIGATION HERE
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManualEntryScreen(),
              ),
            );
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.white),
              SizedBox(height: 4),
              Text(
                "BUS OTP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // LAYER 5: Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red[600],
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.horizontal_rule),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Passes'),
          BottomNavigationBarItem(icon: Icon(Icons.adjust), label: 'Live'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTogglePill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.all(2),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color,
          child: Icon(icon, color: Colors.black87, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------------
// 2. NEW: MANUAL ENTRY SCREEN (OTP/TICKET BOOKING)
// ------------------------------------------------------------------------
class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  String enteredCode = "";
  final int maxCodeLength = 5;

  void _onKeyPress(String value) {
    setState(() {
      if (enteredCode.length < maxCodeLength) {
        enteredCode += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (enteredCode.isNotEmpty) {
        enteredCode = enteredCode.substring(0, enteredCode.length - 1);
      }
    });
  }

  void _onClear() {
    setState(() {
      enteredCode = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = enteredCode.length == maxCodeLength;

    return Scaffold(
      backgroundColor: Colors.black, // Top status bar area matching screenshot
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Row (Back Button & Scan QR Pill)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Scan QR",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 40,
                  ), // Balance the back button for true center
                ],
              ),
            ),

            // Main White Body Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Custom Banner Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Blue section
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(11),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "****",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            // Text section
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book,
                                      color: Colors.orange[300],
                                      size: 30,
                                    ), // Placeholder for Thiruvalluvar image
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        "தெய்வத்தான் ஆகா தெனினும் முயற்சிதன்\nமெய்வருத்தக் கூலி தரும்",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black87,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Code Input Display Slots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(maxCodeLength, (index) {
                        bool hasValue = index < enteredCode.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: hasValue
                              ? Container(
                                  width: 55,
                                  height: 75,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    enteredCode[index],
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 45,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                        );
                      }),
                    ),
                    const SizedBox(height: 40),

                    // Dynamic Submit Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isComplete
                                ? Colors.blue[700]
                                : Colors.grey[350],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isComplete
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TicketBookingScreen(
                                        ticketCode: enteredCode,
                                      ),
                                    ),
                                  );
                                  /* Handle Booking Action */
                                }
                              : null,
                          child: Text(
                            "Book Bus ticket >>",
                            style: TextStyle(
                              color: isComplete ? Colors.white : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Custom Keyboard Area
                    Container(
                      padding: const EdgeInsets.only(bottom: 40, top: 20),
                      decoration: const BoxDecoration(
                        color: Color(
                          0xFFFAFAFA,
                        ), // Very light grey backing for keyboard
                      ),
                      child: Column(
                        children: [
                          // Top Row: Letter Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: ['I', 'S', 'J', 'K', 'L'].map((letter) {
                              return GestureDetector(
                                onTap: () => _onKeyPress(letter),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Numpad Grid
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                            ),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              childAspectRatio: 1.5,
                              children: [
                                _buildNumKey('1'),
                                _buildNumKey('2'),
                                _buildNumKey('3'),
                                _buildNumKey('4'),
                                _buildNumKey('5'),
                                _buildNumKey('6'),
                                _buildNumKey('7'),
                                _buildNumKey('8'),
                                _buildNumKey('9'),

                                // Bottom Row Special Keys
                                GestureDetector(
                                  onTap: _onClear,
                                  child: const Center(
                                    child: Text(
                                      "Clear",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                _buildNumKey('0'),
                                GestureDetector(
                                  onTap: _onBackspace,
                                  child: const Center(
                                    child: Icon(
                                      Icons.backspace_outlined,
                                      color: Colors.grey,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumKey(String number) {
    return GestureDetector(
      onTap: () => _onKeyPress(number),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// 3. ORGANIC CITY MAP PAINTER
// ------------------------------------------------------------------------
class GridMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBackground = Paint()..color = const Color(0xFFF9F6F0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paintBackground,
    );

    final paintPark = Paint()..color = const Color(0xFFD4EDDA);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(250, 150, 300, 220),
        const Radius.circular(24),
      ),
      paintPark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(950, 750, 450, 280),
        const Radius.circular(24),
      ),
      paintPark,
    );
    canvas.drawCircle(const Offset(1450, 320), 140, paintPark);

    final paintBlock = Paint()..color = const Color(0xFFEAEAEA);
    final paintBlockOutline = Paint()
      ..color = const Color(0xFFDDDCDA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    void drawCityBlock(double x, double y, double w, double h) {
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), paintBlock);
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), paintBlockOutline);
    }

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 4; j++) {
        drawCityBlock(60.0 + i * 110, 480.0 + j * 90, 85, 65);
      }
    }

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        drawCityBlock(1150.0 + i * 130, 140.0 + j * 95, 100, 70);
      }
    }

    final paintRiver = Paint()
      ..color = const Color(0xFFCDEBFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 75.0
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(-50, size.height * 0.18)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.04,
        size.width * 0.38,
        size.height * 0.48,
        size.width + 50,
        size.height * 0.38,
      );
    canvas.drawPath(riverPath, paintRiver);

    final paintStreet = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0;

    canvas.drawLine(const Offset(520, 0), const Offset(520, 2000), paintStreet);
    canvas.drawLine(
      const Offset(1050, 0),
      const Offset(1050, 2000),
      paintStreet,
    );
    canvas.drawLine(const Offset(0, 420), const Offset(2000, 420), paintStreet);
    canvas.drawLine(
      const Offset(0, 1150),
      const Offset(2000, 1150),
      paintStreet,
    );

    final paintMainRoad = Paint()
      ..color = const Color(0xFF6C757D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32.0
      ..strokeCap = StrokeCap.round;

    final paintInnerRoad = Paint()
      ..color = const Color(0xFF8A9298)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28.0
      ..strokeCap = StrokeCap.round;

    final roadPath = Path()
      ..moveTo(120, 0)
      ..lineTo(120, 800)
      ..quadraticBezierTo(120, 1020, 420, 1020)
      ..lineTo(1550, 1020)
      ..quadraticBezierTo(1780, 1020, 1780, 1280)
      ..lineTo(1780, 2000);

    canvas.drawPath(roadPath, paintMainRoad);
    canvas.drawPath(roadPath, paintInnerRoad);

    final paintBusRoute = Paint()
      ..color = const Color(0xFF9B5DE5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final busRoutePath = Path()
      ..moveTo(120, 220)
      ..lineTo(120, 800)
      ..quadraticBezierTo(120, 1020, 420, 1020)
      ..lineTo(1250, 1020);

    canvas.drawPath(busRoutePath, paintBusRoute);

    void renderBusStop(Offset coordinates, String stationName) {
      canvas.drawCircle(
        coordinates,
        12.0,
        Paint()..color = const Color(0xFF9B5DE5),
      );
      canvas.drawCircle(coordinates, 5.0, Paint()..color = Colors.white);

      final textPainter = TextPainter(
        text: TextSpan(
          text: stationName,
          style: const TextStyle(
            color: Color(0xFF212529),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(coordinates.dx + 18, coordinates.dy - 6),
      );
    }

    renderBusStop(const Offset(120, 360), "Pattabiram E-Depot");
    renderBusStop(const Offset(120, 720), "TNEB Office Junction");
    renderBusStop(const Offset(580, 1020), "Vengal Crossing");
    renderBusStop(const Offset(1120, 1020), "Amrita Campus Entrance");

    final Offset busTargetCoordinates = const Offset(580, 1020);
    final paintBusChassis = Paint()..color = const Color(0xFF007BFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: busTargetCoordinates, width: 44, height: 24),
        const Radius.circular(6),
      ),
      paintBusChassis,
    );

    final paintWindows = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(
        busTargetCoordinates.dx - 16,
        busTargetCoordinates.dy - 7,
        7,
        6,
      ),
      paintWindows,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        busTargetCoordinates.dx - 4,
        busTargetCoordinates.dy - 7,
        7,
        6,
      ),
      paintWindows,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        busTargetCoordinates.dx + 8,
        busTargetCoordinates.dy - 7,
        7,
        6,
      ),
      paintWindows,
    );

    final paintWheels = Paint()..color = const Color(0xFF343A40);
    canvas.drawCircle(
      Offset(busTargetCoordinates.dx - 12, busTargetCoordinates.dy + 12),
      4.5,
      paintWheels,
    );
    canvas.drawCircle(
      Offset(busTargetCoordinates.dx + 12, busTargetCoordinates.dy + 12),
      4.5,
      paintWheels,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ------------------------------------------------------------------------
// 4. TICKET BOOKING SCREEN (FINAL CHECKOUT)
// ------------------------------------------------------------------------
class TicketBookingScreen extends StatefulWidget {
  final String ticketCode;

  const TicketBookingScreen({super.key, required this.ticketCode});

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  // 1. Controllers holding the dynamic data
  final TextEditingController sourceController = TextEditingController(
    text: "Vengal College",
  );
  final TextEditingController destinationController = TextEditingController(
    text: "Pattabiram",
  );
  final TextEditingController routeController = TextEditingController(
    text: "580",
  );
  final TextEditingController fareController = TextEditingController(
    text: "29",
  );

  int passengerCount = 1;

  @override
  void dispose() {
    sourceController.dispose();
    destinationController.dispose();
    routeController.dispose();
    fareController.dispose();
    super.dispose();
  }

  void _toggleStops() {
    setState(() {
      String temp = sourceController.text;
      sourceController.text = destinationController.text;
      destinationController.text = temp;
    });
  }

  void _incrementPassenger() {
    setState(() {
      if (passengerCount < 10) passengerCount++;
    });
  }

  // --- NEW: Dialog to edit Source/Destination ---
  Future<void> _editValueDialog(
    String title,
    TextEditingController controller,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter new $title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Refreshes the UI to show what you typed
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // --- NEW: Dialog to edit Route & Fare together ---
  Future<void> _editRouteAndFareDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Edit Route & Fare"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: routeController,
                decoration: const InputDecoration(
                  labelText: "Route (e.g. 580 MAG)",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fareController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Fare (e.g. 31)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Refreshes the UI
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate the total amount based on what is typed in the fare controller
    int currentFare = int.tryParse(fareController.text) ?? 29;
    int totalAmount = passengerCount * currentFare;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            right: -25,
            child: Transform.rotate(
              angle: -0.1,
              child: const Text('🚌', style: TextStyle(fontSize: 100)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),

                      // --- UPDATED: Dynamic Route Display & Edit Button ---
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                routeController
                                    .text, // Uses controller data instead of hardcoded "580"
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap:
                                    _editRouteAndFareDialog, // Triggers the popup
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "DELUX",
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // --- UPDATED: Uses dynamic controller data ---
                _buildStopCard(
                  label: "Source Stop",
                  controller: sourceController,
                ),

                GestureDetector(
                  onTap: _toggleStops,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                  ),
                ),

                // --- UPDATED: Uses dynamic controller data ---
                _buildStopCard(
                  label: "Destination Stop",
                  controller: destinationController,
                ),

                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: 40,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Ticket payment\ninformation",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          GestureDetector(
                            onTap: _incrementPassenger,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    passengerCount.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF5350),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActiveTicketScreen(
                                  ticketCode: widget.ticketCode,
                                  source: sourceController.text,
                                  destination: destinationController.text,
                                  routeNo: routeController.text,
                                  fare:
                                      totalAmount, // Passes the correctly calculated fare
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Book Bus @ ₹$totalAmount", // Displays the updated fare
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED: Helper now accepts a controller and triggers the dialog ---
  Widget _buildStopCard({
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              children: [
                Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    controller.text, // Uses the dynamic controller text
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                _editValueDialog(label, controller), // Triggers the popup
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit, color: Colors.grey[600], size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveTicketScreen extends StatefulWidget {
  final String ticketCode;
  final String source;
  final String destination;
  final int fare;
  final String routeNo;

  const ActiveTicketScreen({
    super.key,
    required this.ticketCode,
    required this.source,
    required this.destination,
    required this.fare,
    required this.routeNo,
  });

  @override
  State<ActiveTicketScreen> createState() => _ActiveTicketScreenState();
}

class _ActiveTicketScreenState extends State<ActiveTicketScreen> {
  int _selectedIndex = 3;
  Duration _timeLeft = const Duration(hours: 2, minutes: 58, seconds: 10);
  Timer? _timer;
  bool _isLightGreen = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
          _isLightGreen = !_isLightGreen;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate =
        "${DateFormat('dd/MM/yy').format(now)}\n${DateFormat('yyyy').format(now)}";
    final validityTime = DateFormat('h:mm a').format(now.add(_timeLeft));

    final Color timerBgColor = _isLightGreen
        ? const Color(0xFF8CC496)
        : const Color(0xFF9ED5A6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2D2D),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Active Ticket",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                "History >",
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 4,
                  bottom: 0,
                ),
                child: ClipPath(
                  clipper: TicketNotchClipper(),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFEEF0F5),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 40,
                          right: -20,
                          child: Opacity(
                            opacity: 0.03,
                            child: Icon(
                              Icons.verified_user,
                              size: 250,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 4,
                          top: 120,
                          bottom: 0,
                          child: _buildVerticalText(
                            "BUS TICKET        BUS TICKET        BUS TICKET",
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 120,
                          bottom: 0,
                          child: _buildVerticalText(
                            "BUS TICKET        BUS TICKET        BUS TICKET",
                          ),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            left: 24.0,
                            right: 24.0,
                            top: 20.0,
                            bottom: 60.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "MTC CHENNAI",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "மா. போ. க. (சென்னை)",
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    formattedDate,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 11,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Container(
                                    width: 1,
                                    height: 16,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(width: 14),
                                  Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.grey[700],
                                  ),
                                  Text(
                                    " X 1",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Container(
                                    width: 1,
                                    height: 16,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    "ID: 1291...",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.copy,
                                    size: 12,
                                    color: Colors.grey[700],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: timerBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Ticket is valid for",
                                      style: TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDuration(_timeLeft),
                                      style: const TextStyle(
                                        fontFamily: 'DigitalClock',
                                        fontSize: 50,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 170,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFDFCD9A,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Icon(
                                                  Icons.directions_bus,
                                                  color: Color(0xFF4A3414),
                                                  size: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "${widget.routeNo} |",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF333333),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Text(
                                                  "₹",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF333333),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                widget.fare.toString(),
                                                style: const TextStyle(
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF333333),
                                                  height: 1.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 75,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CustomPaint(
                                          painter: BlueCardPainter(),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 16.0,
                                              top: 10.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            2,
                                                          ),
                                                      decoration:
                                                          const BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                      child: const Icon(
                                                        Icons.check,
                                                        color: Color(
                                                          0xFF0A3CB1,
                                                        ),
                                                        size: 10,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text(
                                                      "Activated Ticket",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  widget.ticketCode,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 2.5,
                                                    fontFamily: 'Courier',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -30,
                                      right: -30,
                                      width: 110,
                                      height: 110,
                                      child: Image.asset(
                                        'lib/assets/Get.png',
                                        filterQuality: FilterQuality.high,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildMock3DBus(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Source",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.source.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.subdirectory_arrow_right,
                                      color: Colors.grey[600],
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Destination",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.destination.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const DashedDivider(),
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Board Bus from ${widget.source.toUpperCase()}",
                                  style: const TextStyle(
                                    color: Color(0xFF333333),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "NEXT ARRIVAL",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 9,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "--",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "VALIDITY",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 9,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        validityTime,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const DashedDivider(),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Adult",
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    "1",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: 150,
                                height: 150,
                                child: CustomPaint(painter: QRCodePainter()),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1048D4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Show Bus Ticket",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TicketDetailsScreen(
                                              source: widget.source,
                                              destination: widget.destination,
                                              fare: widget.fare,
                                              routeNo: widget.routeNo,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "THANK YOU FOR USING\nPUBLIC TRANSPORT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "பயணம் செய்தமைக்கு\nநன்றி",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildVerticalText(String text) {
    return RotatedBox(
      quarterTurns: 1,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[350],
          fontSize: 9,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.red[600],
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.horizontal_rule),
          label: 'Home',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Passes'),
        BottomNavigationBarItem(icon: Icon(Icons.adjust), label: 'Live'),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_num),
          label: 'Ticket',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  Widget _buildMock3DBus() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(-5, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 80,
            height: 65,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9024D9), Color(0xFF00C4D0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_bus,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. TICKET DETAILS SCREEN (THE NEW LITE BLUE RECEIPT PAGE)
// ============================================================================
class TicketDetailsScreen extends StatelessWidget {
  final String source;
  final String destination;
  final int fare;
  final String routeNo;

  const TicketDetailsScreen({
    super.key,
    required this.source,
    required this.destination,
    required this.fare,
    required this.routeNo,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Setting dates precisely as shown in your latest screenshot
    final formattedDate = DateFormat('MM/dd/yyyy').format(now);
    final formattedTime = DateFormat('HH:mm').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF0066CC), // The new lite bright blue
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Your bus ticket for $routeNo bus is\nready!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "You can view your ticket details\nbelow.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ClipPath(
                  clipper: ReceiptJaggedClipper(),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFEEF0F5),
                    child: Stack(
                      children: [
                        // New Circular MTC Watermark
                        Positioned.fill(
                          child: Center(
                            child: Opacity(
                              opacity: 0.05,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 4,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "MTC",
                                    style: TextStyle(
                                      fontSize: 65,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // New Vertical Text "MTC, CHENNAI"
                        Positioned(
                          left: 6,
                          top: 0,
                          bottom: 0,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              "MTC, CHENNAI          MTC, CHENNAI          MTC, CHENNAI",
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 11,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 0,
                          bottom: 0,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              "MTC, CHENNAI          MTC, CHENNAI          MTC, CHENNAI",
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 11,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),

                        // Receipt Data Content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 24),
                              const Text(
                                "மா. போ. க. (சென்னை)",
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                source.toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "T No: 3308980766",
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    formattedTime,
                                    style: const TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const DashedDivider(),
                              const SizedBox(height: 24),
                              Text(
                                source.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                destination.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Ad: 1 x $fare.00 = Rs. $fare.00",
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "ரூ. $fare.00",
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "மோட்டார் வாகன\nவிதிகளுக்குட்பட்டது",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                              ),
                              const Spacer(),

                              // Native Go Back Navigation Button
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    foregroundColor: const Color(0xFF333333),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Go Back",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. UTILITY PAINTERS & CLIPPERS
// ============================================================================

class BlueCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0A3CB1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final dotPaint = Paint()..color = Colors.black.withValues(alpha: 0.08);
    for (double y = 0; y < size.height; y += 4) {
      for (double x = 0; x < size.width; x += 4) {
        double offsetX = (y % 8 == 0) ? 0 : 2;
        canvas.drawCircle(Offset(x + offsetX, y), 0.7, dotPaint);
      }
    }

    final yellowColor = const Color(0xFFF2A73D);
    final arcPaint = Paint()
      ..color = yellowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width - 25, size.height / 2 + 10),
        radius: 38,
      ),
      math.pi / 2,
      math.pi * 1.3,
      false,
      arcPaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '1',
        style: TextStyle(
          color: yellowColor,
          fontSize: 75,
          fontWeight: FontWeight.w900,
          fontFamily: 'Arial',
          height: 1.0,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 42, size.height / 2 - 32));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF333333);
    final double s = size.width;

    void drawPositioner(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 30, 30), paint);
      canvas.drawRect(
        Rect.fromLTWH(x + 5, y + 5, 20, 20),
        Paint()..color = const Color(0xFFEEF0F5),
      );
      canvas.drawRect(Rect.fromLTWH(x + 10, y + 10, 10, 10), paint);
    }

    drawPositioner(0, 0);
    drawPositioner(s - 30, 0);
    drawPositioner(0, s - 30);

    final random = math.Random(42);
    for (double y = 0; y < s; y += 6) {
      for (double x = 0; x < s; x += 6) {
        if ((x < 35 && y < 35) ||
            (x > s - 35 && y < 35) ||
            (x < 35 && y > s - 35)) {
          continue;
        }
        if (random.nextDouble() > 0.5) {
          canvas.drawRect(Rect.fromLTWH(x, y, 6, 6), paint);
        }
      }
    }

    canvas.drawCircle(
      Offset(s / 2, s / 2),
      18,
      Paint()..color = const Color(0xFFEEF0F5),
    );
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '1',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(s / 2 - 7, s / 2 - 14));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TicketNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width / 2 - 16, size.height);
    path.arcToPoint(
      Offset(size.width / 2 + 16, size.height),
      radius: const Radius.circular(16),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ReceiptJaggedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double toothWidth = size.width / 35;
    path.moveTo(0, 6.0);
    for (double i = 0; i < size.width; i += toothWidth) {
      path.lineTo(i + (toothWidth / 2), 0);
      path.lineTo(i + toothWidth, 6.0);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2 + 16, size.height);
    path.arcToPoint(
      Offset(size.width / 2 - 16, size.height),
      radius: const Radius.circular(16),
      clockwise: false,
    );
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(),
      child: const SizedBox(height: 1, width: double.infinity),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 4, dashSpace = 4, startX = 0;
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
