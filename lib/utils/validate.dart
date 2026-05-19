// GROUP MEMBERS: [Add your names and student numbers here]

class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateModuleLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select module level';
    }
    return null;
  }

  static String? validateModuleName(String? value, String moduleNumber) {
    if (value == null || value.isEmpty) {
      return 'Please select $moduleNumber module';
    }
    return null;
  }

  static String? validateModuleReason(String? value, String moduleName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please explain why you want to assist with $moduleName';
    }
    if (value.trim().length < 20) {
      return 'Please provide at least 20 characters';
    }
    return null;
  }

  static String? validateModulesAreDifferent(
    String firstModule,
    String? secondModule,
    bool hasSecondModule,
  ) {
    if (hasSecondModule && secondModule != null) {
      if (firstModule == secondModule) {
        return 'Second module must be different from first module';
      }
    }
    return null;
  }

  static String? validateFileUpload(String? fileName, String fileType) {
    if (fileName == null || fileName.isEmpty) {
      return 'Please upload your $fileType';
    }
    return null;
  }

  static String? validateCheckbox(bool? value) {
    if (value != true) {
      return 'You must confirm eligibility';
    }
    return null;
  }
}