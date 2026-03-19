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

class AdminUploadPage extends StatefulWidget {
  const AdminUploadPage({super.key});

  @override
  State<AdminUploadPage> createState() => _AdminUploadPageState();
}

class _AdminUploadPageState extends State<AdminUploadPage> {
  final List<String> junctions = ["Junction 1", "Junction 2"];
  final List<String> roads = ["North", "South", "East", "West"];

  Map<String, File?> mobileFiles = {};
  Map<String, Uint8List?> webFiles = {};
  Map<String, bool> uploadingState = {};

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
      }
    }
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
        "https://api.openweathermap.org/data/2.5/weather?q=Thiruvananthapuram&appid=$weatherApiKey&units=metric");

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
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video, withData: true);

    if (result == null) return;

    final file = result.files.single;

    setState(() {
      if (kIsWeb) {
        webFiles[key] = file.bytes;
        mobileFiles[key] = null;
      } else {
        mobileFiles[key] = File(file.path!);
        webFiles[key] = null;
      }
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Select video for $road")));
      return;
    }

    setState(() => uploadingState[key] = true);

    try {
      String? url = await _uploadToCloudinary(key);

      if (url != null) {
        final weather = await _getWeatherData();
        
        // Ensure the junction id has no spaces as requested i.e., "Junction1"
        String junctionId = junction.replaceAll(" ", "");

        await FirebaseFirestore.instance
            .collection("traffic_data")
            .doc(junctionId)
            .collection("roads")
            .doc(road)
            .set({
          "videoUrl": url,
          "weather": weather["weather"],
          "sunlight": weather["sunlight"],
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        uploadingState[key] = false;
        mobileFiles[key] = null;
        webFiles[key] = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$road uploaded successfully")));
      }

    } catch (e) {
      setState(() => uploadingState[key] = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Upload failed")));
      }
    }
  }

  // ================= ROAD CARD =================
  Widget _roadCard(String junction, String road) {
    String key = "$junction-$road";
    bool hasFile = mobileFiles[key] != null || webFiles[key] != null;
    bool isUploading = uploadingState[key]!;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                road,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasFile) ...[
                const SizedBox(width: 5),
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
              ]
            ],
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: isUploading ? null : () => _pickVideo(key),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(70, 30),
            ),
            child: const Text("Select", style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: (isUploading || !hasFile) ? null : () => _uploadSingle(junction, road),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(70, 30),
            ),
            child: isUploading
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
    return Expanded(
      child: Container(
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
              children: roads
                  .map((road) => _roadCard(junction, road))
                  .toList(),
            ),
          ],
        ),
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
        title: const Text(
          "SolarStat Admin",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (v) {
              if (v == 1) _logout();
            },
            itemBuilder: (c) => const [
              PopupMenuItem(value: 1, child: Text("Logout"))
            ],
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "ADMIN PAGE",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Upload Traffic Videos",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: junctions
                  .map((junction) => _junctionCard(junction))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
