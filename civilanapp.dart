// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:solar/login.dart';

// class CivilianAppPage extends StatefulWidget {
//   const CivilianAppPage({super.key});

//   @override
//   State<CivilianAppPage> createState() => _CivilianAppPageState();
// }

// class _CivilianAppPageState extends State<CivilianAppPage> {

//   // ===== Traffic Data =====
//   Map<String, Map<String, dynamic>> roads = {
//     "North": {
//       "light": "Red",
//       "timer": 30,
//       "congestion": "High",
//       "greenTime": 25
//     },
//     "South": {
//       "light": "Green",
//       "timer": 25,
//       "congestion": "Normal",
//       "greenTime": 25
//     },
//     "East": {
//       "light": "Orange",
//       "timer": 5,
//       "congestion": "Medium",
//       "greenTime": 20
//     },
//     "West": {
//       "light": "Red",
//       "timer": 30,
//       "congestion": "High",
//       "greenTime": 30
//     },
//   };

//   final int redDuration = 30;
//   final int orangeDuration = 5;

//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startTrafficCycle();
//   }

//   // ===== Traffic Cycle =====
//   void _startTrafficCycle() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       setState(() {
//         roads.forEach((roadName, road) {
//           road["timer"]--;

//           if (road["timer"] <= 0) {
//             if (road["light"] == "Red") {
//               road["light"] = "Green";
//               road["timer"] = road["greenTime"];
//               road["congestion"] = "Normal";
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
//             }
//           }
//         });
//       });
//     });
//   }

//   // ===== Logout =====
//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     if (!mounted) return;

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   // ===== Helpers =====
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

//   Widget _signalLight(String roadName) {
//     String light = roads[roadName]!["light"];

//     Color color;
//     if (light == "Red") {
//       color = Colors.red;
//     } else if (light == "Orange") {
//       color = Colors.orange;
//     } else {
//       color = Colors.green;
//     }

//     return Column(
//       children: [
//         Container(
//           width: 20,
//           height: 20,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.6),
//                 blurRadius: 6,
//               )
//             ],
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           roadName,
//           style: const TextStyle(fontSize: 10),
//         ),
//       ],
//     );
//   }

//   // ===== Intersection UI =====
//   Widget _buildIntersection() {
//     return SizedBox(
//       height: 260,
//       width: 260,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [

//           // Vertical road
//           Container(width: 80, height: 260, color: Colors.grey.shade300),

//           // Horizontal road
//           Container(width: 260, height: 80, color: Colors.grey.shade300),

//           // Center
//           Container(
//             width: 40,
//             height: 40,
//             decoration: const BoxDecoration(
//               color: Colors.black87,
//               shape: BoxShape.circle,
//             ),
//           ),

//           Positioned(top: 20, child: _signalLight("North")),
//           Positioned(bottom: 20, child: _signalLight("South")),
//           Positioned(left: 20, child: _signalLight("West")),
//           Positioned(right: 20, child: _signalLight("East")),
//         ],
//       ),
//     );
//   }

//   // ===== Road Status Cards (with Timer) =====
//   Widget _buildRoadCards() {
//     return Column(
//       children: roads.keys.map((roadName) {
//         var road = roads[roadName]!;

//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: _congestionColor(road["congestion"]).withOpacity(0.1),
//             border: Border.all(
//               color: _congestionColor(road["congestion"]),
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     roadName,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     "Green Time: ${road["greenTime"]} sec",
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                   Text(
//                     "Remaining: ${road["timer"]} sec",
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),
//               Text(
//                 road["congestion"],
//                 style: TextStyle(
//                   color: _congestionColor(road["congestion"]),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
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
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           PopupMenuButton<int>(
//             icon: const Icon(Icons.menu, color: Colors.white),
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

//             _buildIntersection(),

//             const SizedBox(height: 25),

//             _buildRoadCards(),
//           ],
//         ),
//       ),
//     );
//   }
// }





//new ui

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solar/login.dart';

class CivilianAppPage extends StatefulWidget {
  const CivilianAppPage({super.key});

  @override
  State<CivilianAppPage> createState() => _CivilianAppPageState();
}

class _CivilianAppPageState extends State<CivilianAppPage> {

  Map<String, Map<String, Map<String, dynamic>>> areas = {

    "Area A Junction": {
      "North": {"light": "Red", "timer": 30, "congestion": "High", "greenTime": 25},
      "South": {"light": "Green", "timer": 25, "congestion": "Normal", "greenTime": 25},
      "East": {"light": "Orange", "timer": 5, "congestion": "Medium", "greenTime": 20},
      "West": {"light": "Red", "timer": 30, "congestion": "High", "greenTime": 30},
    },

    "Area B Junction": {
      "North": {"light": "Green", "timer": 20, "congestion": "Medium", "greenTime": 20},
      "South": {"light": "Red", "timer": 30, "congestion": "High", "greenTime": 25},
      "East": {"light": "Red", "timer": 30, "congestion": "High", "greenTime": 25},
      "West": {"light": "Orange", "timer": 5, "congestion": "Medium", "greenTime": 20},
    },

  };

  final int redDuration = 30;
  final int orangeDuration = 5;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTrafficCycle();
  }

  void _startTrafficCycle() {

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {

      setState(() {

        areas.forEach((areaName, roads) {

          roads.forEach((roadName, road) {

            road["timer"]--;

            if (road["timer"] <= 0) {

              if (road["light"] == "Red") {
                road["light"] = "Green";
                road["timer"] = road["greenTime"];
                road["congestion"] = "Normal";
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
              }

            }

          });

        });

      });

    });

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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

  Widget _signalLight(Map<String, dynamic> road, String name) {

    String light = road["light"];

    Color color;

    if (light == "Red") {
      color = Colors.red;
    }
    else if (light == "Orange") {
      color = Colors.orange;
    }
    else {
      color = Colors.green;
    }

    return Column(
      children: [

        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 6,
              )
            ],
          ),
        ),

        const SizedBox(height: 4),

        Text(
          name,
          style: const TextStyle(fontSize: 10),
        ),

      ],
    );
  }

  Widget _buildIntersection(Map<String, Map<String, dynamic>> roads) {

    return SizedBox(
      height: 260,
      width: 260,

      child: Stack(
        alignment: Alignment.center,
        children: [

          Container(width: 80, height: 260, color: Colors.grey.shade300),
          Container(width: 260, height: 80, color: Colors.grey.shade300),

          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),

          Positioned(top: 20, child: _signalLight(roads["North"]!, "North")),
          Positioned(bottom: 20, child: _signalLight(roads["South"]!, "South")),
          Positioned(left: 20, child: _signalLight(roads["West"]!, "West")),
          Positioned(right: 20, child: _signalLight(roads["East"]!, "East")),

        ],
      ),
    );
  }

  Widget _buildRoadCards(Map<String, Map<String, dynamic>> roads) {

    return Column(

      children: roads.keys.map((roadName) {

        var road = roads[roadName]!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: _congestionColor(road["congestion"]).withOpacity(0.1),

            border: Border.all(
              color: _congestionColor(road["congestion"]),
            ),

            borderRadius: BorderRadius.circular(10),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    roadName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Timer: ${road["timer"]} sec",
                    style: const TextStyle(fontSize: 12),
                  ),

                ],
              ),

              Text(
                road["congestion"],
                style: TextStyle(
                  color: _congestionColor(road["congestion"]),
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        );

      }).toList(),

    );
  }

  Widget _buildArea(String areaName, Map<String, Map<String, dynamic>> roads) {

    return Container(

      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade900),
      ),

      child: Column(
        children: [

          Text(
            areaName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _buildIntersection(roads),

          const SizedBox(height: 15),

          _buildRoadCards(roads),

        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,

        title: const Text(
          "SolarStat",
          style: TextStyle(color: Colors.white),
        ),

        actions: [

          PopupMenuButton<int>(
            icon: const Icon(Icons.menu, color: Colors.white),

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

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: areas.entries.map((area) {

            return _buildArea(area.key, area.value);

          }).toList(),

        ),

      ),

    );

  }

}




// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:solar/login.dart';

// class CivilianAppPage extends StatefulWidget {
//   const CivilianAppPage({super.key});

//   @override
//   State<CivilianAppPage> createState() => _CivilianAppPageState();
// }

// class _CivilianAppPageState extends State<CivilianAppPage>
//     with SingleTickerProviderStateMixin {

//   // ===== Traffic Data ===== (COMPLETELY UNCHANGED)
//   Map<String, Map<String, dynamic>> roads = {
//     "North": {
//       "light": "Red",
//       "timer": 30,
//       "congestion": "High",
//       "greenTime": 25
//     },
//     "South": {
//       "light": "Green",
//       "timer": 25,
//       "congestion": "Normal",
//       "greenTime": 25
//     },
//     "East": {
//       "light": "Orange",
//       "timer": 5,
//       "congestion": "Medium",
//       "greenTime": 20
//     },
//     "West": {
//       "light": "Red",
//       "timer": 30,
//       "congestion": "High",
//       "greenTime": 30
//     },
//   };

//   final int redDuration = 30;    // UNCHANGED
//   final int orangeDuration = 5;  // UNCHANGED

//   Timer? _timer;

//   // UI-only
//   late AnimationController _pulseCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _startTrafficCycle(); // UNCHANGED
//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
//   }

//   // ===== _startTrafficCycle ===== (COMPLETELY UNCHANGED)
//   void _startTrafficCycle() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       setState(() {
//         roads.forEach((roadName, road) {
//           road["timer"]--;

//           if (road["timer"] <= 0) {
//             if (road["light"] == "Red") {
//               road["light"] = "Green";
//               road["timer"] = road["greenTime"];
//               road["congestion"] = "Normal";
//             } else if (road["light"] == "Green") {
//               road["light"] = "Orange";
//               road["timer"] = orangeDuration;
//               road["congestion"] = "Medium";
//             } else {
//               road["light"] = "Red";
//               road["timer"] = redDuration;
//               road["congestion"] = "High";
//             }
//           }
//         });
//       });
//     });
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

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pulseCtrl.dispose();
//     super.dispose();
//   }

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

//   // ───────────────────────────────────────────
//   //  UI HELPERS  (design only – same data used)
//   // ───────────────────────────────────────────

//   // _signalLight – same logic, new visual
//   Widget _signalLight(String roadName) {
//     final String light = roads[roadName]!["light"];

//     Color color;
//     if (light == "Red") {
//       color = Colors.red;
//     } else if (light == "Orange") {
//       color = Colors.orange;
//     } else {
//       color = Colors.green;
//     }

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           width: 18,
//           height: 18,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.65),
//                 blurRadius: 10,
//                 spreadRadius: 1,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           roadName,
//           style: const TextStyle(
//             fontSize: 9,
//             fontWeight: FontWeight.w600,
//             color: Colors.white70,
//             letterSpacing: 0.5,
//           ),
//         ),
//       ],
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
//           Row(
//             children: [
//               const Text(
//                 'LIVE INTERSECTION',
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2.5,
//                   color: Color(0xFF8A9BBE),
//                 ),
//               ),
//               const Spacer(),
//               // Live pulse badge
//               AnimatedBuilder(
//                 animation: _pulseCtrl,
//                 builder: (_, __) => Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.green.withOpacity(0.1),
//                     border: Border.all(
//                         color: Colors.green.withOpacity(
//                             0.15 + 0.2 * _pulseCtrl.value)),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 6,
//                         height: 6,
//                         decoration: BoxDecoration(
//                           color: Colors.green.withOpacity(
//                               0.5 + 0.5 * _pulseCtrl.value),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       const SizedBox(width: 5),
//                       const Text(
//                         'LIVE',
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.green,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Center(
//             child: SizedBox(
//               height: 260,
//               width: 260,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Vertical road
//                   Container(
//                     width: 80,
//                     height: 260,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E2A3A),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   // Horizontal road
//                   Container(
//                     width: 260,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1E2A3A),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                   // Centre
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF0A0E1A),
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFFFFC107).withOpacity(0.3),
//                         width: 1.5,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFFFFC107).withOpacity(0.12),
//                           blurRadius: 14,
//                         ),
//                       ],
//                     ),
//                     child: const Center(
//                         child:
//                             Text('☀', style: TextStyle(fontSize: 18))),
//                   ),
//                   // Signal positions – SAME as original
//                   Positioned(top: 20,    child: _signalLight("North")),
//                   Positioned(bottom: 20, child: _signalLight("South")),
//                   Positioned(left: 20,   child: _signalLight("West")),
//                   Positioned(right: 20,  child: _signalLight("East")),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ===== _buildRoadCards =====  (same data access, new visual)
//   Widget _buildRoadCards() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(bottom: 12),
//           child: Text(
//             'ROAD STATUS',
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 2.5,
//               color: Color(0xFF8A9BBE),
//             ),
//           ),
//         ),
//         ...roads.keys.map((roadName) {
//           final road = roads[roadName]!;
//           final congColor = _congestionColor(road["congestion"]);

//           // Signal colour – same logic as original _signalLight
//           Color lightColor;
//           if (road["light"] == "Green") {
//             lightColor = Colors.green;
//           } else if (road["light"] == "Orange") {
//             lightColor = Colors.orange;
//           } else {
//             lightColor = Colors.red;
//           }

//           // Timer progress 0..1
//           final int maxT = road["light"] == "Green"
//               ? road["greenTime"]
//               : road["light"] == "Orange"
//                   ? orangeDuration
//                   : redDuration;
//           final double progress =
//               (road["timer"] as int).clamp(0, maxT) / maxT;

//           return Container(
//             margin: const EdgeInsets.only(bottom: 10),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF111827),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: congColor.withOpacity(0.25),
//               ),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     // Direction badge
//                     Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: congColor.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Center(
//                         child: Text(
//                           roadName[0],
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             color: congColor,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '$roadName Road',
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFFF0F4FF),
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             "Green Time: ${road["greenTime"]} sec",
//                             style: const TextStyle(
//                                 fontSize: 11,
//                                 color: Color(0xFF8A9BBE)),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Signal pill
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: lightColor.withOpacity(0.12),
//                         border: Border.all(
//                             color: lightColor.withOpacity(0.35)),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 7,
//                             height: 7,
//                             decoration: BoxDecoration(
//                               color: lightColor,
//                               shape: BoxShape.circle,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: lightColor.withOpacity(0.5),
//                                   blurRadius: 5,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 5),
//                           Text(
//                             road["light"],
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w700,
//                               color: lightColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     // Congestion badge
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 8, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: congColor.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         road["congestion"],
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w700,
//                           color: congColor,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 // Timer progress bar + remaining
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(3),
//                         child: TweenAnimationBuilder<double>(
//                           tween: Tween(begin: 0, end: progress),
//                           duration:
//                               const Duration(milliseconds: 700),
//                           builder: (_, val, __) =>
//                               LinearProgressIndicator(
//                             value: val,
//                             minHeight: 5,
//                             backgroundColor:
//                                 Colors.white.withOpacity(0.05),
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                                 lightColor),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       "${road["timer"]} sec",
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700,
//                         color: lightColor,
//                         fontFamily: 'Courier',
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   // ===== BUILD ===== (same Column structure as original)
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
//           // Popup menu – UNCHANGED logic (same onSelected, same items)
//           PopupMenuButton<int>(
//             icon: const Icon(Icons.menu,
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
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _buildIntersection(),     // same call as original
//             const SizedBox(height: 25),
//             _buildRoadCards(),         // same call as original
//           ],
//         ),
//       ),
//     );
//   }
// }


//new

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:solar/login.dart';

// class CivilianAppPage extends StatefulWidget {
//   const CivilianAppPage({super.key});

//   @override
//   State<CivilianAppPage> createState() => _CivilianAppPageState();
// }

// class _CivilianAppPageState extends State<CivilianAppPage>
//     with TickerProviderStateMixin {

//   // ===== Traffic Data ===== (COMPLETELY UNCHANGED)
//   Map<String, Map<String, dynamic>> roads = {
//     "North": {
//       "light": "Red",
//       "timer": 30,
//       "congestion": "High",
//       "greenTime": 25
//     },
//     "South": {
//       "light": "Green",
//       "timer": 25,
//       "congestion": "Normal",
//       "greenTime": 25
//     },
//     "East": {
//       "light": "Orange",
//       "timer": 5,
//       "congestion": "Medium",
//       "greenTime": 20
//     },
//     "West": {
//       "light": "Red",
//       "timer": 30,
//       "congestion": "High",
//       "greenTime": 30
//     },
//   };

//   final int redDuration    = 30; // UNCHANGED
//   final int orangeDuration = 5;  // UNCHANGED

//   Timer? _timer;

//   // UI-only animation controllers
//   late AnimationController _pulseCtrl;
//   late AnimationController _vehicleCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _startTrafficCycle(); // UNCHANGED

//     _pulseCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _vehicleCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3),
//     )..repeat();
//   }

//   // ===== _startTrafficCycle ===== (COMPLETELY UNCHANGED)
//   void _startTrafficCycle() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       setState(() {
//         roads.forEach((roadName, road) {
//           road["timer"]--;
//           if (road["timer"] <= 0) {
//             if (road["light"] == "Red") {
//               road["light"]      = "Green";
//               road["timer"]      = road["greenTime"];
//               road["congestion"] = "Normal";
//             } else if (road["light"] == "Green") {
//               road["light"]      = "Orange";
//               road["timer"]      = orangeDuration;
//               road["congestion"] = "Medium";
//             } else {
//               road["light"]      = "Red";
//               road["timer"]      = redDuration;
//               road["congestion"] = "High";
//             }
//           }
//         });
//       });
//     });
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

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pulseCtrl.dispose();
//     _vehicleCtrl.dispose();
//     super.dispose();
//   }

//   // ===== _congestionColor ===== (COMPLETELY UNCHANGED)
//   Color _congestionColor(String level) {
//     switch (level) {
//       case "High":   return Colors.red;
//       case "Medium": return Colors.orange;
//       default:       return Colors.green;
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  UI COLOUR + DIRECTION HELPERS
//   // ─────────────────────────────────────────────

//   Color _lightColor(String light) {
//     switch (light) {
//       case "Green":  return const Color(0xFF22C55E);
//       case "Orange": return const Color(0xFFF97316);
//       default:       return const Color(0xFFEF4444);
//     }
//   }

//   // Vehicles enter FROM that road → move toward centre
//   IconData _directionArrow(String road) {
//     switch (road) {
//       case "North": return Icons.arrow_downward_rounded;
//       case "South": return Icons.arrow_upward_rounded;
//       case "East":  return Icons.arrow_back_rounded;
//       default:      return Icons.arrow_forward_rounded; // West
//     }
//   }

//   // ─────────────────────────────────────────────
//   //  INTERSECTION MAP
//   // ─────────────────────────────────────────────
//   Widget _buildIntersection() {
//     const double mapSize = 210.0;
//     const double roadW   = 50.0;
//     const double cx      = mapSize / 2;
//     const double cy      = mapSize / 2;

//     return SizedBox(
//       width: mapSize,
//       height: mapSize,
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.center,
//         children: [

//           // ── Road tarmac ───────────────────────
//           Center(
//             child: Container(
//               width: roadW, height: mapSize,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFCBD5E1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//           ),
//           Center(
//             child: Container(
//               width: mapSize, height: roadW,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFCBD5E1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//           ),

//           // ── Lane centre dashes ────────────────
//           // Vertical dashes (above + below intersection box)
//           ..._vertDashes(mapSize, roadW),
//           // Horizontal dashes (left + right of intersection box)
//           ..._horizDashes(mapSize, roadW),

//           // ── Animated vehicle dots ─────────────
//           ...roads.entries.map((e) {
//             if (e.value["light"] != "Green") return const SizedBox.shrink();
//             return AnimatedBuilder(
//               animation: _vehicleCtrl,
//               builder: (_, __) =>
//                   _vehicleDot(e.key, _vehicleCtrl.value, mapSize, roadW),
//             );
//           }),

//           // ── Centre solar circle ───────────────
//           Container(
//             width: 42, height: 42,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.orange.withOpacity(0.22),
//                   blurRadius: 12,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: const Center(
//               child: Text('☀', style: TextStyle(fontSize: 22)),
//             ),
//           ),

//           // ── Signal dots at road ends ──────────
//           Positioned(top: 4,    left: cx - 13, child: _signalPin("North")),
//           Positioned(bottom: 4, left: cx - 13, child: _signalPin("South")),
//           Positioned(left: 4,   top:  cy - 13, child: _signalPin("West")),
//           Positioned(right: 4,  top:  cy - 13, child: _signalPin("East")),
//         ],
//       ),
//     );
//   }

//   // Vertical lane dashes
//   List<Widget> _vertDashes(double mapSize, double roadW) {
//     final double zoneTop    = (mapSize - roadW) / 2;
//     final double zoneBottom = (mapSize + roadW) / 2;
//     final List<Widget> dashes = [];
//     for (double y = 8; y < mapSize - 8; y += 20) {
//       if (y >= zoneTop - 8 && y <= zoneBottom + 8) continue;
//       dashes.add(Positioned(
//         left: mapSize / 2 - 1,
//         top: y,
//         child: Container(
//           width: 2, height: 10,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.75),
//             borderRadius: BorderRadius.circular(1),
//           ),
//         ),
//       ));
//     }
//     return dashes;
//   }

//   // Horizontal lane dashes
//   List<Widget> _horizDashes(double mapSize, double roadW) {
//     final double zoneLeft  = (mapSize - roadW) / 2;
//     final double zoneRight = (mapSize + roadW) / 2;
//     final List<Widget> dashes = [];
//     for (double x = 8; x < mapSize - 8; x += 20) {
//       if (x >= zoneLeft - 8 && x <= zoneRight + 8) continue;
//       dashes.add(Positioned(
//         top: mapSize / 2 - 1,
//         left: x,
//         child: Container(
//           width: 10, height: 2,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.75),
//             borderRadius: BorderRadius.circular(1),
//           ),
//         ),
//       ));
//     }
//     return dashes;
//   }

//   // Animated vehicle dot moving toward centre (only when green)
//   Widget _vehicleDot(
//       String road, double t, double mapSize, double roadW) {
//     const double r       = 5.0;
//     final double cx      = mapSize / 2;
//     final double cy      = mapSize / 2;
//     const double edge    = 10.0;
//     const double stop    = 28.0;

//     double x, y;
//     switch (road) {
//       case "North":
//         x = cx - r;
//         y = edge + (cy - stop - edge) * t;
//         break;
//       case "South":
//         x = cx + r;
//         y = mapSize - edge - (cy - stop - edge) * t;
//         break;
//       case "East":
//         x = mapSize - edge - (cx - stop - edge) * t;
//         y = cy - r;
//         break;
//       default: // West
//         x = edge + (cx - stop - edge) * t;
//         y = cy + r;
//     }

//     return Positioned(
//       left: x - r,
//       top: y - r,
//       child: Container(
//         width: r * 2, height: r * 2,
//         decoration: BoxDecoration(
//           color: const Color(0xFF3B82F6),
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFF3B82F6).withOpacity(0.5),
//               blurRadius: 6,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Signal pin widget: coloured circle + direction arrow icon
//   Widget _signalPin(String roadName) {
//     final String light   = roads[roadName]!["light"];
//     final Color  col     = _lightColor(light);
//     final IconData arrow = _directionArrow(roadName);

//     return Container(
//       width: 26, height: 26,
//       decoration: BoxDecoration(
//         color: col,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: col.withOpacity(0.5),
//             blurRadius: 8,
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: Center(
//         child: Icon(arrow, color: Colors.white, size: 13),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  ROAD STATUS CARD (compact)
//   // ─────────────────────────────────────────────
//   Widget _buildRoadCard(String roadName) {
//     final road       = roads[roadName]!;
//     final congColor  = _congestionColor(road["congestion"]);
//     final lightColor = _lightColor(road["light"]);
//     final arrow      = _directionArrow(roadName);

//     final int maxT = road["light"] == "Green"
//         ? road["greenTime"] as int
//         : road["light"] == "Orange"
//             ? orangeDuration
//             : redDuration;
//     final double progress =
//         (road["timer"] as int).clamp(0, maxT) / maxT;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: lightColor.withOpacity(0.08),
//             blurRadius: 14,
//             offset: const Offset(0, 4),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 6,
//             offset: const Offset(0, 1),
//           ),
//         ],
//         border: Border.all(color: lightColor.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [

//           // Direction circle
//           Container(
//             width: 36, height: 36,
//             decoration: BoxDecoration(
//               color: lightColor.withOpacity(0.10),
//               shape: BoxShape.circle,
//             ),
//             child: Center(
//               child: Icon(arrow, color: lightColor, size: 17),
//             ),
//           ),

//           const SizedBox(width: 10),

//           // Road name + green time
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   '$roadName Road',
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF1E293B),
//                     height: 1.2,
//                   ),
//                 ),
//                 Text(
//                   'Green: ${road["greenTime"]}s',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey.shade400,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Countdown ring
//           SizedBox(
//             width: 36, height: 36,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 TweenAnimationBuilder<double>(
//                   tween: Tween(begin: 0.0, end: progress),
//                   duration: const Duration(milliseconds: 600),
//                   builder: (_, val, __) => CircularProgressIndicator(
//                     value: val,
//                     strokeWidth: 3,
//                     backgroundColor: Colors.grey.shade100,
//                     valueColor:
//                         AlwaysStoppedAnimation<Color>(lightColor),
//                   ),
//                 ),
//                 Text(
//                   '${road["timer"]}',
//                   style: TextStyle(
//                     fontSize: 9,
//                     fontWeight: FontWeight.w800,
//                     color: lightColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 10),

//           // Signal pill + congestion tag
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 9, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: lightColor,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   road["light"],
//                   style: const TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                     letterSpacing: 0.2,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: congColor.withOpacity(0.10),
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   road["congestion"],
//                   style: TextStyle(
//                     fontSize: 9,
//                     fontWeight: FontWeight.w700,
//                     color: congColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────
//   //  BUILD  (no SingleChildScrollView — fits screen)
//   // ─────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       // ── AppBar ────────────────────────────────
//       appBar: AppBar(
//         backgroundColor: Colors.orange.shade900,
//         elevation: 0,
//         title: const Text(
//           "SolarStat",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         actions: [
//           PopupMenuButton<int>(
//             icon: const Icon(Icons.menu, color: Colors.white),
//             onSelected: (value) {
//               if (value == 1) _logout(); // UNCHANGED
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

//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               // ── Top greeting row ───────────────
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Traffic Overview',
//                         style: TextStyle(
//                           fontSize: 19,
//                           fontWeight: FontWeight.w800,
//                           color: Color(0xFF1E293B),
//                           height: 1.2,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       AnimatedBuilder(
//                         animation: _pulseCtrl,
//                         builder: (_, __) => Row(
//                           children: [
//                             Container(
//                               width: 6, height: 6,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.green.withOpacity(
//                                     0.5 + 0.5 * _pulseCtrl.value),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.green.withOpacity(0.35),
//                                     blurRadius: 6,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               'Live · Real-time updates',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.grey.shade500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Spacer(),
//                   // Solar chip
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 11, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       border: Border.all(
//                           color: Colors.orange.shade200),
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text('☀',
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: Colors.orange.shade700)),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Solar',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.orange.shade700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 14),

//               // ── Intersection card ─────────────────
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                     vertical: 14, horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF8FAFC),
//                   borderRadius: BorderRadius.circular(20),
//                   border:
//                       Border.all(color: const Color(0xFFE2E8F0)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.03),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     // Map
//                     Center(child: _buildIntersection()),

//                     const SizedBox(height: 10),

//                     // Legend
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         _legendItem(
//                             const Color(0xFF3B82F6), 'Moving'),
//                         const SizedBox(width: 14),
//                         _legendItem(
//                             const Color(0xFF22C55E), 'Green'),
//                         const SizedBox(width: 14),
//                         _legendItem(
//                             const Color(0xFFF97316), 'Orange'),
//                         const SizedBox(width: 14),
//                         _legendItem(
//                             const Color(0xFFEF4444), 'Red'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 14),

//               // ── Road status label ─────────────────
//               const Text(
//                 'ROAD STATUS',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2,
//                   color: Color(0xFF94A3B8),
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // ── 4 Road cards ──────────────────────
//               Expanded(
//                 child: Column(
//                   children: roads.keys.map((name) {
//                     final isLast = name == roads.keys.last;
//                     return Expanded(
//                       child: Padding(
//                         padding:
//                             EdgeInsets.only(bottom: isLast ? 0 : 8),
//                         child: _buildRoadCard(name),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Legend item helper
//   Widget _legendItem(Color color, String label) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 7, height: 7,
//           decoration: BoxDecoration(
//               color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 4),
//         Text(
//           label,
//           style: TextStyle(
//               fontSize: 9,
//               color: Colors.grey.shade500,
//               fontWeight: FontWeight.w500),
//         ),
//       ],
//     );
//   }
// }
