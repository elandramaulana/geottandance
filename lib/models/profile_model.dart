// models/profile_model.dart
class ProfileModel {
  final int id;
  final String employeeId;
  final String name;
  final String phone;
  final String? birthDate;
  final String? gender;
  final String? address;
  final String? avatar;
  final String position;
  final String department;
  final String hireDate;
  final String? contractEndDate;
  final String employmentStatus;
  final String companyName;
  final String officeName;
  final String roleName;
  final String approverName;

  ProfileModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.phone,
    this.birthDate,
    this.gender,
    this.address,
    this.avatar,
    required this.position,
    required this.department,
    required this.hireDate,
    this.contractEndDate,
    required this.employmentStatus,
    required this.companyName,
    required this.officeName,
    required this.roleName,
    required this.approverName,
  });

  // Factory constructor untuk membuat instance dari Map
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      birthDate: json['birth_date'],
      gender: json['gender'],
      address: json['address'],
      avatar: json['avatar'],
      position: json['position'] ?? '',
      department: json['department'] ?? '',
      hireDate: json['hire_date'] ?? '',
      contractEndDate: json['contract_end_date'],
      employmentStatus: json['employment_status'] ?? '',
      companyName: json['company_name'] ?? '',
      officeName: json['office_name'] ?? '',
      roleName: json['role_name'] ?? '',
      approverName: json['approver_name'] ?? '',
    );
  }

  // Method untuk convert ke Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'phone': phone,
      'birth_date': birthDate,
      'gender': gender,
      'address': address,
      'avatar': avatar,
      'position': position,
      'department': department,
      'hire_date': hireDate,
      'contract_end_date': contractEndDate,
      'employment_status': employmentStatus,
      'company_name': companyName,
      'office_name': officeName,
      'role_name': roleName,
      'approver_name': approverName,
    };
  }

  // Method untuk membuat copy dengan perubahan
  ProfileModel copyWith({
    int? id,
    String? employeeId,
    String? name,
    String? phone,
    String? birthDate,
    String? gender,
    String? address,
    String? avatar,
    String? position,
    String? department,
    String? hireDate,
    String? contractEndDate,
    String? employmentStatus,
    String? companyName,
    String? officeName,
    String? roleName,
    String? approverName,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      position: position ?? this.position,
      department: department ?? this.department,
      hireDate: hireDate ?? this.hireDate,
      contractEndDate: contractEndDate ?? this.contractEndDate,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      companyName: companyName ?? this.companyName,
      officeName: officeName ?? this.officeName,
      roleName: roleName ?? this.roleName,
      approverName: approverName ?? this.approverName,
    );
  }

  @override
  String toString() {
    return 'ProfileModel{id: $id, employeeId: $employeeId, name: $name, phone: $phone, position: $position, department: $department, roleName: $roleName}';
  }

  // Helper methods untuk memeriksa status
  bool get isPermanentEmployee => employmentStatus.toLowerCase() == 'permanent';
  bool get isContractEmployee => employmentStatus.toLowerCase() == 'contract';
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  bool get hasContractEndDate =>
      contractEndDate != null && contractEndDate!.isNotEmpty;

  // Helper method untuk mendapatkan nama lengkap atau inisial
  String get initials {
    List<String> nameParts = name.split(' ');
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
    }
    return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'
        .toUpperCase();
  }
}
