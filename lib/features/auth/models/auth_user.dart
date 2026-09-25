class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? companyId;
  final String? companyName;
  final int? branchId;
  final String? branchName;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
    this.companyName,
    this.branchId,
    this.branchName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      branchId: json['branchId'],
      branchName: json['branchName'],
    );
  }
}
