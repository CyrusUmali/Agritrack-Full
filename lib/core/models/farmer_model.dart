import 'package:equatable/equatable.dart';

class Farmer extends Equatable {
  final int id;
  final String name;
  final String? firstname;
  final String? middlename;
  final String? surname;
  final String? extension;
  final String sector;
  final String? barangay;
  final String? contact;
  final String? farmName;
  final String? sex;
  final double? hectare;
  final String? email;
  final String? phone;
  final String? address;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? house_hold_head;
  final String? civilStatus;
  final String? spouseName;
  final String? religion;
  final int? userId;
  final int? householdNum;
  final int? maleMembersNum;
  final int? femaleMembersNum;
  final String? motherMaidenName;
  final String? personToNotify;
  final String? ptnContact;
  final String? ptnRelationship;

  const Farmer({
    required this.id,
    required this.name,
    this.firstname,
    this.middlename,
    this.surname,
    this.extension,
    this.sex,
    required this.sector,
    this.barangay,
    this.contact,
    this.userId,
    this.farmName,
    this.hectare,
    this.email,
    this.phone,
    this.address,
    this.imageUrl =
        'https://res.cloudinary.com/dk41ykxsq/image/upload/v1745590990/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTAxL3JtNjA5LXNvbGlkaWNvbi13LTAwMi1wLnBuZw-removebg-preview_myrmrf.png',
    this.createdAt,
    this.updatedAt,
    this.house_hold_head,
    this.civilStatus,
    this.spouseName,
    this.religion,
    this.householdNum,
    this.maleMembersNum,
    this.femaleMembersNum,
    this.motherMaidenName,
    this.personToNotify,
    this.ptnContact,
    this.ptnRelationship,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: (json['id'] as int?) ?? 0,
      name: (json['name'] as String?) ?? 'Unknown',
      firstname: (json['firstname'] as String?) ?? '',
      surname: (json['surname'] as String?) ?? '',
      middlename: (json['middlename'] as String?) ?? '',
      extension: (json['extension'] as String?) ?? '',
      sector: (json['sector'] as String?) ?? 'Unknown Sector',
      barangay: (json['barangay'] as String?) ?? 'Unknown Barangay',
      contact: (json['contact'] as String?) ?? '',
      farmName: (json['farmName'] as String?) ?? '',
      sex: (json['sex'] as String?) ?? '',
      hectare: (json['hectare'] as num?)?.toDouble() ?? 0.0,
      email: (json['email'] as String?) ?? '',
      userId: (json['userId'] as int?) ?? 0,
      phone: (json['phone'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      house_hold_head: json['house_hold_head'] as String?,
      civilStatus: json['civil_status'] as String?,
      spouseName: json['spouse_name'] as String?,
      religion: json['religion'] as String?,
      householdNum: json['household_num'] as int?,
      maleMembersNum: json['male_members_num'] as int?,
      femaleMembersNum: json['female_members_num'] as int?,
      motherMaidenName: json['mother_maiden_name'] as String?,
      personToNotify: json['person_to_notify'] as String?,
      ptnContact: json['ptn_contact'] as String?,
      ptnRelationship: json['ptn_relationship'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'firstname': firstname,
      'surname': surname,
      'middlename': middlename,
      'extension': extension,
      'sector': sector,
      'userId': userId,
      'barangay': barangay,
      'contact': contact,
      'farmName': farmName,
      'sex': sex,
      'hectare': hectare,
      'email': email,
      'phone': phone,
      'address': address,
      'imageUrl': imageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'house_hold_head': house_hold_head,
      'civil_status': civilStatus,
      'spouse_name': spouseName,
      'religion': religion,
      'household_num': householdNum,
      'male_members_num': maleMembersNum,
      'female_members_num': femaleMembersNum,
      'mother_maiden_name': motherMaidenName,
      'person_to_notify': personToNotify,
      'ptn_contact': ptnContact,
      'ptn_relationship': ptnRelationship,
    };
  }

  // Sample data for development/demo purposes
  static List<Farmer> get sampleFarmers {
    return [
      Farmer(
        id: 1,
        name: 'Juan Dela Cruz',
        sector: 'Rice',
        barangay: 'San Juan',
        contact: '09123456789',
        farmName: 'Golden Grains Rice Farm',
        hectare: 5.2,
        email: 'juan.delacruz@example.com',
        phone: '09123456789',
        address: '123 Farm Street, San Juan',
        house_hold_head: "true",
        civilStatus: 'Married',
        spouseName: 'Maria Dela Cruz',
        religion: 'Roman Catholic',
        householdNum: 5,
        maleMembersNum: 3,
        femaleMembersNum: 2,
        motherMaidenName: 'Santos',
        personToNotify: 'Pedro Dela Cruz',
        ptnContact: '09123456788',
        ptnRelationship: 'Brother',
      ),
      Farmer(
        id: 2,
        name: 'Ricardo Mendoza',
        sector: 'Rice',
        barangay: 'San Isidro',
        contact: '09234567891',
        farmName: 'Mendoza Rice Fields',
        hectare: 3.8,
        email: 'ricardo.mendoza@example.com',
        phone: '09234567891',
        address: '456 Harvest Road, San Isidro',
        house_hold_head: "true",
        civilStatus: 'Single',
        religion: 'Protestant',
        householdNum: 4,
        maleMembersNum: 2,
        femaleMembersNum: 2,
        motherMaidenName: 'Gonzales',
      ),
    ];
  }

  @override
  List<Object?> get props => [
        id,
        name,
        firstname,
        surname,
        middlename,
        extension,
        sector,
        barangay,
        contact,
        farmName,
        hectare,
        email,
        phone,
        address,
        imageUrl,
        createdAt,
        updatedAt,
        house_hold_head,
        civilStatus,
        spouseName,
        religion,
        householdNum,
        maleMembersNum,
        femaleMembersNum,
        motherMaidenName,
        personToNotify,
        ptnContact,
        ptnRelationship,
        userId
      ];
}
