import 'package:shared_preferences/shared_preferences.dart';

/// Holds the current customer's Firestore document ID in memory.
///
/// This covers the case where a customer logged in via Firestore-based
/// email/password lookup (no Firebase Auth session) and their profile is
/// stored under a document ID that differs from any Firebase Auth UID.
class SessionManager {
  SessionManager._();

  static const String _customerDocIdKey = 'customer_doc_id';

  static String? _customerDocId;
  static SharedPreferences? _prefs;

  /// Initialize persisted session values at app startup.
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _customerDocId = _prefs?.getString(_customerDocIdKey);
  }

  /// The Firestore document ID of the currently logged-in customer.
  /// Falls back to FirebaseAuth UID when not set explicitly.
  static String? get customerDocId => _customerDocId;

  static bool get hasSession =>
      _customerDocId != null && _customerDocId!.trim().isNotEmpty;

  /// Store the customer document ID after a successful login.
  static void setCustomerDocId(String id) {
    _customerDocId = id;
    _prefs?.setString(_customerDocIdKey, id);
  }

  /// Clear session data on logout.
  static void clear() {
    _customerDocId = null;
    _prefs?.remove(_customerDocIdKey);
  }
}
