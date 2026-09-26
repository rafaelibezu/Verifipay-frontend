class ReceiverDeviceLocalState {
  final int id;
  final String name;
  final int branchId;
  final String branchName;
  final bool active;

  const ReceiverDeviceLocalState({
    required this.id,
    required this.name,
    required this.branchId,
    required this.branchName,
    required this.active,
  });

  Map<String, String> toStorage() {
    return {
      'id': id.toString(),
      'name': name,
      'branchId': branchId.toString(),
      'branchName': branchName,
      'active': active.toString(),
    };
  }

  factory ReceiverDeviceLocalState.fromStorage(Map<String, String> values) {
    return ReceiverDeviceLocalState(
      id: int.parse(values['id']!),
      name: values['name']!,
      branchId: int.parse(values['branchId']!),
      branchName: values['branchName']!,
      active: values['active'] == 'true',
    );
  }

  ReceiverDeviceLocalState copyWith({bool? active}) {
    return ReceiverDeviceLocalState(
      id: id,
      name: name,
      branchId: branchId,
      branchName: branchName,
      active: active ?? this.active,
    );
  }
}
