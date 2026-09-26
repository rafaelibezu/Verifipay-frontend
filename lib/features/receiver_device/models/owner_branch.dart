class OwnerBranch {
  final int id;
  final String name;
  final String? address;
  final bool active;

  const OwnerBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.active,
  });

  factory OwnerBranch.fromJson(Map<String, dynamic> json) {
    return OwnerBranch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      active: json['active'] == true,
    );
  }
}
