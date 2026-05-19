/* 
Student Numbers: 223046876, 223000460, 223050336, 223040081, 224000274, 224027806
Student Names: Lehlogonolo Moshoeu, Asanda Sithole, Sandile Pheko, Mvelo Masinga, Mponisi Nkuna, Cedric Motone
Questions: StudentValidators class provides static methods for validating student application inputs
*/ 

class StudentValidators {
  // Module level validation
  static String? validateModuleLevel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select module level';
    }
    return null;
  }

  // Module name validation
  static String? validateModuleName(String? value, String moduleNumber) {
    if (value == null || value.isEmpty) {
      return 'Please select $moduleNumber module';
    }
    return null;
  }

  // Module reason validation (minimum 20 characters)
  static String? validateModuleReason(String? value, String moduleName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please explain why you want to assist with $moduleName';
    }
    if (value.trim().length < 20) {
      return 'Please provide at least 20 characters';
    }
    return null;
  }

  // Check if modules are different
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

  // Eligibility confirmation
  static String? validateEligibilityConfirmation(bool? isConfirmed) {
    if (isConfirmed != true) {
      return 'You must confirm eligibility requirements';
    }
    return null;
  }

  // File upload validation
  static String? validateFileUpload(String? fileName, String fileType) {
    if (fileName == null || fileName.isEmpty) {
      return 'Please upload your $fileType';
    }
    return null;
  }
}