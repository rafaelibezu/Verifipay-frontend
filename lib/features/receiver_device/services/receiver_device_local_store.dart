import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/receiver_device.dart';
import '../models/receiver_device_local_state.dart';

class ReceiverDeviceLocalStore {
  ReceiverDeviceLocalStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _idKey = 'receiver_device_id';
  static const _nameKey = 'receiver_device_name';
  static const _branchIdKey = 'receiver_device_branch_id';
  static const _branchNameKey = 'receiver_device_branch_name';
  static const _activeKey = 'receiver_device_active';

  final FlutterSecureStorage _storage;

  Future<ReceiverDeviceLocalState?> read() async {
    final values = <String, String>{};

    for (final entry in {
      'id': _idKey,
      'name': _nameKey,
      'branchId': _branchIdKey,
      'branchName': _branchNameKey,
      'active': _activeKey,
    }.entries) {
      final value = await _storage.read(key: entry.value);
      if (value == null || value.isEmpty) return null;
      values[entry.key] = value;
    }

    try {
      return ReceiverDeviceLocalState.fromStorage(values);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCreated(ReceiverDevice device) async {
    await save(
      ReceiverDeviceLocalState(
        id: device.id,
        name: device.name,
        branchId: device.branchId,
        branchName: device.branchName,
        active: true,
      ),
    );
  }

  Future<void> save(ReceiverDeviceLocalState state) async {
    final values = state.toStorage();
    await Future.wait([
      _storage.write(key: _idKey, value: values['id']),
      _storage.write(key: _nameKey, value: values['name']),
      _storage.write(key: _branchIdKey, value: values['branchId']),
      _storage.write(key: _branchNameKey, value: values['branchName']),
      _storage.write(key: _activeKey, value: values['active']),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _idKey),
      _storage.delete(key: _nameKey),
      _storage.delete(key: _branchIdKey),
      _storage.delete(key: _branchNameKey),
      _storage.delete(key: _activeKey),
    ]);
  }
}
