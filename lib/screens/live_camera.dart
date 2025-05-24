import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:smart_home/widgets/icon_with_labels.dart';

class LiveCameraScreen extends StatefulWidget {
  const LiveCameraScreen({super.key});

  @override
  _LiveCameraScreenState createState() => _LiveCameraScreenState();
}

class _LiveCameraScreenState extends State<LiveCameraScreen> {
  static const String BASE_URL = 'http://192.168.18.15:5000'; // Sesuaikan dengan IP komputer Anda

  Uint8List? _imageBytes;
  List<dynamic> _detectionLogs = [];
  bool _isConnected = false;
  bool _cameraAvailable = false;
  bool _isFetchingFrame = false;
  Timer? _frameTimer;
  Timer? _logsTimer;
  String _systemStatus = 'Initializing...';
  int _totalDetections = 0;
  String _connectionMessage = 'Connecting to camera...';
  bool _showDetectionLogs = false;

  @override
  void initState() {
    super.initState();
    _startFetching();
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _logsTimer?.cancel();
    super.dispose();
  }

  void _startFetching() {
    // Wait a bit before starting to allow camera initialization
    Future.delayed(Duration(seconds: 2), () {
      // Check camera status first
      _checkCameraStatus();

      // Fetch frames setiap 100ms (10 FPS) - only after camera is ready
      _frameTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (_cameraAvailable) {
          _fetchCurrentFrame();
        }
      });

      // Fetch logs setiap 2 detik
      _logsTimer = Timer.periodic(Duration(seconds: 2), (timer) {
        _fetchDetectionLogs();
        _fetchSystemStatus();
      });
    });
  }

  Future<void> _checkCameraStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL/camera_status'), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _cameraAvailable = data['camera_available'] ?? false;
            _connectionMessage = _cameraAvailable ? 'Camera ready' : 'Camera not available';
          });
        }
      } else {
        setState(() {
          _cameraAvailable = false;
          _connectionMessage = 'Server not responding';
        });
      }
    } catch (e) {
      setState(() {
        _cameraAvailable = false;
        _connectionMessage = 'Connection failed';
      });
    }
  }

  Future<void> _fetchCurrentFrame() async {
    if (_isFetchingFrame) return;

    _isFetchingFrame = true;
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL/current_frame'), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['image'] != null) {
          setState(() {
            _imageBytes = base64Decode(data['image']);
            _isConnected = true;
          });
        }
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    } finally {
      _isFetchingFrame = false;
    }
  }

  Future<void> _fetchDetectionLogs() async {
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL/detection_logs'), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _detectionLogs = data['logs'] ?? [];
          });
        }
      }
    } catch (e) {
      print('Error fetching logs: $e');
    }
  }

  Future<void> _fetchSystemStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$BASE_URL/status'), headers: {'Content-Type': 'application/json'})
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _systemStatus = data['status'] ?? 'Unknown';
            _totalDetections = data['total_detections'] ?? 0;
            _cameraAvailable = data['camera_available'] ?? false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _systemStatus = 'Error';
      });
    }
  }

  Widget _buildCameraView() {
    return Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _isConnected ? Colors.green : Colors.red.withOpacity(0.5), width: 2),
      ),
      child:
          _imageBytes != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover, gaplessPlayback: true),
              )
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_cameraAvailable ? Icons.videocam : Icons.videocam_off, color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      _connectionMessage,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    if (!_cameraAvailable && _isConnected) ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _checkCameraStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1166AA),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                        child: const Text('Retry', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(
                _isConnected ? Icons.wifi : Icons.wifi_off,
                color: _isConnected ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(_isConnected ? 'Connected' : 'Offline', style: const TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
          Column(
            children: [
              Icon(
                _cameraAvailable ? Icons.camera_alt : Icons.camera_alt_outlined,
                color: _cameraAvailable ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(_cameraAvailable ? 'Active' : 'Standby', style: const TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
          Column(
            children: [
              Icon(Icons.security, color: _totalDetections > 0 ? Colors.red : Colors.green, size: 20),
              const SizedBox(height: 4),
              Text('$_totalDetections Alerts', style: const TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Detections', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => setState(() => _showDetectionLogs = false), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          Expanded(
            child:
                _detectionLogs.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No detections yet', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _detectionLogs.length,
                      itemBuilder: (context, index) {
                        final log = _detectionLogs[index];
                        bool isIntruder = log['type'] == 'intruder';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isIntruder ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isIntruder ? Colors.red : Colors.green, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isIntruder ? Icons.warning : Icons.check_circle,
                                color: isIntruder ? Colors.red : Colors.green,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log['nama'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      log['status'] ?? '',
                                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    Text(log['waktu'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1166AA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1166AA),
        title: const Text('Live Camera'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _totalDetections > 0 ? Icons.notifications_active : Icons.notifications,
              color: _totalDetections > 0 ? Colors.red : Colors.white,
            ),
            onPressed: () => setState(() => _showDetectionLogs = true),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _checkCameraStatus();
              _fetchCurrentFrame();
              _fetchDetectionLogs();
              _fetchSystemStatus();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const IconWithLabels(underIconLabel: 'Siaran Langsung Kamera'),
                const SizedBox(height: 32),
                _buildCameraView(),
                const SizedBox(height: 20),
                _buildStatusIndicator(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ElevatedButton.icon(
                    //   onPressed: () => setState(() => _showDetectionLogs = true),
                    //   icon: const Icon(Icons.list_alt),
                    //   label: const Text('Detections'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.white,
                    //     foregroundColor: const Color(0xFF1166AA),
                    //   ),
                    // ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1166AA),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showDetectionLogs)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showDetectionLogs = false),
                child: Container(
                  color: Colors.black54,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {}, // Prevent closing when tapping on modal
                      child: _buildDetectionModal(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
