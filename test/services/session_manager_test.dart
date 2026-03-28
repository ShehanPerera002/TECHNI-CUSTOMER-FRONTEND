import 'package:flutter_test/flutter_test.dart';
import 'package:technni_customer/core/session_manager.dart';

void main() {
  group('SessionManager Tests', () {
    setUp(() {
      // Clear session before each test
      SessionManager.clear();
    });

    test('SessionManager should initialize with null customerDocId', () {
      expect(SessionManager.customerDocId, isNull);
    });

    test('SessionManager should set customerDocId', () {
      SessionManager.setCustomerDocId('cust_001');
      expect(SessionManager.customerDocId, equals('cust_001'));
    });

    test('SessionManager should allow updating customerDocId', () {
      SessionManager.setCustomerDocId('cust_001');
      expect(SessionManager.customerDocId, equals('cust_001'));

      SessionManager.setCustomerDocId('cust_002');
      expect(SessionManager.customerDocId, equals('cust_002'));
    });

    test('SessionManager should clear customerDocId', () {
      SessionManager.setCustomerDocId('cust_001');
      expect(SessionManager.customerDocId, equals('cust_001'));

      SessionManager.clear();
      expect(SessionManager.customerDocId, isNull);
    });

    test('SessionManager should handle different customer IDs', () {
      const customerIds = [
        'cust_001',
        'user_abc',
        'c_12345',
        'customer_name_email',
      ];

      for (var customerId in customerIds) {
        SessionManager.clear();
        SessionManager.setCustomerDocId(customerId);
        expect(SessionManager.customerDocId, equals(customerId));
      }
    });

    test('SessionManager should maintain state after multiple operations', () {
      SessionManager.setCustomerDocId('cust_001');
      for (int i = 0; i < 5; i++) {
        expect(SessionManager.customerDocId, equals('cust_001'));
      }
    });

    test('SessionManager.clear should reset state', () {
      SessionManager.setCustomerDocId('cust_001');
      SessionManager.setCustomerDocId('cust_002');
      SessionManager.setCustomerDocId('cust_003');

      SessionManager.clear();
      expect(SessionManager.customerDocId, isNull);
    });

    test('SessionManager should be a singleton', () {
      SessionManager.setCustomerDocId('cust_001');
      final id1 = SessionManager.customerDocId;

      final id2 = SessionManager.customerDocId;

      expect(id1, equals(id2));
      expect(id1, equals('cust_001'));
    });

    test('SessionManager should handle empty string ID', () {
      SessionManager.setCustomerDocId('');
      expect(SessionManager.customerDocId, equals(''));
    });

    test('SessionManager clear should be idempotent', () {
      SessionManager.setCustomerDocId('cust_001');
      SessionManager.clear();
      expect(SessionManager.customerDocId, isNull);

      SessionManager.clear();
      expect(SessionManager.customerDocId, isNull);
    });

    test('SessionManager should work with complex ID formats', () {
      const complexIds = [
        'firebase_uid_with_uuid_1234-5678',
        'email@domain.com',
        'user:123:456:789',
      ];

      for (var id in complexIds) {
        SessionManager.clear();
        SessionManager.setCustomerDocId(id);
        expect(SessionManager.customerDocId, equals(id));
      }
    });
  });
}
