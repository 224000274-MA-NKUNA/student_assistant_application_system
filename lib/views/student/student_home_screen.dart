// lib/views/student/student_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant_app/models/application_models.dart';
import 'package:student_assistant_app/viewmodel/application_viewmodel.dart';
import 'package:student_assistant_app/viewmodel/auth_viewmodel.dart';
import 'package:student_assistant_app/views/student/application_form_screen.dart';
import 'package:student_assistant_app/views/student/profile_screen.dart';
import 'package:student_assistant_app/views/student/application_detail_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataOnce();
    });
  }

  Future<void> _loadDataOnce() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    
    final authVM = context.read<AuthViewModel>();
    if (authVM.currentUserId != null) {
      await context.read<ApplicationViewModel>().fetchMyApplications(authVM.currentUserId!);
    }
    
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    
    final authVM = context.read<AuthViewModel>();
    if (authVM.currentUserId != null) {
      await context.read<ApplicationViewModel>().fetchMyApplications(authVM.currentUserId!);
    }
    
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showDeleteConfirmation(ApplicationModel app, ApplicationViewModel appVM) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Application'),
        content: Text('Are you sure you want to delete your application for ${app.firstModuleName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await appVM.deleteApplication(app.id);
              await _refreshData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application deleted'), backgroundColor: Colors.red),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appVM = context.watch<ApplicationViewModel>();
    final authVM = context.watch<AuthViewModel>();

    if (_isLoading || (appVM.isLoading && _isRefreshing)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Assistant Portal'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Drawer Header with Profile Picture
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                        if (result == true) {
                          await _refreshData();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          backgroundImage: authVM.currentStudent?.profilePictureUrl != null &&
                                  authVM.currentStudent!.profilePictureUrl!.isNotEmpty
                              ? NetworkImage(authVM.currentStudent!.profilePictureUrl!)
                              : null,
                          child: authVM.currentStudent?.profilePictureUrl == null ||
                                  authVM.currentStudent!.profilePictureUrl!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.blue,
                                )
                              : null,
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
                      authVM.currentStudentNumber,
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
           
              _buildDrawerItem(
                icon: Icons.add_circle_outline,
                title: 'New Application',
                color: Colors.blue,
                onTap: () async {
                  Navigator.pop(context);
                  if (appVM.canSubmitApplication) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ApplicationFormScreen()),
                    );
                    if (result == true) {
                      await _refreshData();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appVM.hasPendingApplication 
                          ? 'You already have a pending application' 
                          : 'You have already been approved'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.person_outline,
                title: 'My Profile',
                color: Colors.blue,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  if (result == true) {
                    await _refreshData();
                  }
                },
              ),
              _buildDrawerItem(
                icon: Icons.history,
                title: 'My Applications',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  // Scroll to top or show applications
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
              const Spacer(),
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
      body: appVM.applications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appVM.applications.length,
                itemBuilder: (context, index) {
                  final app = appVM.applications[index];
                  return _buildApplicationCard(app, appVM);
                },
              ),
            ),
      floatingActionButton: appVM.canSubmitApplication
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApplicationFormScreen()),
                );
                if (result == true) {
                  await _refreshData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New Application'),
              backgroundColor: Colors.blue,
            )
          : null,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No applications yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to submit your application',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(ApplicationModel app, ApplicationViewModel appVM) {
    Color statusColor;
    IconData statusIcon;
    switch (app.status) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ApplicationDetailScreen(applicationId: app.id.toString()),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.firstModuleName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Submitted: ${app.createdAt.toString().substring(0, 10)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (app.status == 'pending')
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ApplicationFormScreen(application: app)),
                          );
                          await _refreshData();
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(app, appVM);
                        }
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        app.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}