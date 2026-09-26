class ReceiverDevice {
  final int id;
  final String name;
  final int branchId;
  final String branchName;
  final String deviceToken;

  const ReceiverDevice({
    required this.id,
    required this.name,
    required this.branchId,
    required this.branchName,
    required this.deviceToken,
  });

  factory ReceiverDevice.fromJson(Map<String, dynamic> json) {
    return ReceiverDevice(
      id: json['id'],
      name: json['name'],
      branchId: json['branchId'],
      branchName: json['branchName'],
      deviceToken: json['deviceToken'],
    );
  }
}
