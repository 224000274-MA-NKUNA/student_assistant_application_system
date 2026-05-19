// lib/views/admin/admin_application_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_app/models/application_models.dart';
import 'package:student_assistant_app/viewmodel/application_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminApplicationDetailScreen extends StatefulWidget {
  final String applicationId;
  const AdminApplicationDetailScreen({super.key, required this.applicationId});

  @override
  State<AdminApplicationDetailScreen> createState() => _AdminApplicationDetailScreenState();
}

class _AdminApplicationDetailScreenState extends State<AdminApplicationDetailScreen> {
  late ApplicationModel _application;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  void _loadApplication() {
    final appVM = context.read<ApplicationViewModel>();
    try {
      // Handle both int and string IDs
      final app = appVM.applications.firstWhere((a) => 
        a.id.toString() == widget.applicationId || 
        a.id == widget.applicationId
      );
      _application = app;
    } catch (e) {
      print('Application not found: ${widget.applicationId}');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _openFile(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            // Status Banner
            _buildStatusBanner(),
            const SizedBox(height: 16),
            
            // Student Information
            _buildInfoCard('Student Information', [
              _buildRow('Student Number', _application.studentNumber),
              _buildRow('Full Name', _application.fullName),
              _buildRow('Email', _application.email),
              _buildRow('Year of Study', _application.yearOfStudy.toString()),
            ]),
            const SizedBox(height: 16),
            
            // First Module
            _buildInfoCard('First Module', [
              _buildRow('Level', _application.firstModuleLevel),
              _buildRow('Module', _application.firstModuleName),
              _buildRow('Reason', _application.firstModuleReason),
            ]),
            
            if (_application.hasSecondModule) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Second Module', [
                _buildRow('Level', _application.secondModuleLevel ?? ''),
                _buildRow('Module', _application.secondModuleName ?? ''),
                _buildRow('Reason', _application.secondModuleReason ?? ''),
              ]),
            ],
            
            const SizedBox(height: 16),
            
            // All Documents Section
            _buildInfoCard('Supporting Documents', [
              _buildDocumentRow('CV', _application.cvUrl),
              _buildDocumentRow('Academic Record', _application.academicRecordUrl),
              _buildDocumentRow('Matric Certificate', _application.matricCertificateUrl),
              _buildDocumentRow('ID Document', _application.idDocumentUrl),
            ]),
            
            if (_application.rejectionReason != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard('Rejection Reason', [
                Text(_application.rejectionReason!),
              ]),
            ],
            
            const SizedBox(height: 24),
            
            // Admin Actions (if status is pending)
            if (_application.status == 'pending')
              _buildAdminActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color statusColor;
    IconData statusIcon;
    String statusText = _application.status.toUpperCase();
    
    switch (_application.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Application Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    final appVM = context.read<ApplicationViewModel>();
    
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Admin Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Approve Application'),
                          content: const Text('Are you sure you want to approve this application?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.green),
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true) {
                        await appVM.approveApplication(_application.id.toString());
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Application approved!'), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final reasonController = TextEditingController();
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reject Application'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Please provide a reason for rejection:'),
                              const SizedBox(height: 12),
                              TextField(
                                controller: reasonController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter rejection reason...',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true && reasonController.text.isNotEmpty) {
                        await appVM.rejectApplication(_application.id.toString(), reasonController.text);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Application rejected!'), backgroundColor: Colors.red),
                          );
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, 
            child: Text(
              '$label:', 
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String title, String? url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _openFile(url),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      url != null && url.isNotEmpty 
                          ? 'View Document' 
                          : 'No file uploaded',
                      style: TextStyle(
                        color: url != null && url.isNotEmpty ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                  if (url != null && url.isNotEmpty) 
                    const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}