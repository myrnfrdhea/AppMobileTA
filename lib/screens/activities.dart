import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/widgets/icon_with_labels.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _detectionLogs = [];
  bool _isConnected = false;
  StreamSubscription<QuerySnapshot>? _detectionSubscription;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setupFirestoreListener();
  }

  @override
  void dispose() {
    _detectionSubscription?.cancel();
    super.dispose();
  }

  void _setupFirestoreListener() {
    try {
      _detectionSubscription = _firestore
          .collection('deteksi_intruder')
          .orderBy('timestamp', descending: true)
          // .limit(50) #NYALAIN KALAU MAU DILIMIT
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) {
              setState(() {
                _detectionLogs =
                    snapshot.docs.map((DocumentSnapshot doc) {
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                      if (data['timestamp'] is Timestamp) {
                        DateTime dateTime = (data['timestamp'] as Timestamp).toDate();
                        data['waktu'] = _formatDateTime(dateTime);
                      }
                      return {
                        'id': doc.id,
                        'nama': data['nama'] ?? 'Unknown',
                        'status': data['status'] ?? 'No status',
                        'waktu': data['waktu'] ?? 'Unknown time',
                        'type': data['type'] ?? 'unknown',
                        'confidence': data['confidence'] ?? 0.0,
                        'timestamp': data['timestamp'],
                        'gambar_path': data['gambar_path'],
                      };
                    }).toList();

                _isLoading = false;
                _isConnected = true;
                _errorMessage = '';
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = 'Firebase error: ${error.toString()}';
                _isLoading = false;
                _isConnected = false;
              });
            },
          );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to Firebase: ${e.toString()}';
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _getRelativeTime(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return timestamp.toString();
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return _formatDateTime(dateTime);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildLogItem(BuildContext context, int index) {
    final log = _detectionLogs[index];
    bool isIntruder = log['type'] == 'intruder';
    bool isUnknown = log['nama'] == 'unknown' || log['nama'] == 'Unknown';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isIntruder ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isIntruder ? Colors.red : Colors.green, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isIntruder ? Colors.red : Colors.green).withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIntruder ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIntruder ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: isIntruder ? Colors.red : Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isUnknown ? 'Orang Tidak Dikenal' : log['nama'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isIntruder ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ),
                    if (log['confidence'] != null && log['confidence'] > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${(log['confidence'] as double).toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  log['status'] ?? 'No status available',
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.2),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      _getRelativeTime(log['timestamp']),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _detectionLogs.isEmpty) {
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

    if (_errorMessage.isNotEmpty && _detectionLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(_errorMessage, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _detectionSubscription?.cancel();
                _setupFirestoreListener();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1166AA)),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
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
              SizedBox(height: 8),
              Text('Data akan muncul secara real-time', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        )
        : RefreshIndicator(
          onRefresh: _refreshData,
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
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  _isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  color: _isConnected ? Colors.white : Colors.amber,
                ),
                onPressed: () {
                  _detectionSubscription?.cancel();
                  _setupFirestoreListener();
                },
              ),
              if (_detectionLogs.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_detectionLogs.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            const IconWithLabels(underIconLabel: 'Riwayat Aktivitas'),
            const SizedBox(height: 16),
            if (_isLoading && _detectionLogs.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.white30,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
