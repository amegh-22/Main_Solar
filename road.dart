// import 'dart:async';
// import 'package:flutter/material.dart';

// class RoadPage extends StatefulWidget {
//   final String roadName;

//   const RoadPage({super.key, required this.roadName});

//   @override
//   State<RoadPage> createState() => _RoadPageState();
// }

// class _RoadPageState extends State<RoadPage> {

//   String currentLight = "Red";
//   int timer = 30;
//   String congestion = "High";

//   final int redDuration = 30;
//   final int greenDuration = 25;
//   final int orangeDuration = 5;

//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startCycle();
//   }

//   void _startCycle() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       setState(() {
//         timer--;

//         if (timer <= 0) {
//           if (currentLight == "Red") {
//             currentLight = "Green";
//             timer = greenDuration;
//             congestion = "Normal";
//           } 
//           else if (currentLight == "Green") {
//             currentLight = "Orange";
//             timer = orangeDuration;
//             congestion = "Medium";
//           } 
//           else {
//             currentLight = "Red";
//             timer = redDuration;
//             congestion = "High";
//           }
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   Color _congestionColor() {
//     switch (congestion) {
//       case "High":
//         return Colors.red;
//       case "Medium":
//         return Colors.orange;
//       default:
//         return Colors.green;
//     }
//   }

//   Widget _trafficLight(Color color, bool active) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       width: active ? 60 : 50,
//       height: active ? 60 : 50,
//       decoration: BoxDecoration(
//         color: active ? color : color.withOpacity(0.3),
//         shape: BoxShape.circle,
//       ),
//     );
//   }

//   // ===== Beautiful Road View =====
//   Widget _roadView() {
//     return Container(
//       height: 200,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade800,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [

//           // Lane markings
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(
//               8,
//               (index) => Container(
//                 margin: const EdgeInsets.symmetric(vertical: 4),
//                 width: 6,
//                 height: 12,
//                 color: Colors.white,
//               ),
//             ),
//           ),

//           // Traffic light on road
//           Positioned(
//             right: 20,
//             child: Column(
//               children: [
//                 _trafficLight(Colors.red, currentLight == "Red"),
//                 _trafficLight(Colors.orange, currentLight == "Orange"),
//                 _trafficLight(Colors.green, currentLight == "Green"),
//               ],
//             ),
//           ),
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
//         title: Text(
//           widget.roadName,
//           style: const TextStyle(color: Colors.white),
//         ),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [

//             _roadView(),

//             const SizedBox(height: 30),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _congestionColor().withOpacity(0.1),
//                 border: Border.all(color: _congestionColor()),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   const Text("Congestion"),
//                   Text(
//                     congestion,
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: _congestionColor(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             Text(
//               "Current: $currentLight",
//               style: const TextStyle(fontSize: 18),
//             ),

//             Text(
//               "Time Remaining: $timer sec",
//               style: const TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
