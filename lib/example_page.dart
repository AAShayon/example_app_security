import 'package:flutter/material.dart';
import 'security/security_config.dart';
import 'security/api_security_manager.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final TextEditingController _searchController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  // Example: How to use the security module independently
  late ApiSecurityManager _securityManager;

  @override
  void initState() {
    super.initState();
    
    // Step 1: Create security configuration
    final config = SecurityConfig(
      baseUrl: 'https://www.refugerestrooms.org',
      endpoints: {
        'restrooms_search': '/api/v1/restrooms/search',
        'restrooms_by_location': '/api/v1/restrooms/by_location',
      },
      enableCertificatePinning: true,
      enableDataEncryption: true,
      enableEndpointObfuscation: true,
    );
    
    // Step 2: Create security manager with configuration
    _securityManager = ApiSecurityManager(config);
    
    // Step 3: Initialize security features
    _securityManager.initialize();
  }

  Future<void> _searchRestrooms() async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Step 4: Make secure request using the security manager
      final response = await _securityManager.makeSecureRequest(
        endpointKey: 'restrooms_search', // Use the key defined in config
        method: 'GET',
        parameters: {
          'query': _searchController.text.trim(),
          'page': 1,
          'per_page': 10,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _result = 'Success! Found ${response.data.length} restrooms';
          _isLoading = false;
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure API Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search for restrooms...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchRestrooms(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchRestrooms,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Search'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _result.isEmpty
                  ? const Center(
                      child: Text('Enter a search term and tap Search'),
                    )
                  : Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(_result),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}