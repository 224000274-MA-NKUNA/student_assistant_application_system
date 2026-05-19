// lib/views/student/application_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_app/models/application_models.dart';
import 'package:student_assistant_app/viewmodel/application_viewmodel.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  late ApplicationModel _application;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  void _loadApplication() {
    final appVM = context.read<ApplicationViewModel>();
    _application = appVM.applications.firstWhere((a) => a.id == widget.applicationId);
    setState(() => _isLoading = false);
  }

  Color _getStatusColor() {
    switch (_application.status) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return  Scaffold(
        appBar: AppBar(title: Text('Application Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _application.status.toUpperCase(),
                  style: TextStyle(color: _getStatusColor(), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildInfoCard('Student Information', [
              _buildInfoRow('Student Number', _application.studentNumber),
              _buildInfoRow('Full Name', _application.fullName),
              _buildInfoRow('Email', _application.email),
              _buildInfoRow('Year of Study', _application.yearOfStudy.toString()),
            ]),
            const SizedBox(height: 16),
            
            _buildInfoCard('First Module', [
              _buildInfoRow('Level', _application.firstModuleLevel),
              _buildInfoRow('Module', _application.firstModuleName),
              _buildInfoRow('Reason', _application.firstModuleReason),
            ]),
            
            if (_application.hasSecondModule) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Second Module', [
                _buildInfoRow('Level', _application.secondModuleLevel ?? ''),
                _buildInfoRow('Module', _application.secondModuleName ?? ''),
                _buildInfoRow('Reason', _application.secondModuleReason ?? ''),
              ]),
            ],
            
            const SizedBox(height: 16),
            _buildInfoCard('Documents', [
              _buildInfoRow('CV', _application.cvUrl ?? 'Not uploaded'),
              _buildInfoRow('Academic Record', _application.academicRecordUrl ?? 'Not uploaded'),
            ]),
            
            if (_application.rejectionReason != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Rejection Reason', [
                Text(_application.rejectionReason!),
              ]),
            ],
            
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}