/// Holds the current customer's Firestore document ID in memory.
///
/// This covers the case where a customer logged in via Firestore-based
/// email/password lookup (no Firebase Auth session) and their profile is
/// stored under a document ID that differs from any Firebase Auth UID.
class SessionManager {
  SessionManager._();

  static String? _customerDocId;

  /// The Firestore document ID of the currently logged-in customer.
  /// Falls back to FirebaseAuth UID when not set explicitly.
  static String? get customerDocId => _customerDocId;

  /// Store the customer document ID after a successful login.
  static void setCustomerDocId(String id) {
    _customerDocId = id;
  }

  /// Clear session data on logout.
  static void clear() {
    _customerDocId = null;
  }
}
