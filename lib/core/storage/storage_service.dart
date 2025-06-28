import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/credentical/data/models/credential.dart';
import '../../features/dids/data/model/did.dart';

class StorageService {
  static const String _pinKey = 'user_pin';
  static const String _credentialsKey = 'user_credentials';
  static const String _didsKey = 'user_dids';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // PIN Management
  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString(_pinKey);
    return savedPin == pin;
  }

  Future<void> deletePin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }

  // Biometric Settings
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  // Credentials Management
  Future<List<Credential>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = prefs.getStringList(_credentialsKey) ?? [];
    
    return credentialsJson
        .map((json) => Credential.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveCredentials(List<Credential> credentials) async {
    final prefs = await SharedPreferences.getInstance();
    final credentialsJson = credentials
        .map((credential) => jsonEncode(credential.toJson()))
        .toList();
    
    await prefs.setStringList(_credentialsKey, credentialsJson);
  }

  Future<void> addCredential(Credential credential) async {
    final credentials = await getCredentials();
    credentials.add(credential);
    await saveCredentials(credentials);
  }

  Future<void> deleteCredential(String credentialId) async {
    final credentials = await getCredentials();
    credentials.removeWhere((c) => c.id == credentialId);
    await saveCredentials(credentials);
  }

  // DIDs Management
  Future<List<DID>> getDids() async {
    final prefs = await SharedPreferences.getInstance();
    final didsJson = prefs.getStringList(_didsKey) ?? [];
    
    return didsJson
        .map((json) => DID.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> saveDids(List<DID> dids) async {
    final prefs = await SharedPreferences.getInstance();
    final didsJson = dids
        .map((did) => jsonEncode(did.toJson()))
        .toList();
    
    await prefs.setStringList(_didsKey, didsJson);
  }

  Future<void> addDid(DID did) async {
    final dids = await getDids();
    dids.add(did);
    await saveDids(dids);
  }

  Future<void> deleteDid(String didId) async {
    final dids = await getDids();
    dids.removeWhere((d) => d.id == didId);
    await saveDids(dids);
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 