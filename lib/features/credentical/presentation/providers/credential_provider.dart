import 'package:flutter/material.dart';
import '../../data/models/credential.dart';
import '../../../dids/data/model/did.dart';
import '../../../../core/storage/storage_service.dart';

class CredentialProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  List<Credential> _credentials = [];
  List<DID> _dids = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  CredentialType? _filterType;

  List<Credential> get credentials => _getFilteredCredentials();
  List<DID> get dids => _dids;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  CredentialType? get filterType => _filterType;

  CredentialProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadCredentials(),
      loadDids(),
    ]);
    _addSampleData();
  }

  // Credentials Management
  Future<void> loadCredentials() async {
    _setLoading(true);
    try {
      _credentials = await _storageService.getCredentials();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load credentials: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> addCredential(Credential credential) async {
    try {
      await _storageService.addCredential(credential);
      _credentials.add(credential);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add credential: ${e.toString()}');
    }
  }

  Future<void> deleteCredential(String credentialId) async {
    try {
      await _storageService.deleteCredential(credentialId);
      _credentials.removeWhere((c) => c.id == credentialId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete credential: ${e.toString()}');
    }
  }

  // DIDs Management
  Future<void> loadDids() async {
    try {
      _dids = await _storageService.getDids();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load DIDs: ${e.toString()}');
    }
  }

  Future<void> addDid(DID did) async {
    try {
      await _storageService.addDid(did);
      _dids.add(did);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add DID: ${e.toString()}');
    }
  }

  Future<void> deleteDid(String didId) async {
    try {
      await _storageService.deleteDid(didId);
      _dids.removeWhere((d) => d.id == didId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete DID: ${e.toString()}');
    }
  }

  // Search and Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(CredentialType? type) {
    _filterType = type;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = null;
    notifyListeners();
  }

  List<Credential> _getFilteredCredentials() {
    var filtered = _credentials;

    // Apply type filter
    if (_filterType != null) {
      filtered = filtered.where((c) => c.type == _filterType).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((c) =>
        c.title.toLowerCase().contains(query) ||
        c.issuer.toLowerCase().contains(query) ||
        c.description.toLowerCase().contains(query)
      ).toList();
    }

    // Sort by issue date (newest first)
    filtered.sort((a, b) => b.issuedDate.compareTo(a.issuedDate));

    return filtered;
  }

  // Utility methods
  int get verifiedCredentialsCount => 
      _credentials.where((c) => c.isVerified).length;

  int get expiredCredentialsCount => 
      _credentials.where((c) => c.isExpired).length;

  List<Credential> getCredentialsByType(CredentialType type) =>
      _credentials.where((c) => c.type == type).toList();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Add sample data for demo
  void _addSampleData() async {
    if (_credentials.isEmpty) {
      final sampleCredentials = [
        Credential(
          id: '1',
          title: 'Senior Software Developer',
          issuer: 'Naturellica',
          issuerLogo: '⚡',
          isVerified: true,
          issuedDate: DateTime(2023, 5, 2),
          description: 'Employment verification for Senior Software Developer position',
          type: CredentialType.employment,
          data: {'position': 'Senior Software Developer', 'department': 'Engineering'},
        ),
        Credential(
          id: '2',
          title: 'Driver\'s License Bureau',
          issuer: 'Driver\'s License Bureau',
          issuerLogo: '🔄',
          isVerified: true,
          issuedDate: DateTime(2024, 4, 28),
          expiryDate: DateTime(2028, 4, 28),
          description: 'Valid driver\'s license for motor vehicles',
          type: CredentialType.license,
          data: {'license_number': 'DL123456789', 'class': 'C'},
        ),
        Credential(
          id: '3',
          title: 'ID Card',
          issuer: 'Government ID Authority',
          issuerLogo: '🆔',
          isVerified: true,
          issuedDate: DateTime(2023, 1, 15),
          expiryDate: DateTime(2033, 1, 15),
          description: 'Government issued identification card',
          type: CredentialType.identity,
          data: {'id_number': 'ID987654321', 'country': 'USA'},
        ),
      ];

      for (final credential in sampleCredentials) {
        await _storageService.addCredential(credential);
      }
      _credentials = sampleCredentials;
      notifyListeners();
    }
  }
} 