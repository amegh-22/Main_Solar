// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:solar/login.dart';

// class OfficerWebPage extends StatefulWidget {
//   const OfficerWebPage({super.key});

//   @override
//   State<OfficerWebPage> createState() => _OfficerWebPageState();
// }

// class _OfficerWebPageState extends State<OfficerWebPage> {

//   String selectedRoad = "North";

//   // ===== Data =====
//   Map<String, Map<String, dynamic>> roads = {
//     "North": {"light": "Red", "timer": 30, "congestion": "High", "waiting": 40, "passed": 520, "battery": 80},
//     "South": {"light": "Green", "timer": 25, "congestion": "Normal", "waiting": 15, "passed": 460, "battery": 72},
//     "East": {"light": "Orange", "timer": 5, "congestion": "Medium", "waiting": 25, "passed": 390, "battery": 65},
//     "West": {"light": "Red", "timer": 30, "congestion": "High", "waiting": 38, "passed": 500, "battery": 55},
//   };

//   final int redDuration = 30;
//   final int greenDuration = 25;
//   final int orangeDuration = 5;

//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startSimulation();
//   }

//   void _startSimulation() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       setState(() {
//         roads.forEach((name, road) {
//           road["timer"]--;

//           if (road["timer"] <= 0) {
//             if (road["light"] == "Red") {
//               road["light"] = "Green";
//               road["timer"] = greenDuration;
//               road["congestion"] = "Normal";
//               road["waiting"] = 15;
//             } 
//             else if (road["light"] == "Green") {
//               road["light"] = "Orange";
//               road["timer"] = orangeDuration;
//               road["congestion"] = "Medium";
//             } 
//             else {
//               road["light"] = "Red";
//               road["timer"] = redDuration;
//               road["congestion"] = "High";
//               road["waiting"] = 40;
//             }

//             road["passed"] += road["waiting"];
//           }
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     if (!mounted) return;

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   Map<String, dynamic> get road => roads[selectedRoad]!;

//   // ===== Colors =====
//   Color _congestionColor(String level) {
//     switch (level) {
//       case "High":
//         return Colors.red;
//       case "Medium":
//         return Colors.orange;
//       default:
//         return Colors.green;
//     }
//   }

//   Color _lightColor(String light) {
//     switch (light) {
//       case "Green":
//         return Colors.green;
//       case "Orange":
//         return Colors.orange;
//       default:
//         return Colors.red;
//     }
//   }

//   // ===== Intersection Signals =====
//   Widget _signal(String roadName) {
//     String light = roads[roadName]!["light"];

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedRoad = roadName;
//         });
//       },
//       child: Column(
//         children: [
//           Container(
//             width: selectedRoad == roadName ? 28 : 22,
//             height: selectedRoad == roadName ? 28 : 22,
//             decoration: BoxDecoration(
//               color: _lightColor(light),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: _lightColor(light).withOpacity(0.6),
//                   blurRadius: 6,
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             roadName,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: selectedRoad == roadName
//                   ? FontWeight.bold
//                   : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIntersection() {
//     return SizedBox(
//       height: 240,
//       width: 240,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Container(width: 80, height: 240, color: Colors.grey.shade300),
//           Container(width: 240, height: 80, color: Colors.grey.shade300),

//           Container(
//             width: 30,
//             height: 40,
//             decoration: const BoxDecoration(
//               color: Colors.black87,
//               shape: BoxShape.circle,
//             ),
//           ),

//           Positioned(top: 15, child: _signal("North")),
//           Positioned(bottom: 15, child: _signal("South")),
//           Positioned(left: 139, child: _signal("West")),
//           Positioned(right: 139, child: _signal("East")),
//         ],
//       ),
//     );
//   }

//   // ===== Detail Row (Aligned) =====
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 150,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===== Details Panel =====
//   Widget _buildDetails() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: _congestionColor(road["congestion"]).withOpacity(0.1),
//         border: Border.all(color: _congestionColor(road["congestion"])),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             selectedRoad,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 15),

//           _detailRow("Signal", road["light"]),
//           _detailRow("Remaining", "${road["timer"]} sec"),
//           _detailRow("Congestion", road["congestion"]),
//           _detailRow("Waiting Vehicles", "${road["waiting"]}"),
//           _detailRow("Passed Today", "${road["passed"]}"),
//           _detailRow("Battery", "${road["battery"]}%"),
//         ],
//       ),
//     );
//   }

//   // ===== UI =====
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.orange.shade900,
//         title: const Text(
//           "SolarStat",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           PopupMenuButton<int>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) {
//               if (value == 1) _logout();
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 1,
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout, size: 18),
//                     SizedBox(width: 8),
//                     Text("Logout"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [

//             // Top Section
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(flex: 1, child: _buildIntersection()),
//                 const SizedBox(width: 20),
//                 Expanded(flex: 1, child: _buildDetails()),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // Bottom Video
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     "Live Traffic Video",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//new 


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solar/login.dart';

class OfficerWebPage extends StatefulWidget {
  const OfficerWebPage({super.key});

  @override
  State<OfficerWebPage> createState() => _OfficerWebPageState();
}

class _OfficerWebPageState extends State<OfficerWebPage> {

  String selectedArea = "Area A Junction";
  String selectedRoad = "North";

  Map<String, Map<String, Map<String, dynamic>>> areas = {

    "Area A Junction": {
      "North": {"light": "Red", "timer": 30, "congestion": "High", "waiting": 40, "passed": 520, "battery": 80},
      "South": {"light": "Green", "timer": 25, "congestion": "Normal", "waiting": 15, "passed": 460, "battery": 72},
      "East": {"light": "Orange", "timer": 5, "congestion": "Medium", "waiting": 25, "passed": 390, "battery": 65},
      "West": {"light": "Red", "timer": 30, "congestion": "High", "waiting": 38, "passed": 500, "battery": 55},
    },

    "Area B Junction": {
      "North": {"light": "Green", "timer": 20, "congestion": "Medium", "waiting": 18, "passed": 410, "battery": 70},
      "South": {"light": "Red", "timer": 30, "congestion": "High", "waiting": 36, "passed": 480, "battery": 65},
      "East": {"light": "Red", "timer": 30, "congestion": "High", "waiting": 40, "passed": 500, "battery": 60},
      "West": {"light": "Orange", "timer": 5, "congestion": "Medium", "waiting": 22, "passed": 370, "battery": 75},
    },

  };

  final int redDuration = 30;
  final int greenDuration = 25;
  final int orangeDuration = 5;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {

      setState(() {

        areas.forEach((areaName, roads) {

          roads.forEach((name, road) {

            road["timer"]--;

            if (road["timer"] <= 0) {

              if (road["light"] == "Red") {
                road["light"] = "Green";
                road["timer"] = greenDuration;
                road["congestion"] = "Normal";
                road["waiting"] = 15;
              }

              else if (road["light"] == "Green") {
                road["light"] = "Orange";
                road["timer"] = orangeDuration;
                road["congestion"] = "Medium";
              }

              else {
                road["light"] = "Red";
                road["timer"] = redDuration;
                road["congestion"] = "High";
                road["waiting"] = 40;
              }

              road["passed"] += road["waiting"];
            }

          });

        });

      });

    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Map<String, dynamic> get road => areas[selectedArea]![selectedRoad]!;

  Color _congestionColor(String level) {
    switch (level) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Color _lightColor(String light) {
    switch (light) {
      case "Green":
        return Colors.green;
      case "Orange":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget _signal(String roadName) {

    String light = areas[selectedArea]![roadName]!["light"];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRoad = roadName;
        });
      },
      child: Column(
        children: [
          Container(
            width: selectedRoad == roadName ? 28 : 22,
            height: selectedRoad == roadName ? 28 : 22,
            decoration: BoxDecoration(
              color: _lightColor(light),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _lightColor(light).withOpacity(0.6),
                  blurRadius: 6,
                )
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roadName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selectedRoad == roadName
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntersection() {
    return SizedBox(
      height: 240,
      width: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [

          Container(width: 80, height: 240, color: Colors.grey.shade300),
          Container(width: 240, height: 80, color: Colors.grey.shade300),

          Container(
            width: 30,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),

          Positioned(top: 15, child: _signal("North")),
          Positioned(bottom: 15, child: _signal("South")),
          Positioned(left: 15, child: _signal("West")),
          Positioned(right: 15, child: _signal("East")),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [

          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildDetails() {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: _congestionColor(road["congestion"]).withOpacity(0.1),
        border: Border.all(color: _congestionColor(road["congestion"])),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            selectedRoad,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          _detailRow("Signal", road["light"]),
          _detailRow("Remaining", "${road["timer"]} sec"),
          _detailRow("Congestion", road["congestion"]),
          _detailRow("Waiting Vehicles", "${road["waiting"]}"),
          _detailRow("Passed Today", "${road["passed"]}"),
          _detailRow("Battery", "${road["battery"]}%"),

        ],
      ),
    );
  }

  Widget _buildAreaSelector() {

    return Row(
      children: [

        const Text(
          "Select Area:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(width: 10),

        DropdownButton<String>(
          value: selectedArea,

          items: areas.keys.map((area) {

            return DropdownMenuItem(
              value: area,
              child: Text(area),
            );

          }).toList(),

          onChanged: (value) {
            setState(() {
              selectedArea = value!;
              selectedRoad = "North";
            });
          },
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        title: const Text(
          "SolarStat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [

          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.white),

            onSelected: (value) {
              if (value == 1) _logout();
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Text("Logout"),
              ),
            ],

          ),

        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            _buildAreaSelector(),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(child: _buildIntersection()),

                const SizedBox(width: 20),

                Expanded(child: _buildDetails()),

              ],
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "Live Traffic Video",
                    style: TextStyle(fontSize: 16),
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

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:solar/login.dart';

// class OfficerWebPage extends StatefulWidget {
//   const OfficerWebPage({super.key});

//   @override
//   State<OfficerWebPage> createState() => _OfficerWebPageState();
// }

// class _OfficerWebPageState extends State<OfficerWebPage>
//     with TickerProviderStateMixin {

//   String selectedRoad = "North";

//   // ===== Data ===== (UNCHANGED)
//   Map<String, Map<String, dynamic>> roads = {
//     "North": {"light": "Red", "timer": 30, "congestion": "High", "waiting": 40, "passed": 520, "battery": 80},
//     "South": {"light": "Green", "timer": 25, "congestion": "Normal", "waiting": 15, "passed": 460, "battery": 72},
//     "East": {"light": "Orange", "timer": 5, "congestion": "Medium", "waiting": 25, "passed": 390, "battery": 65},
//     "West": {"light": "Red", "timer": 30, "congestion": "High", "waiting": 38, "passed": 500, "battery": 55},
//   };

//   final int redDuration = 30;    // UNCHANGED
//   final int greenDuration = 25;  // UNCHANGED
//   final int orangeDuration = 5;  // UNCHANGED

//   Timer? _timer;

//   // UI-only animation controllers
//   late AnimationController _pulseCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _startSimulation(); // UNCHANGED
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
//   }

//   // ===== _startSimulation ===== (COMPLETELY UNCHANGED)
//   void _startSimulation() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       setState(() {
//         roads.forEach((name, road) {
//           road["timer"]--;

//           if (road["timer"] <= 0) {
//             if (road["light"] == "Red") {
//               road["light"] = "Green";
//               road["timer"] = greenDuration;
//               road["congestion"] = "Normal";
//               road["waiting"] = 15;
//             } else if (road["light"] == "Green") {
//               road["light"] = "Orange";
//               road["timer"] = orangeDuration;
//               road["congestion"] = "Medium";
//             } else {
//               road["light"] = "Red";
//               road["timer"] = redDuration;
//               road["congestion"] = "High";
//               road["waiting"] = 40;
//             }

//             road["passed"] += road["waiting"];
//           }
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pulseCtrl.dispose();
//     super.dispose();
//   }

//   // ===== _logout ===== (COMPLETELY UNCHANGED)
//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     if (!mounted) return;

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   Map<String, dynamic> get road => roads[selectedRoad]!; // UNCHANGED

//   // ===== _congestionColor ===== (COMPLETELY UNCHANGED)
//   Color _congestionColor(String level) {
//     switch (level) {
//       case "High":
//         return Colors.red;
//       case "Medium":
//         return Colors.orange;
//       default:
//         return Colors.green;
//     }
//   }

//   // ===== _lightColor ===== (COMPLETELY UNCHANGED)
//   Color _lightColor(String light) {
//     switch (light) {
//       case "Green":
//         return Colors.green;
//       case "Orange":
//         return Colors.orange;
//       default:
//         return Colors.red;
//     }
//   }

//   // ───────────────────────────────────────────
//   //  UI HELPERS (design only, same data/logic)
//   // ───────────────────────────────────────────

//   // Signal dot used inside intersection
//   Widget _signal(String roadName) {
//     final String light = roads[roadName]!["light"];
//     final bool isSelected = selectedRoad == roadName;
//     final Color col = _lightColor(light);

//     return GestureDetector(
//       onTap: () => setState(() => selectedRoad = roadName),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             width: isSelected ? 28 : 20,
//             height: isSelected ? 28 : 20,
//             decoration: BoxDecoration(
//               color: col,
//               shape: BoxShape.circle,
//               border: isSelected
//                   ? Border.all(color: Colors.white, width: 2.5)
//                   : null,
//               boxShadow: [
//                 BoxShadow(
//                   color: col.withOpacity(isSelected ? 0.85 : 0.5),
//                   blurRadius: isSelected ? 14 : 7,
//                   spreadRadius: isSelected ? 2 : 0,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 5),
//           Text(
//             roadName,
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight:
//                   isSelected ? FontWeight.w700 : FontWeight.w400,
//               color: isSelected ? Colors.white : Colors.white70,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===== _buildIntersection =====
//   Widget _buildIntersection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111827),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.07)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'INTERSECTION',
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 2.5,
//               color: Color(0xFF8A9BBE),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Center(
//             child: SizedBox(
//               height: 240,
//               width: 240,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Road surface vertical
//                   Container(
//                     width: 80,
//                     height: 240,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E2A3A),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   // Road surface horizontal
//                   Container(
//                     width: 240,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E2A3A),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   // Centre solar icon
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF0A0E1A),
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFFFFC107).withOpacity(0.35),
//                         width: 1.5,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFFFFC107).withOpacity(0.15),
//                           blurRadius: 16,
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                       child: Text('☀', style: TextStyle(fontSize: 20)),
//                     ),
//                   ),
//                   // Signals – same positions as original
//                   Positioned(top: 15,   child: _signal("North")),
//                   Positioned(bottom: 15, child: _signal("South")),
//                   Positioned(left: 139,  child: _signal("West")),
//                   Positioned(right: 139, child: _signal("East")),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===== _detailRow ===== (logic-only helper, used in _buildDetails – UNCHANGED interface)
//   Widget _detailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 9),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 150,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.5,
//                 color: Color(0xFF8A9BBE),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFFF0F4FF),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===== _buildDetails =====
//   Widget _buildDetails() {
//     final congColor = _congestionColor(road["congestion"]);
//     final lightColor = _lightColor(road["light"]);

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111827),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: congColor.withOpacity(0.35),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header row
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   '$selectedRoad Road',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFFF0F4FF),
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//               // Signal pill
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 5),
//                 decoration: BoxDecoration(
//                   color: lightColor.withOpacity(0.15),
//                   border: Border.all(
//                       color: lightColor.withOpacity(0.4)),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: lightColor,
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: lightColor.withOpacity(0.6),
//                             blurRadius: 6,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       road["light"],
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w800,
//                         color: lightColor,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 6),

//           // Congestion badge
//           Container(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 10, vertical: 3),
//             decoration: BoxDecoration(
//               color: congColor.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text(
//               road["congestion"],
//               style: TextStyle(
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 color: congColor,
//                 letterSpacing: 1,
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),
//           Divider(color: Colors.white.withOpacity(0.06)),
//           const SizedBox(height: 8),

//           // Detail rows – same labels/values as original
//           _detailRow("Signal",           road["light"]),
//           _detailRow("Remaining",        "${road["timer"]} sec"),
//           _detailRow("Congestion",       road["congestion"]),
//           _detailRow("Waiting Vehicles", "${road["waiting"]}"),
//           _detailRow("Passed Today",     "${road["passed"]}"),
//           _detailRow("Battery",          "${road["battery"]}%"),
//         ],
//       ),
//     );
//   }

//   // ===== BUILD ===== (STRUCTURE UNCHANGED – same Row/Column layout as original)
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E1A),

//       // ── AppBar ──────────────────────────────
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0A0E1A),
//         elevation: 0,
//         titleSpacing: 20,
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFFFFC107), Color(0xFFFF8C00)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFFFFC107).withOpacity(0.4),
//                     blurRadius: 10,
//                   ),
//                 ],
//               ),
//               child: const Center(
//                   child: Text('☀', style: TextStyle(fontSize: 15))),
//             ),
//             const SizedBox(width: 10),
//             RichText(
//               text: const TextSpan(
//                 style: TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 1.5,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: 'SOLAR',
//                     style: TextStyle(color: Color(0xFFF0F4FF)),
//                   ),
//                   TextSpan(
//                     text: 'STAT',
//                     style: TextStyle(color: Color(0xFFFFC107)),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           // Live indicator
//           AnimatedBuilder(
//             animation: _pulseCtrl,
//             builder: (_, __) => Container(
//               margin: const EdgeInsets.symmetric(vertical: 14),
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 12, vertical: 0),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.12),
//                 border: Border.all(
//                     color: Colors.green
//                         .withOpacity(0.15 + 0.15 * _pulseCtrl.value)),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 7,
//                     height: 7,
//                     decoration: BoxDecoration(
//                       color: Colors.green
//                           .withOpacity(0.5 + 0.5 * _pulseCtrl.value),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   const Text(
//                     'LIVE',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.green,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           // Popup menu – UNCHANGED logic
//           PopupMenuButton<int>(
//             icon: const Icon(Icons.more_vert,
//                 color: Color(0xFF8A9BBE)),
//             color: const Color(0xFF151D2E),
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12)),
//             onSelected: (value) {
//               if (value == 1) _logout(); // UNCHANGED
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 1,
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout,
//                         size: 16, color: Color(0xFF8A9BBE)),
//                     SizedBox(width: 8),
//                     Text(
//                       "Logout",
//                       style: TextStyle(
//                           color: Color(0xFFF0F4FF), fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 8),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(
//             height: 1,
//             color: Colors.white.withOpacity(0.07),
//           ),
//         ),
//       ),

//       // ── Body ────────────────────────────────
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [

//             // ── Top Section ── SAME structure as original (Row with two Expanded)
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(flex: 1, child: _buildIntersection()),
//                 const SizedBox(width: 20),
//                 Expanded(flex: 1, child: _buildDetails()),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // ── Bottom Video ── SAME structure as original (Expanded container)
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF111827),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                       color: Colors.white.withOpacity(0.07)),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Subtle scan-line animation
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(16),
//                       child: AnimatedBuilder(
//                         animation: _pulseCtrl,
//                         builder: (_, __) => Align(
//                           alignment: Alignment(
//                               0,
//                               -1 +
//                                   2 *
//                                       ((_pulseCtrl.value +
//                                               DateTime.now()
//                                                   .millisecondsSinceEpoch /
//                                                   3000) %
//                                           1)),
//                           child: Container(
//                             height: 2,
//                             color: const Color(0xFFFFC107)
//                                 .withOpacity(0.06),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Camera corner accents
//                     ..._cameraCorners(),
//                     // Centre label
//                     Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.videocam_outlined,
//                               color: Colors.white.withOpacity(0.15),
//                               size: 40),
//                           const SizedBox(height: 10),
//                           Text(
//                             "Live Traffic Video",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.white.withOpacity(0.3),
//                               letterSpacing: 1,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             "$selectedRoad · ${roads[selectedRoad]!["light"]}",
//                             style: const TextStyle(
//                               fontSize: 11,
//                               color: Color(0xFF8A9BBE),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // REC badge
//                     Positioned(
//                       top: 14,
//                       right: 14,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         decoration: BoxDecoration(
//                           color: Colors.red.withOpacity(0.12),
//                           border: Border.all(
//                               color: Colors.red.withOpacity(0.3)),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.circle,
//                                 color: Colors.red, size: 7),
//                             SizedBox(width: 5),
//                             Text(
//                               "REC",
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w800,
//                                 color: Colors.red,
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Camera corner decorations for video panel
//   List<Widget> _cameraCorners() {
//     const double s = 18;
//     const double t = 14;
//     const color = Color(0xFFFFC107);
//     const op = 0.3;
//     const w = 2.0;

//     Widget corner(
//             double? top, double? bottom, double? left, double? right,
//             bool flipX, bool flipY) =>
//         Positioned(
//           top: top,
//           bottom: bottom,
//           left: left,
//           right: right,
//           child: Transform.scale(
//             scaleX: flipX ? -1 : 1,
//             scaleY: flipY ? -1 : 1,
//             child: SizedBox(
//               width: s,
//               height: s,
//               child: CustomPaint(
//                 painter: _CornerPainter(color.withOpacity(op), w),
//               ),
//             ),
//           ),
//         );

//     return [
//       corner(t, null, t,    null,  false, false),
//       corner(t, null, null, t,     true,  false),
//       corner(null, t, t,    null,  false, true),
//       corner(null, t, null, t,     true,  true),
//     ];
//   }
// }

// // Small L-shaped corner painter
// class _CornerPainter extends CustomPainter {
//   final Color color;
//   final double strokeWidth;
//   _CornerPainter(this.color, this.strokeWidth);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//     canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
//     canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
//   }

//   @override
//   bool shouldRepaint(_CornerPainter old) =>
//       old.color != color || old.strokeWidth != strokeWidth;
// }
