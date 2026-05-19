/* 
Student Numbers: 223046876, 223000460, 223050336, 223040081, 224000274, 224027806
Student Names: Lehlogonolo Moshoeu, Asanda Sithole, Sandile Pheko, Mvelo Masinga, Mponisi Nkuna, Cedric Motone
Questions: AdminDashboardScreen
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_app/models/application_models.dart';
import 'package:student_assistant_app/viewmodel/application_viewmodel.dart';
import 'package:student_assistant_app/viewmodel/auth_viewmodel.dart';
import 'admin_application_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await context.read<ApplicationViewModel>().fetchAllApplications();
    if (mounted) setState(() => _isLoading = false);
  }

  List<ApplicationModel> _getFilteredApplications(ApplicationViewModel appVM) {
    var apps = appVM.applications;
    if (_statusFilter != 'all') {
      apps = apps.where((a) => a.status == _statusFilter).toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      apps = apps
          .where((a) =>
              a.fullName.toLowerCase().contains(query) ||
              a.studentNumber.contains(query))
          .toList();
    }
    return apps;
  }

  void _showRejectDialog(String applicationId, ApplicationViewModel appVM) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration:
                  const InputDecoration(hintText: 'Rejection reason...'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await appVM.rejectApplication(
                  applicationId, reasonController.text);
              _loadData();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              context.read<ApplicationViewModel>().reset();
              await context.read<AuthViewModel>().signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appVM = context.watch<ApplicationViewModel>();
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Drawer Header - NO PROFILE CLICK
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Static admin icon - NOT clickable
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authVM.currentStudentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Administrator',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authVM.currentUserEmail ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Drawer Items - NO PROFILE ITEM
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.people_outline,
                        title: 'All Applications',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _statusFilter = 'all');
                          _loadData();
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.pending_actions,
                        title: 'Pending Applications',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _statusFilter = 'pending');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.check_circle_outline,
                        title: 'Approved Applications',
                        color: Colors.green,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _statusFilter = 'approved');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.cancel_outlined,
                        title: 'Rejected Applications',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _statusFilter = 'rejected');
                        },
                      ),
                      const Divider(height: 32, thickness: 1),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutConfirmation();
                        },
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading || appVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsRow(appVM),
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: _getFilteredApplications(appVM).isEmpty
                      ? const Center(child: Text('No applications found'))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _getFilteredApplications(appVM).length,
                            itemBuilder: (context, index) {
                              final app =
                                  _getFilteredApplications(appVM)[index];
                              return _buildApplicationCard(app, appVM);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      onTap: onTap,
      hoverColor: Colors.blue.withOpacity(0.05),
      splashColor: Colors.blue.withOpacity(0.1),
    );
  }

  Widget _buildStatsRow(ApplicationViewModel appVM) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard('Total', appVM.applications.length, Colors.blue),
          _buildStatCard('Pending', appVM.pendingCount, Colors.orange),
          _buildStatCard('Approved', appVM.approvedCount, Colors.green),
          _buildStatCard('Rejected', appVM.rejectedCount, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              Text(title, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search by name or student number',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _statusFilter == 'all',
            onSelected: (_) => setState(() => _statusFilter = 'all'),
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.blue.withOpacity(0.2),
            checkmarkColor: Colors.blue,
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Pending'),
            selected: _statusFilter == 'pending',
            onSelected: (_) => setState(() => _statusFilter = 'pending'),
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.orange.withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Approved'),
            selected: _statusFilter == 'approved',
            onSelected: (_) => setState(() => _statusFilter = 'approved'),
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.green.withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Rejected'),
            selected: _statusFilter == 'rejected',
            onSelected: (_) => setState(() => _statusFilter = 'rejected'),
            backgroundColor: Colors.grey[200],
            selectedColor: Colors.red.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(
      ApplicationModel app, ApplicationViewModel appVM) {
    Color statusColor = app.status == 'approved'
        ? Colors.green
        : (app.status == 'rejected' ? Colors.red : Colors.orange);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AdminApplicationDetailScreen(
                        applicationId: app.id.toString())))
            .then((_) => _loadData()),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            app.status == 'approved'
                ? Icons.check
                : (app.status == 'rejected' ? Icons.close : Icons.pending),
            color: statusColor,
          ),
        ),
        title: Text(app.fullName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Student: ${app.studentNumber}'),
            Text('Module: ${app.firstModuleName}'),
          ],
        ),
        trailing: app.status == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Approve Application'),
                          content: Text(
                              'Approve ${app.fullName}\'s application for ${app.firstModuleName}?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.green),
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await appVM.approveApplication(app.id.toString());
                        _loadData();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () =>
                        _showRejectDialog(app.id.toString(), appVM),
                  ),
                ],
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  app.status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }
}
