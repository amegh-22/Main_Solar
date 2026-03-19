import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================
// Traffic Dashboard Widget
// ============================================
// Real-time display of traffic data from all regions
// Shows: vehicle count, congestion level, signal timing, emergency status

class TrafficDashboard extends StatelessWidget {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traffic Control Dashboard'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('traffic_data').snapshots(),
        builder: (context, snapshot) {
          // -------- Loading State --------
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading traffic data...'),
                ],
              ),
            );
          }

          // -------- Error State --------
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          // -------- No Data State --------
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.orange),
                  SizedBox(height: 16),
                  Text('No traffic data available yet'),
                ],
              ),
            );
          }

          // -------- Data Available --------
          final docs = snapshot.data!.docs;

          return ListView(
            padding: EdgeInsets.all(12),
            children: [
              // Region Cards
              ...docs.map((doc) {
                final region = doc.id;
                final data = doc.data() as Map<String, dynamic>;

                return _buildRegionCard(context, region, data);
              }).toList(),

              // Summary Section
              SizedBox(height: 20),
              _buildSummarySection(docs),
            ],
          );
        },
      ),
    );
  }

  // ============================================
  // Region Card Widget
  // ============================================

  Widget _buildRegionCard(
    BuildContext context,
    String region,
    Map<String, dynamic> data,
  ) {
    final vehicleCount = data['vehicleCount'] ?? 0;
    final congestion = data['congestion'] ?? 'UNKNOWN';
    final signalTiming = data['signalTiming'] ?? 0;
    final emergencyDetected = data['emergencyDetected'] ?? false;

    // Determine card color based on congestion
    final cardColor = _getCongestionColor(congestion);
    const borderWidth = 2.0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cardColor, width: borderWidth),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [cardColor.withOpacity(0.1), cardColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Header (Region Name + Emergency Badge) --------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    region.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                  if (emergencyDetected)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '🚨 EMERGENCY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12),

              // -------- Vehicle Count + Status --------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicles',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$vehicleCount',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          congestion,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // -------- Signal Timing (Countdown) --------
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueAccent, width: 1),
                ),
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Signal Timing',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SignalTimerWidget(initialSeconds: signalTiming),
                  ],
                ),
              ),

              SizedBox(height: 8),

              // -------- Metadata --------
              Text(
                'Updated: ${_formatTimestamp(data['processedAt'])}',
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // Summary Section
  // ============================================

  Widget _buildSummarySection(List<QueryDocumentSnapshot> docs) {
    int totalVehicles = 0;
    int highCongestionCount = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalVehicles += data['vehicleCount'] ?? 0;
      if (data['congestion'] == 'HIGH') highCongestionCount++;
    }

    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Total Vehicles', style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Text(
                      '$totalVehicles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('High Congestion', style: TextStyle(fontSize: 12)),
                    SizedBox(height: 4),
                    Text(
                      '$highCongestionCount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // Helper Functions
  // ============================================

  Color _getCongestionColor(String congestion) {
    switch (congestion.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';

    final dateTime = (timestamp as Timestamp).toDate();
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

// ============================================
// Signal Timer Widget
// ============================================
// Animated countdown timer for signal timing

class SignalTimerWidget extends StatefulWidget {
  final int initialSeconds;

  const SignalTimerWidget({Key? key, required this.initialSeconds})
    : super(key: key);

  @override
  _SignalTimerWidgetState createState() => _SignalTimerWidgetState();
}

class _SignalTimerWidgetState extends State<SignalTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;

    _controller = AnimationController(
      duration: Duration(seconds: widget.initialSeconds),
      vsync: this,
    )..forward();

    _controller.addListener(() {
      setState(() {
        _remainingSeconds = (widget.initialSeconds * (1 - _controller.value))
            .toInt();
      });
    });
  }

  @override
  void didUpdateWidget(SignalTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds) {
      _controller.stop();
      _controller.dispose();

      _remainingSeconds = widget.initialSeconds;
      _controller = AnimationController(
        duration: Duration(seconds: widget.initialSeconds),
        vsync: this,
      )..forward();

      _controller.addListener(() {
        setState(() {
          _remainingSeconds = (widget.initialSeconds * (1 - _controller.value))
              .toInt();
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Color changes based on remaining time
    final color = _remainingSeconds > 20
        ? Colors.green
        : _remainingSeconds > 10
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: color, size: 18),
          SizedBox(width: 8),
          Text(
            '${_remainingSeconds.toString().padLeft(2, '0')}s',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
