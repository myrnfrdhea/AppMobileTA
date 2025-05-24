import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_home/widgets/icon_with_labels.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  static const String BASE_URL = 'http://192.168.18.15:5000'; // Use the same base URL as LiveCameraScreen

  List<dynamic> _detectionLogs = [];
  bool _isConnected = false;
  Timer? _logsTimer;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDetectionLogs();
    // Setup periodic refresh every 5 seconds
    _logsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchDetectionLogs();
    });
  }

  @override
  void dispose() {
    _logsTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDetectionLogs() async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL/detection_logs')).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _detectionLogs = data['logs'] ?? [];
            _isLoading = false;
            _isConnected = true;
            _errorMessage = '';
          });
          return;
        }
      }
      setState(() {
        _errorMessage = 'Failed to load logs: Server error';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: ${e.toString()}';
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  Widget _buildLogItem(BuildContext context, int index) {
    final log = _detectionLogs[index];
    bool isIntruder = log['type'] == 'intruder';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIntruder ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isIntruder ? Colors.red : Colors.green, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            isIntruder ? Icons.warning : Icons.check_circle,
            color: isIntruder ? Colors.red : Colors.green,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['nama'] ?? 'Unknown Detection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isIntruder ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  log['status'] ?? 'No status available',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  log['waktu'] ?? 'Unknown time',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Memuat aktivitas...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDetectionLogs,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1166AA)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return _detectionLogs.isEmpty
        ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text('Tidak ada aktivitas terdeteksi', style: TextStyle(color: Colors.white)),
            ],
          ),
        )
        : RefreshIndicator(
          onRefresh: _fetchDetectionLogs,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _detectionLogs.length,
            itemBuilder: _buildLogItem,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1166AA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1166AA),
        title: const Text('Aktivitas'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.white : Colors.amber,
            ),
            onPressed: _fetchDetectionLogs,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            const IconWithLabels(underIconLabel: 'Riwayat Aktivitas'),
            const SizedBox(height: 16),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
