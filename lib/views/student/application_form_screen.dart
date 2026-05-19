// lib/views/student/application_form_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:student_assistant_app/models/application_models.dart';
import 'package:student_assistant_app/utils/student_validators.dart';
import 'package:student_assistant_app/services/storage_service.dart';
import 'package:student_assistant_app/viewmodel/auth_viewmodel.dart';
import 'package:student_assistant_app/viewmodel/application_viewmodel.dart';

class ApplicationFormScreen extends StatefulWidget {
  final ApplicationModel? application;
  const ApplicationFormScreen({super.key, this.application});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstModuleReasonController = TextEditingController();
  final _secondModuleReasonController = TextEditingController();

  // Student's current academic status
  String? _selectedYearLevel;
  String? _selectedSemester;
  
  // Subjects to assist with
  String? _selectedFirstSubject;
  String? _selectedSecondSubject;
  bool _hasSecondSubject = false;
  bool _eligibilityConfirmed = false;

  // Document URLs after upload
  String _cvUrl = '';
  String _academicRecordUrl = '';
  String _matricCertificateUrl = '';
  String _idDocumentUrl = '';
  
  bool _isUploading = false;
  bool _isSubmitting = false;

  // Year levels
  final List<String> _yearLevels = ['First Year', 'Second Year', 'Third Year'];
  
  // Semesters
  final List<String> _semesters = ['Semester 1', 'Semester 2'];
  
  // Complete subjects database with year, semester, and order
  final Map<String, Map<String, List<Map<String, dynamic>>>> _allSubjects = {
    'First Year': {
      'Semester 1': [
        {'name': 'SOFTWARE DEVELOPMENT I', 'code': 'SOD115C', 'credits': 15.00},
        {'name': 'INFORMATION TECHNOLOGY MATHEMATICS I', 'code': 'ITM115C', 'credits': 15.00},
        {'name': 'INFORMATION TECHNOLOGY ESSENTIALS I', 'code': 'ITE115C', 'credits': 15.00},
        {'name': 'PROBLEM SOLVING AND ALGORITHMS', 'code': 'PSA115C', 'credits': 15.00},
        {'name': 'ACADEMIC LITERACY AND COMMUNICATION STUDIES', 'code': 'LCS5011', 'credits': 6.00},
      ],
      'Semester 2': [
        {'name': 'SOFTWARE DEVELOPMENT I', 'code': 'SOD125C', 'credits': 15.00},
        {'name': 'INFORMATION TECHNOLOGY ESSENTIALS I', 'code': 'ITE125C', 'credits': 15.00},
        {'name': 'INFORMATION TECHNOLOGY MATHEMATICS I', 'code': 'ITM125C', 'credits': 15.00},
        {'name': 'ACADEMIC LITERACY AND COMMUNICATION STUDIES', 'code': 'LCS5012', 'credits': 6.00},
        {'name': 'INTERNET PROGRAMMING I', 'code': 'INP125C', 'credits': 15.00},
      ],
    },
    'Second Year': {
      'Semester 1': [
        {'name': 'SOFTWARE DEVELOPMENT II A', 'code': 'SOD216C', 'credits': 15.00},
        {'name': 'DATABASES II', 'code': 'DBS216C', 'credits': 15.00},
        {'name': 'TECHNICAL PROGRAMMING II A', 'code': 'TPG216C', 'credits': 15.00},
        {'name': 'WEB CONTENT MANAGEMENT II', 'code': 'WEB215C', 'credits': 15.00},
        {'name': 'GRAPHIC DESIGN II', 'code': 'GID216C', 'credits': 15.00},
      ],
      'Semester 2': [
        {'name': 'SOFTWARE DEVELOPMENT II B', 'code': 'SOD226C', 'credits': 15.00},
        {'name': 'INTERNET TECHNOLOGIES II', 'code': 'INT226C', 'credits': 15.00},
        {'name': 'GRAPHICAL USER INTERFACE DESIGN II', 'code': 'GUD226C', 'credits': 15.00},
        {'name': 'SOFTWARE ENGINEERING II', 'code': 'SOE226C', 'credits': 15.00},
        {'name': 'TECHNICAL PROGRAMMING II B', 'code': 'TPG226C', 'credits': 15.00},
      ],
    },
    'Third Year': {
      'Semester 1': [
        {'name': 'SOFTWARE DEVELOPMENT III', 'code': 'SOD316C', 'credits': 15.00},
        {'name': 'COMMUNICATION NETWORKS II', 'code': 'CMN316C', 'credits': 15.00},
        {'name': 'INFORMATION TECHNOLOGY AND SOCIETY I', 'code': 'ITS316C', 'credits': 15.00},
        {'name': 'SOFTWARE ENGINEERING III', 'code': 'SOE316C', 'credits': 15.00},
        {'name': 'TECHNICAL PROGRAMMING III', 'code': 'TPG316C', 'credits': 15.00},
      ],
      'Semester 2': [
        {'name': 'ADVANCED DATABASES III', 'code': 'ADB326C', 'credits': 15.00},
        {'name': 'MOBILE APPLICATION DEVELOPMENT III', 'code': 'MAD326C', 'credits': 15.00},
        {'name': 'CLOUD COMPUTING III', 'code': 'CLC326C', 'credits': 15.00},
        {'name': 'INFORMATION TECHNOLOGY MANAGEMENT III', 'code': 'ITM326C', 'credits': 15.00},
        {'name': 'RESEARCH METHODOLOGY III', 'code': 'REM326C', 'credits': 15.00},
      ],
    },
  };

  // Get all completed modules from previous semesters in reverse order (newest first)
  List<Map<String, dynamic>> get _completedModules {
    if (_selectedYearLevel == null || _selectedSemester == null) {
      return [];
    }
    
    final List<Map<String, dynamic>> completedModules = [];
    
    final currentYearIndex = _yearLevels.indexOf(_selectedYearLevel!);
    final currentSemesterIndex = _semesters.indexOf(_selectedSemester!);
    
    for (int yearIndex = 0; yearIndex <= currentYearIndex; yearIndex++) {
      final year = _yearLevels[yearIndex];
      
      int maxSemesterIndex;
      if (yearIndex == currentYearIndex) {
        maxSemesterIndex = currentSemesterIndex - 1;
      } else {
        maxSemesterIndex = _semesters.length - 1;
      }
      
      for (int semIndex = 0; semIndex <= maxSemesterIndex; semIndex++) {
        final semester = _semesters[semIndex];
        final modules = _allSubjects[year]?[semester] ?? [];
        completedModules.addAll(modules);
      }
    }
    
    return completedModules.reversed.toList();
  }

  // Get last 5 completed modules
  List<Map<String, dynamic>> get _last5CompletedModules {
    return _completedModules.take(5).toList();
  }
     List<String> get _availableSubjects {
  return _last5CompletedModules.map((module) => module['name'] as String).toList();
}
 
  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.application != null) {
      final app = widget.application!;
      _selectedYearLevel = app.yearLevel;
      _selectedSemester = app.semester;
      _selectedFirstSubject = app.firstModuleName;
      _firstModuleReasonController.text = app.firstModuleReason;
      _hasSecondSubject = app.hasSecondModule;
      _selectedSecondSubject = app.secondModuleName;
      if (app.secondModuleReason != null) {
        _secondModuleReasonController.text = app.secondModuleReason!;
      }
      _eligibilityConfirmed = app.eligibilityConfirmed;
      _cvUrl = app.cvUrl ?? '';
      _academicRecordUrl = app.academicRecordUrl ?? '';
      _matricCertificateUrl = app.matricCertificateUrl ?? '';
      _idDocumentUrl = app.idDocumentUrl ?? '';
    }
  }

  @override
  void dispose() {
    _firstModuleReasonController.dispose();
    _secondModuleReasonController.dispose();
    super.dispose();
  }

  Future<void> _uploadFile(String documentType, Function(String) onUrlSaved) async {
    try {
      setState(() => _isUploading = true);
      
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        dialogTitle: 'Select $documentType',
      );
      
      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final authVM = context.read<AuthViewModel>();
        final storageService = StorageService();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading... Please wait'), backgroundColor: Colors.orange),
        );
        
        String? fileUrl;
        final userId = authVM.currentUserId;
        
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login again'), backgroundColor: Colors.red),
          );
          return;
        }
        
        if (kIsWeb) {
          final bytes = pickedFile.bytes;
          if (bytes != null) {
            fileUrl = await storageService.uploadDocumentBytes(
              userId,
              documentType.toLowerCase().replaceAll(' ', '_'),
              bytes,
              pickedFile.name,
            );
          }
        } else {
          if (pickedFile.path != null) {
            final xFile = XFile(pickedFile.path!);
            fileUrl = await storageService.uploadDocument(
              userId,
              documentType.toLowerCase().replaceAll(' ', '_'),
              xFile,
            );
          }
        }
        
        if (fileUrl != null) {
          onUrlSaved(fileUrl);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$documentType uploaded successfully!'), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload $documentType'), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected'), backgroundColor: Colors.grey),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _submitForm() async {
    // Step 1: Form validation
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix errors above'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Step 2: Check required documents
    if (_cvUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your CV'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_academicRecordUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your Academic Record'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Step 3: Validate subjects are different
    if (_hasSecondSubject && _selectedFirstSubject == _selectedSecondSubject) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First and second subjects must be different'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Step 4: Get ViewModels
    final authVM = context.read<AuthViewModel>();
    final appVM = context.read<ApplicationViewModel>();
    
    final userId = authVM.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Step 5: Check for existing pending application
    if (appVM.hasPendingApplication && widget.application == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already have a pending application'), backgroundColor: Colors.red),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    // Step 6: Create application object
    final application = ApplicationModel(
      id: widget.application?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      studentNumber: authVM.currentStudentNumber.isNotEmpty 
          ? authVM.currentStudentNumber 
          : 'STU${DateTime.now().millisecondsSinceEpoch}',
      fullName: authVM.currentStudentName.isNotEmpty 
          ? authVM.currentStudentName 
          : 'Student',
      email: authVM.currentUserEmail ?? '',
      yearOfStudy: authVM.currentYearOfStudy,
      yearLevel: _selectedYearLevel,
      semester: _selectedSemester,
      firstModuleLevel: _selectedYearLevel ?? '',
      firstModuleName: _selectedFirstSubject ?? '',
      firstModuleReason: _firstModuleReasonController.text,
      hasSecondModule: _hasSecondSubject,
      secondModuleLevel: _hasSecondSubject ? _selectedYearLevel : null,
      secondModuleName: _hasSecondSubject ? _selectedSecondSubject : null,
      secondModuleReason: _hasSecondSubject ? _secondModuleReasonController.text : null,
      cvUrl: _cvUrl,
      academicRecordUrl: _academicRecordUrl,
      matricCertificateUrl: _matricCertificateUrl,
      idDocumentUrl: _idDocumentUrl,
      eligibilityConfirmed: _eligibilityConfirmed,
      status: 'pending',
      rejectionReason: null,
      createdAt: widget.application?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Step 7: Submit or update
    bool success;
    if (widget.application != null) {
      success = await appVM.updateApplication(application);
    } else {
      success = await appVM.submitApplication(application);
    }
    
    setState(() => _isSubmitting = false);
    
    // Step 8: Handle result
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.application != null ? 'Application updated!' : 'Application submitted!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appVM.errorMessage ?? 'Submission failed'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.application != null ? 'Edit Application' : 'Student Assistant Application'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =============================================
                  // STUDENT INFORMATION CARD
                  // =============================================
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Student Information', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Name: ${authVM.currentStudentName}'),
                          Text('Student Number: ${authVM.currentStudentNumber}'),
                          Text('Current Year: ${authVM.currentYearOfStudy}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // =============================================
                  // CURRENT ACADEMIC STATUS SECTION
                  // =============================================
                  _buildSectionHeader('Your Current Academic Status', required: true),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Select your current year and semester. You can only assist with subjects you have already completed.',
                            style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Year Level Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Your Current Year *',
                      prefixIcon: Icon(Icons.school),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedYearLevel,
                    items: _yearLevels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedYearLevel = v;
                        _selectedSemester = null;
                        _selectedFirstSubject = null;
                        _selectedSecondSubject = null;
                      });
                    },
                    validator: (v) => v == null ? 'Please select your current year' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Semester Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Your Current Semester *',
                      prefixIcon: Icon(Icons.calendar_month),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSemester,
                    items: _semesters.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedSemester = v;
                        _selectedFirstSubject = null;
                        _selectedSecondSubject = null;
                      });
                    },
                    validator: (v) => v == null ? 'Please select your current semester' : null,
                  ),
                  const SizedBox(height: 24),
                  
                  // =============================================
                  // LAST 5 COMPLETED MODULES SECTION
                  // =============================================
                  if (_selectedYearLevel != null && _selectedSemester != null) ...[
                    _buildSectionHeader('Your Recently Completed Modules', required: false),
                    const SizedBox(height: 8),
                    
                    if (_last5CompletedModules.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.warning, color: Colors.red[600], size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'No completed modules yet!\n\n'
                              'You need to complete at least one semester before you can apply to assist.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Completed Modules List
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Your Last ${_last5CompletedModules.length} Completed Module(s)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._last5CompletedModules.asMap().entries.map((entry) {
                              final index = entry.key;
                              final module = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.green[600],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              module['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Code: ${module['code']} | Credits: ${module['credits']}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.check_circle, color: Colors.green[400], size: 18),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Total completed modules count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Completed Modules:',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                            Text(
                              '${_completedModules.length} modules',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  
                  // =============================================
                  // SELECT SUBJECT SECTION
                  // =============================================
                  if (_selectedYearLevel != null && _selectedSemester != null && _availableSubjects.isNotEmpty) ...[
                    _buildSectionHeader('Select Subject to Assist', required: true),
                    const SizedBox(height: 16),
                    
                    // First Subject Dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Choose a subject you want to assist with *',
                        prefixIcon: Icon(Icons.book),
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedFirstSubject,
                      items: _availableSubjects.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _selectedFirstSubject = v),
                      validator: (v) => v == null ? 'Please select a subject' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    // First Subject Reason
                    TextFormField(
                      controller: _firstModuleReasonController,
                      decoration: const InputDecoration(
                        labelText: 'Why do you want to assist with this subject? *',
                        hintText: 'Explain your qualifications, grades achieved, and why you would be a good tutor...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (v) => StudentValidators.validateModuleReason(v, _selectedFirstSubject ?? 'this subject'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  
                  // =============================================
                  // SECOND SUBJECT SECTION (OPTIONAL)
                  // =============================================
                  if (_selectedFirstSubject != null && _availableSubjects.length > 1) ...[
                    _buildSectionHeader('Second Subject (Optional)'),
                    const SizedBox(height: 8),
                    Card(
                      child: SwitchListTile(
                        title: const Text('Apply for a second subject'),
                        subtitle: Text('You can assist with up to 2 subjects (${_availableSubjects.length - 1} other subjects available)'),
                        value: _hasSecondSubject,
                        onChanged: (v) => setState(() => _hasSecondSubject = v),
                        activeColor: Colors.blue,
                      ),
                    ),
                    
                    if (_hasSecondSubject) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Second Subject',
                          prefixIcon: Icon(Icons.book_outlined),
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedSecondSubject,
                        items: _availableSubjects
                            .where((s) => s != _selectedFirstSubject)
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSecondSubject = v),
                        validator: (v) {
                          if (_hasSecondSubject && v == null) {
                            return 'Please select a second subject';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _secondModuleReasonController,
                        decoration: const InputDecoration(
                          labelText: 'Why do you want to assist with this subject?',
                          hintText: 'Explain your motivation for the second subject...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  
                  // =============================================
                  // DOCUMENTS SECTION
                  // =============================================
                  _buildSectionHeader('Supporting Documents', required: true),
                  const SizedBox(height: 8),
                  const Text('Please upload the following documents:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  // CV Upload
                  _buildDocumentUploadCard(
                    title: 'Curriculum Vitae (CV)',
                    subtitle: 'PDF or Word document',
                    fileName: _cvUrl.isEmpty ? '' : 'CV Uploaded',
                    icon: Icons.description,
                    onPressed: () => _uploadFile('CV', (url) => setState(() => _cvUrl = url)),
                    isUploading: _isUploading,
                    isUploaded: _cvUrl.isNotEmpty,
                  ),
                  const SizedBox(height: 12),
                  
                  // Academic Record Upload
                  _buildDocumentUploadCard(
                    title: 'Academic Record',
                    subtitle: 'Official academic transcript',
                    fileName: _academicRecordUrl.isEmpty ? '' : 'Academic Record Uploaded',
                    icon: Icons.receipt,
                    onPressed: () => _uploadFile('Academic Record', (url) => setState(() => _academicRecordUrl = url)),
                    isUploading: _isUploading,
                    isUploaded: _academicRecordUrl.isNotEmpty,
                  ),
                  const SizedBox(height: 12),
                  
                  // Matric Certificate Upload
                  _buildDocumentUploadCard(
                    title: 'Matric Certificate',
                    subtitle: 'Senior certificate or equivalent',
                    fileName: _matricCertificateUrl.isEmpty ? '' : 'Matric Certificate Uploaded',
                    icon: Icons.school,
                    onPressed: () => _uploadFile('Matric Certificate', (url) => setState(() => _matricCertificateUrl = url)),
                    isUploading: _isUploading,
                    isUploaded: _matricCertificateUrl.isNotEmpty,
                  ),
                  const SizedBox(height: 12),
                  
                  // ID Document Upload
                  _buildDocumentUploadCard(
                    title: 'ID Document',
                    subtitle: 'Copy of your ID or passport',
                    fileName: _idDocumentUrl.isEmpty ? '' : 'ID Document Uploaded',
                    icon: Icons.credit_card,
                    onPressed: () => _uploadFile('ID Document', (url) => setState(() => _idDocumentUrl = url)),
                    isUploading: _isUploading,
                    isUploaded: _idDocumentUrl.isNotEmpty,
                  ),
                  const SizedBox(height: 24),
                  
                  // =============================================
                  // ELIGIBILITY SECTION
                  // =============================================
                  _buildSectionHeader('Eligibility Confirmation', required: true),
                  const SizedBox(height: 8),
                  Card(
                    color: _eligibilityConfirmed ? Colors.green[50] : null,
                    child: CheckboxListTile(
                      title: const Text('I confirm that I meet the eligibility requirements'),
                      subtitle: const Text('Good academic standing (minimum 65% average), no disciplinary issues, availability required'),
                      value: _eligibilityConfirmed,
                      onChanged: (v) => setState(() => _eligibilityConfirmed = v ?? false),
                      activeColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // =============================================
                  // SUBMIT BUTTON
                  // =============================================
                  ElevatedButton(
                    onPressed: (_selectedFirstSubject == null || _isSubmitting) ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(widget.application != null ? 'UPDATE APPLICATION' : 'SUBMIT APPLICATION'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isSubmitting || _isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool required = false}) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: Colors.blue),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (required) const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String subtitle,
    required String fileName,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isUploading,
    required bool isUploaded,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                if (isUploaded)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isUploading ? null : onPressed,
              icon: isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_file),
              label: Text(isUploaded ? 'Change File' : 'Upload File'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 45)),
            ),
            if (isUploaded)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'File uploaded successfully',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}