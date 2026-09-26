class ReceiverDeviceCurrent {
  final int id;
  final String name;
  final int branchId;
  final String branchName;
  final DateTime? lastSeenAt;

  const ReceiverDeviceCurrent({
    required this.id,
    required this.name,
    required this.branchId,
    required this.branchName,
    required this.lastSeenAt,
  });

  factory ReceiverDeviceCurrent.fromJson(Map<String, dynamic> json) {
    final lastSeenAt = json['lastSeenAt'];
    return ReceiverDeviceCurrent(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String,
      lastSeenAt: lastSeenAt == null
          ? null
          : DateTime.parse(lastSeenAt as String),
    );
  }
}
