// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:solar/login.dart';

// class AdminUploadPage extends StatefulWidget {
//   const AdminUploadPage({super.key});

//   @override
//   State<AdminUploadPage> createState() => _AdminUploadPageState();
// }

// class _AdminUploadPageState extends State<AdminUploadPage> {
//   final List<String> roads = ["North", "South", "East", "West"];

//   Map<String, File?> mobileFiles = {};
//   Map<String, Uint8List?> webFiles = {};
//   Map<String, bool> uploadingState = {};

//   bool isUploadingAll = false;

//   // ===== Cloudinary Config =====
//   static const cloudName = "drcymgxjb";
//   static const uploadPreset = "solarup";

//   // ===== OpenWeather API =====
//   // 🔴 ADD YOUR API KEY HERE
//   static const String weatherApiKey = "8ab607f3516600a5ffe787d46802d740";

//   @override
//   void initState() {
//     super.initState();
//     for (var road in roads) {
//       mobileFiles[road] = null;
//       webFiles[road] = null;
//       uploadingState[road] = false;
//     }
//   }

//   // ================= LOGOUT =================
//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();
//     if (!mounted) return;

//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   // ================= WEATHER =================
//   Future<Map<String, dynamic>> _getWeatherData() async {
//     try {
//       final url = Uri.parse(
//           "https://api.openweathermap.org/data/2.5/weather?q=Thiruvananthapuram&appid=$weatherApiKey&units=metric");

//       final response = await http.get(url);
//       final data = jsonDecode(response.body);

//       String condition = data["weather"][0]["main"];

//       String weather;
//       int sunlight;

//       if (condition == "Clear") {
//         weather = "Sunny";
//         sunlight = 90;
//       } else if (condition == "Clouds") {
//         weather = "Cloudy";
//         sunlight = 50;
//       } else {
//         weather = "Rainy";
//         sunlight = 20;
//       }

//       return {
//         "weather": weather,
//         "sunlight": sunlight,
//       };
//     } catch (e) {
//       return {
//         "weather": "Unknown",
//         "sunlight": 0,
//       };
//     }
//   }

//   // ================= PICK VIDEO =================
//   Future<void> _pickVideo(String road) async {
//     FilePickerResult? result =
//         await FilePicker.platform.pickFiles(type: FileType.video, withData: true);

//     if (result == null) return;

//     final file = result.files.single;

//     setState(() {
//       if (kIsWeb) {
//         webFiles[road] = file.bytes;
//         mobileFiles[road] = null;
//       } else {
//         mobileFiles[road] = File(file.path!);
//         webFiles[road] = null;
//       }
//     });
//   }

//   // ================= CLOUDINARY =================
//   Future<String?> _uploadToCloudinary(String road) async {
//     final uri = Uri.parse(
//       "https://api.cloudinary.com/v1_1/$cloudName/video/upload",
//     );

//     var request = http.MultipartRequest("POST", uri);
//     request.fields['upload_preset'] = uploadPreset;
//     request.fields['folder'] = "traffic_videos";

//     if (kIsWeb) {
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'file',
//           webFiles[road]!,
//           filename: "$road.mp4",
//         ),
//       );
//     } else {
//       request.files.add(
//         await http.MultipartFile.fromPath('file', mobileFiles[road]!.path),
//       );
//     }

//     var response = await request.send();

//     if (response.statusCode == 200) {
//       var res = await response.stream.bytesToString();
//       var data = jsonDecode(res);
//       return data["secure_url"];
//     }
//     return null;
//   }

//   // ================= UPLOAD ONE =================
//   Future<void> _uploadSingle(String road) async {
//     if (mobileFiles[road] == null && webFiles[road] == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Select video for $road")));
//       return;
//     }

//     setState(() => uploadingState[road] = true);

//     try {
//       // 1. Upload video
//       String? url = await _uploadToCloudinary(road);

//       if (url != null) {
//         // 2. Fetch weather at current time
//         final weatherData = await _getWeatherData();

//         // 3. Save video + weather in Firestore
//         await FirebaseFirestore.instance
//             .collection("traffic_data")
//             .doc(road)
//             .set({
//           "videoUrl": url,
//           "weather": weatherData["weather"],
//           "sunlight": weatherData["sunlight"],
//           "updatedAt": FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       }

//       setState(() {
//         uploadingState[road] = false;
//         mobileFiles[road] = null;
//         webFiles[road] = null;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("$road uploaded")));
//     } catch (e) {
//       setState(() => uploadingState[road] = false);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
//     }
//   }

//   // ================= UPLOAD ALL =================
//   Future<void> _uploadAll() async {
//     setState(() => isUploadingAll = true);

//     for (var road in roads) {
//       if (mobileFiles[road] != null || webFiles[road] != null) {
//         await _uploadSingle(road);
//       }
//     }

//     setState(() => isUploadingAll = false);

//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text("All uploads completed")));
//   }

//   // ================= ROAD CARD (UI unchanged) =================
//   Widget _roadCard(String road) {
//     bool isUploading = uploadingState[road]!;

//     return Container(
//       width: 420,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             road,
//             style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             (mobileFiles[road] == null && webFiles[road] == null)
//                 ? "No Video Selected"
//                 : "Video Selected",
//             style: TextStyle(color: Colors.grey[700]),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               SizedBox(
//                 width: 90,
//                 height: 34,
//                 child: ElevatedButton(
//                   onPressed: isUploadingAll ? null : () => _pickVideo(road),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange.shade800,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text("Select", style: TextStyle(fontSize: 12)),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               SizedBox(
//                 width: 90,
//                 height: 34,
//                 child: ElevatedButton(
//                   onPressed: (isUploading || isUploadingAll)
//                       ? null
//                       : () => _uploadSingle(road),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: isUploading
//                       ? const SizedBox(
//                           height: 14,
//                           width: 14,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text("Upload", style: TextStyle(fontSize: 12)),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         backgroundColor: Colors.orange.shade900,
//         title: const Text("SolarStat", style: TextStyle(color: Colors.white)),
//         actions: [
//           PopupMenuButton<int>(
//             icon: const Icon(Icons.menu, color: Colors.white),
//             onSelected: (value) {
//               if (value == 1) _logout();
//             },
//             itemBuilder: (context) => const [
//               PopupMenuItem(value: 1, child: Text("Logout")),
//             ],
//           ),
//         ],
//       ),
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 800),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               const Text(
//                 "ADMIN PAGE",
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 25),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 20,
//                   mainAxisSpacing: 20,
//                   childAspectRatio: 1.6,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   children: roads.map((road) => _roadCard(road)).toList(),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: 200,
//                 height: 42,
//                 child: ElevatedButton(
//                   onPressed: isUploadingAll ? null : _uploadAll,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange.shade900,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: isUploadingAll
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text(
//                           "Upload All",
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 25),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//new

import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:solar/login.dart';
import 'package:video_player/video_player.dart';

class AdminUploadPage extends StatefulWidget {
  const AdminUploadPage({super.key});

  @override
  State<AdminUploadPage> createState() => _AdminUploadPageState();
}

class _AdminUploadPageState extends State<AdminUploadPage> {
  final List<String> junctions = ["Junction 1", "Junction 2", "Junction 3"];
  final List<String> roads = ["North", "South", "East", "West"];

  late String selectedJunction;

  Map<String, File?> mobileFiles = {};
  Map<String, Uint8List?> webFiles = {};
  Map<String, bool> uploadingState = {};

  // Video preview controllers (one per road key)
  Map<String, VideoPlayerController?> videoControllers = {};
  Map<String, Future<void>?> videoInitFutures = {};

  static const cloudName = "drcymgxjb";
  static const uploadPreset = "solarup";

  static const weatherApiKey = "8ab607f3516600a5ffe787d46802d740";

  @override
  void initState() {
    super.initState();

    for (var junction in junctions) {
      for (var road in roads) {
        String key = "$junction-$road";
        mobileFiles[key] = null;
        webFiles[key] = null;
        uploadingState[key] = false;
        videoControllers[key] = null;
        videoInitFutures[key] = null;
      }
    }

    selectedJunction = junctions.first;
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ================= WEATHER =================
  Future<Map<String, dynamic>> _getWeatherData() async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=Thiruvananthapuram&appid=$weatherApiKey&units=metric",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    String condition = data["weather"][0]["main"];

    if (condition == "Clear") {
      return {"weather": "Sunny", "sunlight": 90};
    } else if (condition == "Clouds") {
      return {"weather": "Cloudy", "sunlight": 50};
    } else {
      return {"weather": "Rainy", "sunlight": 20};
    }
  }

  // ================= PICK VIDEO =================
  Future<void> _pickVideo(String key) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;

    // Dispose any existing controller for this key
    videoControllers[key]?.dispose();

    VideoPlayerController? controller;
    Future<void>? initFuture;

    final isWeb = kIsWeb;
    Uint8List? bytes;
    File? fileOnDisk;

    if (isWeb) {
      bytes = file.bytes;
      if (bytes != null) {
        // Create a data URI for web video preview
        final dataUri = 'data:video/mp4;base64,${base64Encode(bytes)}';
        controller = VideoPlayerController.network(dataUri);
        initFuture = controller.initialize();
      }
    } else {
      fileOnDisk = File(file.path!);
      controller = VideoPlayerController.file(fileOnDisk);
      initFuture = controller.initialize();
    }

    setState(() {
      webFiles[key] = bytes;
      mobileFiles[key] = fileOnDisk;
      videoControllers[key] = controller;
      videoInitFutures[key] = initFuture;
    });
  }

  // ================= CLOUDINARY =================
  Future<String?> _uploadToCloudinary(String key) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/video/upload",
    );

    var request = http.MultipartRequest("POST", uri);

    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = "traffic_videos";

    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          webFiles[key]!,
          filename: "$key.mp4",
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath('file', mobileFiles[key]!.path),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      var data = jsonDecode(res);
      return data["secure_url"];
    }

    return null;
  }

  // ================= UPLOAD =================
  Future<void> _uploadSingle(String junction, String road) async {
    String key = "$junction-$road";

    if (mobileFiles[key] == null && webFiles[key] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Select video for $road")));
      return;
    }

    setState(() => uploadingState[key] = true);

    try {
      String? url = await _uploadToCloudinary(key);

      if (url != null) {
        final weather = await _getWeatherData();

        await FirebaseFirestore.instance
            .collection("traffic_data")
            .doc(junction)
            .collection("roads")
            .doc(road)
            .set({
              "videoUrl": url,
              "weather": weather["weather"],
              "sunlight": weather["sunlight"],
              "updatedAt": FieldValue.serverTimestamp(),
              // Mark this video as needing background processing
              "needsProcessing": true,
              "processed": false,
            });
      }

      setState(() {
        uploadingState[key] = false;
        mobileFiles[key] = null;
        webFiles[key] = null;
        videoControllers[key]?.dispose();
        videoControllers[key] = null;
        videoInitFutures[key] = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$road uploaded")));
    } catch (e) {
      setState(() => uploadingState[key] = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload failed")));
    }
  }

  @override
  void dispose() {
    for (final controller in videoControllers.values) {
      controller?.dispose();
    }
    super.dispose();
  }

  // ================= ROAD CARD =================
  Widget _roadCard(String junction, String road) {
    String key = "$junction-$road";
    bool hasFile = mobileFiles[key] != null || webFiles[key] != null;

    final controller = videoControllers[key];
    final initFuture = videoInitFutures[key];

    return Container(
      constraints: const BoxConstraints(minHeight: 230, maxHeight: 260),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(road, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),

          if (controller != null && initFuture != null)
            FutureBuilder<void>(
              future: initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    });
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 180,
                      minHeight: 120,
                      maxWidth: 180,
                      minWidth: 120,
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(controller),
                          if (!controller.value.isPlaying)
                            const Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: Colors.white70,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else
            SizedBox(
              height: 100,
              child: Center(
                child: Text(
                  hasFile ? "Loading preview..." : "No preview",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),

          const SizedBox(height: 5),

          ElevatedButton(
            onPressed: uploadingState[key]! ? null : () => _pickVideo(key),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              minimumSize: const Size(70, 30),
            ),
            child: const Text("Select", style: TextStyle(fontSize: 12)),
          ),

          const SizedBox(height: 5),

          ElevatedButton(
            onPressed: (uploadingState[key]! || !hasFile)
                ? null
                : () => _uploadSingle(junction, road),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(70, 30),
            ),
            child: uploadingState[key]!
                ? const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Upload", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ================= JUNCTION CARD =================
  Widget _junctionCard(String junction) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            junction,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _roadCard(junction, roads[0])),
                      const SizedBox(width: 10),
                      Expanded(child: _roadCard(junction, roads[1])),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _roadCard(junction, roads[2])),
                      const SizedBox(width: 10),
                      Expanded(child: _roadCard(junction, roads[3])),
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.orange.shade900,
        title: const Text("SolarStat", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (v) {
              if (v == 1) _logout();
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 1, child: Text("Logout")),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          const Text(
            "ADMIN PAGE",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DropdownButtonFormField<String>(
              value: selectedJunction,
              decoration: InputDecoration(
                labelText: "Select Junction",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: junctions
                  .map(
                    (junction) => DropdownMenuItem(
                      value: junction,
                      child: Text(junction),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedJunction = value;
                  });
                }
              },
            ),
          ),

          const SizedBox(height: 20),

          Expanded(child: _junctionCard(selectedJunction)),
        ],
      ),
    );
  }
}
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:solar/login.dart';

// class AdminUploadPage extends StatefulWidget {
//   const AdminUploadPage({super.key});

//   @override
//   State<AdminUploadPage> createState() => _AdminUploadPageState();
// }

// class _AdminUploadPageState extends State<AdminUploadPage>
//     with SingleTickerProviderStateMixin {

//   // ===== Data ===== (COMPLETELY UNCHANGED)
//   final List<String> roads = ["North", "South", "East", "West"];

//   Map<String, File?> mobileFiles = {};
//   Map<String, Uint8List?> webFiles = {};
//   Map<String, bool> uploadingState = {};

//   bool isUploadingAll = false;

//   // ===== Cloudinary Config ===== (COMPLETELY UNCHANGED)
//   static const cloudName = "drcymgxjb";
//   static const uploadPreset = "solarup";

//   // ===== OpenWeather API ===== (COMPLETELY UNCHANGED)
//   static const String weatherApiKey = "8ab607f3516600a5ffe787d46802d740";

//   // UI-only
//   late AnimationController _logoGlow;

//   @override
//   void initState() {
//     super.initState();
//     // UNCHANGED init
//     for (var road in roads) {
//       mobileFiles[road] = null;
//       webFiles[road] = null;
//       uploadingState[road] = false;
//     }
//     _logoGlow = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _logoGlow.dispose();
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

//   // ===== _getWeatherData ===== (COMPLETELY UNCHANGED)
//   Future<Map<String, dynamic>> _getWeatherData() async {
//     try {
//       final url = Uri.parse(
//           "https://api.openweathermap.org/data/2.5/weather?q=Thiruvananthapuram&appid=$weatherApiKey&units=metric");

//       final response = await http.get(url);
//       final data = jsonDecode(response.body);

//       String condition = data["weather"][0]["main"];

//       String weather;
//       int sunlight;

//       if (condition == "Clear") {
//         weather = "Sunny";
//         sunlight = 90;
//       } else if (condition == "Clouds") {
//         weather = "Cloudy";
//         sunlight = 50;
//       } else {
//         weather = "Rainy";
//         sunlight = 20;
//       }

//       return {
//         "weather": weather,
//         "sunlight": sunlight,
//       };
//     } catch (e) {
//       return {
//         "weather": "Unknown",
//         "sunlight": 0,
//       };
//     }
//   }

//   // ===== _pickVideo ===== (COMPLETELY UNCHANGED)
//   Future<void> _pickVideo(String road) async {
//     FilePickerResult? result =
//         await FilePicker.platform.pickFiles(type: FileType.video, withData: true);

//     if (result == null) return;

//     final file = result.files.single;

//     setState(() {
//       if (kIsWeb) {
//         webFiles[road] = file.bytes;
//         mobileFiles[road] = null;
//       } else {
//         mobileFiles[road] = File(file.path!);
//         webFiles[road] = null;
//       }
//     });
//   }

//   // ===== _uploadToCloudinary ===== (COMPLETELY UNCHANGED)
//   Future<String?> _uploadToCloudinary(String road) async {
//     final uri = Uri.parse(
//       "https://api.cloudinary.com/v1_1/$cloudName/video/upload",
//     );

//     var request = http.MultipartRequest("POST", uri);
//     request.fields['upload_preset'] = uploadPreset;
//     request.fields['folder'] = "traffic_videos";

//     if (kIsWeb) {
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'file',
//           webFiles[road]!,
//           filename: "$road.mp4",
//         ),
//       );
//     } else {
//       request.files.add(
//         await http.MultipartFile.fromPath('file', mobileFiles[road]!.path),
//       );
//     }

//     var response = await request.send();

//     if (response.statusCode == 200) {
//       var res = await response.stream.bytesToString();
//       var data = jsonDecode(res);
//       return data["secure_url"];
//     }
//     return null;
//   }

//   // ===== _uploadSingle ===== (COMPLETELY UNCHANGED)
//   Future<void> _uploadSingle(String road) async {
//     if (mobileFiles[road] == null && webFiles[road] == null) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Select video for $road")));
//       return;
//     }

//     setState(() => uploadingState[road] = true);

//     try {
//       String? url = await _uploadToCloudinary(road);

//       if (url != null) {
//         final weatherData = await _getWeatherData();

//         await FirebaseFirestore.instance
//             .collection("traffic_data")
//             .doc(road)
//             .set({
//           "videoUrl": url,
//           "weather": weatherData["weather"],
//           "sunlight": weatherData["sunlight"],
//           "updatedAt": FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       }

//       setState(() {
//         uploadingState[road] = false;
//         mobileFiles[road] = null;
//         webFiles[road] = null;
//       });

//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("$road uploaded")));
//     } catch (e) {
//       setState(() => uploadingState[road] = false);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
//     }
//   }

//   // ===== _uploadAll ===== (COMPLETELY UNCHANGED)
//   Future<void> _uploadAll() async {
//     setState(() => isUploadingAll = true);

//     for (var road in roads) {
//       if (mobileFiles[road] != null || webFiles[road] != null) {
//         await _uploadSingle(road);
//       }
//     }

//     setState(() => isUploadingAll = false);

//     ScaffoldMessenger.of(context)
//         .showSnackBar(const SnackBar(content: Text("All uploads completed")));
//   }

//   // ───────────────────────────────────────────
//   //  UI ONLY
//   // ───────────────────────────────────────────

//   // Accent colour per direction
//   Color _roadAccent(String road) {
//     switch (road) {
//       case "North": return const Color(0xFF2196F3);
//       case "South": return const Color(0xFF4CAF50);
//       case "East":  return const Color(0xFFFFC107);
//       default:      return const Color(0xFFF44336);
//     }
//   }

//   String _roadArrow(String road) {
//     switch (road) {
//       case "North": return '↑';
//       case "South": return '↓';
//       case "East":  return '→';
//       default:      return '←';
//     }
//   }

//   // ===== _roadCard ===== (UI redesigned; _pickVideo/_uploadSingle calls unchanged)
//   Widget _roadCard(String road) {
//     final bool isUploading = uploadingState[road]!;
//     final bool hasFile =
//         mobileFiles[road] != null || webFiles[road] != null;
//     final Color accent = _roadAccent(road);

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF111827),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: hasFile
//               ? accent.withOpacity(0.4)
//               : Colors.white.withOpacity(0.07),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Card header ───────────────────
//           Row(
//             children: [
//               Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: accent.withOpacity(0.12),
//                   border: Border.all(color: accent.withOpacity(0.2)),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${_roadArrow(road)} ${road[0]}',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w800,
//                       color: accent,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '$road Road',
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFFF0F4FF),
//                         letterSpacing: 0.3,
//                       ),
//                     ),
//                     Text(
//                       'CAM-${road[0]}01',
//                       style: const TextStyle(
//                           fontSize: 11, color: Color(0xFF8A9BBE)),
//                     ),
//                   ],
//                 ),
//               ),
//               // Status pill
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: hasFile
//                       ? Colors.green.withOpacity(0.12)
//                       : Colors.white.withOpacity(0.04),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   hasFile ? 'Selected' : 'No File',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w700,
//                     color: hasFile
//                         ? Colors.green
//                         : const Color(0xFF4A5568),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // ── Drop / selected area ──────────
//           GestureDetector(
//             onTap: isUploadingAll ? null : () => _pickVideo(road), // UNCHANGED call
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 22),
//               decoration: BoxDecoration(
//                 color: hasFile
//                     ? accent.withOpacity(0.05)
//                     : const Color(0xFF151D2E),
//                 border: Border.all(
//                   color: hasFile
//                       ? accent.withOpacity(0.3)
//                       : Colors.white.withOpacity(0.06),
//                   width: 1.5,
//                 ),
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     width: 46,
//                     height: 46,
//                     decoration: BoxDecoration(
//                       color: accent.withOpacity(0.12),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Text(
//                         hasFile ? '🎬' : '📹',
//                         style: const TextStyle(fontSize: 22),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     hasFile
//                         ? 'Video Selected'
//                         : 'Tap to browse video',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: hasFile
//                           ? const Color(0xFFF0F4FF)
//                           : const Color(0xFF8A9BBE),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     hasFile
//                         ? '$road road footage ready'
//                         : 'MP4 · AVI · MOV · MKV',
//                     style: const TextStyle(
//                         fontSize: 11, color: Color(0xFF4A5568)),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 14),

//           // ── Action buttons ─────────────────
//           Row(
//             children: [
//               // Select button – _pickVideo call UNCHANGED
//               Expanded(
//                 child: GestureDetector(
//                   onTap: isUploadingAll
//                       ? null
//                       : () => _pickVideo(road), // UNCHANGED
//                   child: Container(
//                     height: 38,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                           color: Colors.white.withOpacity(0.1)),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Select',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF8A9BBE),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               // Upload button – _uploadSingle call UNCHANGED
//               Expanded(
//                 child: GestureDetector(
//                   onTap: (isUploading || isUploadingAll)
//                       ? null
//                       : () => _uploadSingle(road), // UNCHANGED
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     height: 38,
//                     decoration: BoxDecoration(
//                       gradient: (!isUploading && !isUploadingAll)
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.green.shade600,
//                                 Colors.green.shade700,
//                               ],
//                             )
//                           : null,
//                       color: (isUploading || isUploadingAll)
//                           ? Colors.white.withOpacity(0.04)
//                           : null,
//                       borderRadius: BorderRadius.circular(10),
//                       boxShadow:
//                           (!isUploading && !isUploadingAll && hasFile)
//                               ? [
//                                   BoxShadow(
//                                     color: Colors.green
//                                         .withOpacity(0.25),
//                                     blurRadius: 10,
//                                   ),
//                                 ]
//                               : null,
//                     ),
//                     child: Center(
//                       child: isUploading
//                           ? const SizedBox(
//                               width: 16,
//                               height: 16,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : Text(
//                               'Upload',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700,
//                                 color: (isUploading ||
//                                         isUploadingAll)
//                                     ? const Color(0xFF4A5568)
//                                     : Colors.white,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ===== BUILD ===== (same GridView + Upload All button structure as original)
//   @override
//   Widget build(BuildContext context) {
//     final int readyCount = roads
//         .where((r) =>
//             mobileFiles[r] != null || webFiles[r] != null)
//         .length;

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
//             AnimatedBuilder(
//               animation: _logoGlow,
//               builder: (_, __) => Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFFFFC107), Color(0xFFFF8C00)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFFFFC107).withOpacity(
//                           0.2 + 0.25 * _logoGlow.value),
//                       blurRadius: 10 + 8 * _logoGlow.value,
//                     ),
//                   ],
//                 ),
//                 child: const Center(
//                     child:
//                         Text('☀', style: TextStyle(fontSize: 15))),
//               ),
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
//           // Admin badge
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 14),
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 12, vertical: 0),
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFC107).withOpacity(0.1),
//               border: Border.all(
//                   color:
//                       const Color(0xFFFFC107).withOpacity(0.25)),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: const Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.admin_panel_settings,
//                     size: 13, color: Color(0xFFFFC107)),
//                 SizedBox(width: 5),
//                 Text(
//                   'ADMIN',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFFFFC107),
//                     letterSpacing: 1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           // Popup menu – UNCHANGED logic
//           PopupMenuButton<int>(
//             icon: const Icon(Icons.menu,
//                 color: Color(0xFF8A9BBE)),
//             color: const Color(0xFF151D2E),
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12)),
//             onSelected: (value) {
//               if (value == 1) _logout(); // UNCHANGED
//             },
//             itemBuilder: (context) => const [
//               PopupMenuItem(
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
//       body: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 800),
//           child: Column(
//             children: [
//               const SizedBox(height: 24),

//               // Page header
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         RichText(
//                           text: const TextSpan(
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.w800,
//                             ),
//                             children: [
//                               TextSpan(
//                                 text: 'Upload Traffic ',
//                                 style: TextStyle(
//                                     color: Color(0xFFF0F4FF)),
//                               ),
//                               TextSpan(
//                                 text: 'Videos',
//                                 style: TextStyle(
//                                     color: Color(0xFFFFC107)),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         const Text(
//                           'Select and upload footage for each road direction',
//                           style: TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF8A9BBE)),
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     // File count badge
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 14, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFC107)
//                             .withOpacity(0.1),
//                         border: Border.all(
//                             color: const Color(0xFFFFC107)
//                                 .withOpacity(0.25)),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         '$readyCount / 4',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800,
//                           color: Color(0xFFFFC107),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // GridView – SAME structure as original (2-column grid)
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 1.1,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20),
//                   children: roads
//                       .map((road) => _roadCard(road))
//                       .toList(),
//                 ),
//               ),

//               const SizedBox(height: 10),

//               // Upload All – _uploadAll call UNCHANGED
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20),
//                 child: Container(
//                   padding: const EdgeInsets.all(18),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF111827),
//                     border: Border.all(
//                         color: Colors.white.withOpacity(0.07)),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Upload Summary',
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w700,
//                                 color: Color(0xFFF0F4FF),
//                               ),
//                             ),
//                             const SizedBox(height: 3),
//                             Text(
//                               readyCount == 0
//                                   ? 'No videos selected yet.'
//                                   : '$readyCount video${readyCount > 1 ? 's' : ''} ready to upload.',
//                               style: const TextStyle(
//                                   fontSize: 11,
//                                   color: Color(0xFF8A9BBE)),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       // Upload All button – UNCHANGED logic
//                       GestureDetector(
//                         onTap: isUploadingAll
//                             ? null
//                             : _uploadAll, // UNCHANGED
//                         child: AnimatedContainer(
//                           duration:
//                               const Duration(milliseconds: 200),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 28, vertical: 13),
//                           decoration: BoxDecoration(
//                             gradient: !isUploadingAll
//                                 ? const LinearGradient(
//                                     colors: [
//                                       Color(0xFFFFC107),
//                                       Color(0xFFFF8C00),
//                                     ],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   )
//                                 : null,
//                             color: isUploadingAll
//                                 ? const Color(0xFF151D2E)
//                                 : null,
//                             borderRadius:
//                                 BorderRadius.circular(12),
//                             boxShadow: !isUploadingAll
//                                 ? [
//                                     BoxShadow(
//                                       color: const Color(
//                                               0xFFFFC107)
//                                           .withOpacity(0.3),
//                                       blurRadius: 16,
//                                     ),
//                                   ]
//                                 : null,
//                           ),
//                           child: isUploadingAll
//                               ? const SizedBox(
//                                   width: 18,
//                                   height: 18,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: Color(0xFFFFC107),
//                                   ),
//                                 )
//                               : const Text(
//                                   'Upload All',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w700,
//                                     color: Color(0xFF0A0E1A),
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 25),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
