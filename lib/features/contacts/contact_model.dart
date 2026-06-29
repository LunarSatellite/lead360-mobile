import '../../core/network/json.dart';

class Contact {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? jobTitle;
  final DateTime? createdAt;

  const Contact({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.jobTitle,
    this.createdAt,
  });

  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
        id: str(j, 'id') ?? '',
        fullName: str(j, 'fullName') ?? 'Contact',
        email: str(j, 'email'),
        phone: str(j, 'phone'),
        jobTitle: str(j, 'jobTitle'),
        createdAt: dateOrNull(j, 'createdAt'),
      );
}
