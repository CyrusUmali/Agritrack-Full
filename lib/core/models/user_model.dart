class UserModel {
  final int id;
  final String email;
  final String name;
  final String? password;
  final String? newPassword;
  final String? photoUrl;
  final String? phone;
  final String role;
  final String? fname;
  final String? lname;
  final String? sector;
  final String? barangay;
  final String? status;
  final String? idToken;
  final int? farmerId;
  final String? authProvider; // 'email' or 'google'
  final bool? hasPassword; // true for email/password users

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.password,
    this.newPassword,
    required this.role,
    this.fname,
    this.phone,
    this.lname,
    this.sector,
    this.barangay,
    this.status,
    this.idToken,
    this.farmerId,
    this.authProvider, // New required field
    this.hasPassword, // New required field
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as int?) ?? 0,
      email: (json['email'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      password: (json['password'] as String?) ?? '',
      newPassword: (json['newPassword'] as String?) ?? '',
      photoUrl: json['photoUrl'] as String?,
      role: (json['role'] as String?) ?? '',
      fname: (json['fname'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      lname: (json['lname'] as String?) ?? '',
      sector: (json['sector'] as String?) ?? '',
      barangay: (json['barangay'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      farmerId: (json['farmerId'] as int?) ?? 0,
      authProvider:
          (json['authProvider'] as String?) ?? 'email', // Default to email
      hasPassword: (json['hasPassword'] as bool?) ?? true, // Default to true
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'fname': fname,
      'lname': lname,
      'password': password,
      'newPassword': newPassword,
      'sector': sector,
      'status': status,
      'idToken': idToken,
      'barangay': barangay,
      'phone': phone,
      'farmerId': farmerId,
      'authProvider': authProvider, // Include new field
      'hasPassword': hasPassword, // Include new field
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        role,
        fname,
        lname,
        sector,
        status,
        password,
        newPassword,
        barangay,
        phone,
        farmerId,
        authProvider, // Include new field
        hasPassword, // Include new field
      ];

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? 0,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      role: map['role'] ?? '',
      fname: map['fname'] ?? '',
      password: map['password'] ?? '',
      newPassword: map['newPassword'] ?? '',
      lname: map['lname'] ?? '',
      sector: map['sector'] ?? '',
      phone: map['phone'] ?? '',
      farmerId: map['farmerId'] ?? 0,
      status: map['status'] ?? '',
      barangay: map['barangay'] ?? '',
      authProvider: map['authProvider'] ?? 'email', // Default to email
      hasPassword: map['hasPassword'] ?? true, // Default to true
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
      'newPassword': newPassword,
      'photoUrl': photoUrl,
      'role': role,
      'fname': fname,
      'lname': lname,
      'sector': sector,
      'status': status,
      'barangay': barangay,
      'phone': phone,
      'farmerId': farmerId,
      'authProvider': authProvider, // Include new field
      'hasPassword': hasPassword, // Include new field
    };
  }
}
