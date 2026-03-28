import 'package:flutter/material.dart';

/// Fake Authentication Service to mimic network requests and server responses
/// without needing an actual backend or `mockito`.
class FakeAuthService {
  Future<bool> loginAgent(String agentId, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Simulate server error
    if (agentId == 'SERVER_ERROR') {
      throw Exception('Internal Server Error');
    }
    
    // Simulate network failure
    if (agentId == 'NETWORK_ERROR') {
      throw Exception('Network timeout');
    }

    // Success case
    if (agentId == 'AG12345' && password == 'ValidPass123!') {
      return true;
    }
    
    // Failure case (incorrect credentials)
    return false;
  }
}

/// A simplified placeholder for the Agent Dashboard to verify navigation works.
class MockAgentDashboard extends StatelessWidget {
  const MockAgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agent Dashboard')),
      body: const Center(child: Text('Welcome, Agent!')),
    );
  }
}
