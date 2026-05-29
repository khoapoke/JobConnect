class Validators {
  const Validators._();

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName không được để trống';
    return null;
  }

  static String? fullName(String? value) {
    final req = required(value, 'Họ tên');
    if (req != null) return req;
    if (value!.trim().length < 2) return 'Họ tên phải có ít nhất 2 ký tự';
    if (value.trim().length > 100) return 'Họ tên không được quá 100 ký tự';
    return null;
  }

  static String? email(String? value) {
    final req = required(value, 'Email');
    if (req != null) return req;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) return 'Email không hợp lệ';
    return null;
  }

  static String? password(String? value) {
    final req = required(value, 'Mật khẩu');
    if (req != null) return req;
    if (value!.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final req = required(value, 'Xác nhận mật khẩu');
    if (req != null) return req;
    if (value != password) return 'Mật khẩu không khớp';
    return null;
  }

  // Profile validators — T-10
  static String? headline(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 120) return 'Tiêu đề không được quá 120 ký tự';
    return null;
  }

  static String? bio(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 500) return 'Giới thiệu không được quá 500 ký tự';
    return null;
  }

  static String? location(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 100) return 'Địa điểm không được quá 100 ký tự';
    return null;
  }

  // T-11 validators
  static String? fromDate(DateTime? value) {
    if (value == null) return 'Vui lòng chọn ngày bắt đầu';
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http')) {
      return 'URL không hợp lệ (cần bắt đầu bằng http/https)';
    }
    return null;
  }

  /// Generic text field: required, min/max length.
  /// Reusable for any named text field.
  static String? text(String? value, String fieldName,
      {int min = 2, int max = 100}) {
    final req = required(value, fieldName);
    if (req != null) return req;
    final trimmed = value!.trim();
    if (trimmed.length < min) {
      return '$fieldName phải có ít nhất $min ký tự';
    }
    if (trimmed.length > max) {
      return '$fieldName không được quá $max ký tự';
    }
    return null;
  }

  /// Optional long text field: validates max length only when provided.
  /// Reusable for descriptions, bios, etc.
  static String? longText(String? value, String fieldName,
      {int max = 1000}) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) {
      return '$fieldName không được quá $max ký tự';
    }
    return null;
  }

  // T-14: Job Post validators
  static String? jobTitle(String? value) {
    return text(value, 'Tên tin tuyển dụng', min: 3, max: 100);
  }

  static String? jobDescription(String? value, {required bool forPublish}) {
    if (value == null || value.trim().isEmpty) {
      return forPublish ? 'Mô tả công việc không được để trống' : null;
    }
    final trimmed = value.trim();
    if (trimmed.length > 5000) {
      return 'Mô tả công việc không được quá 5000 ký tự';
    }
    if (forPublish && trimmed.length < 50) {
      return 'Mô tả công việc phải có ít nhất 50 ký tự';
    }
    return null;
  }

  static String? jobRequirements(String? value, {required bool forPublish}) {
    if (value == null || value.trim().isEmpty) {
      return forPublish ? 'Yêu cầu ứng viên không được để trống' : null;
    }
    final trimmed = value.trim();
    if (trimmed.length > 3000) {
      return 'Yêu cầu ứng viên không được quá 3000 ký tự';
    }
    if (forPublish && trimmed.length < 30) {
      return 'Yêu cầu ứng viên phải có ít nhất 30 ký tự';
    }
    return null;
  }

  static String? salaryRange(int? min, int? max) {
    if (min == null || max == null) {
      return 'Vui lòng nhập đầy đủ mức lương';
    }
    if (min < 0 || max < 0) {
      return 'Mức lương không được âm';
    }
    if (min > max) {
      return 'Mức lương tối đa phải lớn hơn hoặc bằng tối thiểu';
    }
    return null;
  }

  static String? province(String? value) {
    return required(value, 'Tỉnh / Thành phố');
  }

  static String? expiresAtForPublish(DateTime? value) {
    if (value == null) {
      return 'Vui lòng chọn hạn nộp hồ sơ';
    }
    final now = DateTime.now();
    final minDate = now.add(const Duration(days: 1));
    final maxDate = now.add(const Duration(days: 90));
    if (value.isBefore(minDate)) {
      return 'Hạn nộp hồ sơ phải ít nhất 1 ngày kể từ hôm nay';
    }
    if (value.isAfter(maxDate)) {
      return 'Hạn nộp hồ sơ không được quá 90 ngày kể từ hôm nay';
    }
    return null;
  }
}
