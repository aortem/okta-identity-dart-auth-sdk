import 'package:flutter/material.dart';
import 'package:okta_identity_dart_auth_sdk/okta_identity_dart_auth_sdk.dart';

class OktaMetadataScreen extends StatefulWidget {
  const OktaMetadataScreen({super.key});

  @override
  State<OktaMetadataScreen> createState() => _OktaMetadataScreenState();
}

class _OktaMetadataScreenState extends State<OktaMetadataScreen> {
  final _oktaDomain = 'dev-07140130.okta.com'; // <-- Update to your domain
  Map<String, dynamic>? _metadata;
  String? _error;
  bool _isLoading = false;

  Future<void> _fetchMetadata() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _metadata = null;
    });

    try {
      final oktaMetadata = AortemOktaMetadata(oktaDomain: _oktaDomain);
      final data = await oktaMetadata.getMetadata();

      setState(() {
        _metadata = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMetadata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔍 Okta Metadata Viewer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _fetchMetadata,
              icon: const Icon(Icons.refresh),
              label: const Text('Fetch Metadata'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(
                '❌ Error: $_error',
                style: const TextStyle(color: Colors.red),
              )
            else if (_metadata != null)
              Expanded(
                child: ListView(
                  children: _metadata!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(child: Text('${entry.value}')),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              const Text('Press "Fetch Metadata" to load data.'),
          ],
        ),
      ),
    );
  }
}
