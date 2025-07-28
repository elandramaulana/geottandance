import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../models/history_model.dart';

class HistoryDetailScreen extends StatelessWidget {
  HistoryDetailScreen({super.key});

  final HistoryModel history = Get.arguments as HistoryModel;

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd MMM yyyy').format(history.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Detail Attendance'),
        backgroundColor: const Color(0xFF2E7D5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabelValueRow(
              label: 'Date',
              value: dateFormatted,
              icon: Icons.calendar_today,
              iconColor: Colors.teal,
            ),
            _buildCategoryBox(history.category),
            _buildLabelValueRow(
              label: 'Check In',
              value: history.checkIn,
              icon: Icons.login,
              iconColor: Colors.green,
            ),
            _buildLabelValueRow(
              label: 'Check Out',
              value: history.checkOut,
              icon: Icons.logout,
              iconColor: Colors.red,
            ),
            const SizedBox(height: 16),
            if (history.latitudeIn != null && history.longitudeIn != null) ...[
              _buildLabelValueRow(
                label: 'Location (Check In)',
                value: history.locationIn,
                icon: Icons.location_on,
                iconColor: Colors.blue,
              ),
              SizedBox(
                height: 250,
                child: _MapWidget(
                  lat: history.latitudeIn!,
                  lng: history.longitudeIn!,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (history.latitudeOut != null &&
                history.longitudeOut != null) ...[
              _buildLabelValueRow(
                label: 'Location (Check Out)',
                value: history.locationOut,
                icon: Icons.location_on_outlined,
                iconColor: Colors.deepOrange,
              ),
              SizedBox(
                height: 250,
                child: _MapWidget(
                  lat: history.latitudeOut!,
                  lng: history.longitudeOut!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLabelValueRow({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildCategoryBox(String category) {
    Color bgColor;
    switch (category) {
      case 'On Time':
        bgColor = Colors.green;
        break;
      case 'Late':
        bgColor = Colors.orange;
        break;
      case 'Absent':
        bgColor = Colors.red;
        break;
      case 'Holiday':
        bgColor = Colors.blueGrey;
        break;
      case 'Sick/Leave':
        bgColor = Colors.purple;
        break;
      default:
        bgColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        border: Border.all(color: bgColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(color: bgColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MapWidget extends StatelessWidget {
  final double lat;
  final double lng;

  const _MapWidget({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        options: MapOptions(center: LatLng(lat, lng), zoom: 16),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.geottandance',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: LatLng(lat, lng),
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 36,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
