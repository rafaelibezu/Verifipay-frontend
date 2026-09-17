class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final int companyId;
  final int? branchId;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
    this.branchId,
  });

  factory AuthUser.fromJson(
    Map<String, dynamic> json,
  ) {
    return AuthUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      companyId: json['companyId'],
      branchId: json['branchId'],
    );
  }
}