import 'dart:convert';

import 'package:flutter/material.dart';

class CredentialApprovalSheet extends StatefulWidget {
  const CredentialApprovalSheet({
    required this.fqdn,
    required this.login,
    required this.token,
    this.siteName,
    this.issuedAt,
    this.signature,
    super.key,
  });

  final String fqdn;
  final String login;
  final String token;
  final String? siteName;
  final DateTime? issuedAt;
  final String? signature;

  @override
  State<CredentialApprovalSheet> createState() =>
      _CredentialApprovalSheetState();
}

class _CredentialApprovalSheetState extends State<CredentialApprovalSheet> {
  bool _obscureKey = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyDisplay = _obscureKey ? _obscure(widget.token) : widget.token;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review credentials',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Confirm the record matches the QR badge before approving.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _DetailRow(label: 'Server', value: widget.fqdn),
          _DetailRow(label: 'Login', value: widget.login),
          _DetailRow(
            label: 'Site',
            value: (widget.siteName?.isNotEmpty ?? false)
                ? widget.siteName!
                : 'Not provided',
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailRow(
                  label: 'Token',
                  value: keyDisplay,
                  selectable: !_obscureKey,
                ),
              ),
              IconButton(
                tooltip: _obscureKey ? 'Show token' : 'Hide token',
                onPressed: () {
                  setState(() {
                    _obscureKey = !_obscureKey;
                  });
                },
                icon: Icon(_obscureKey ? Icons.visibility : Icons.vpn_key),
              ),
            ],
          ),
          if (widget.issuedAt != null)
            _DetailRow(
              label: 'Issued At',
              value: widget.issuedAt!.toUtc().toIso8601String(),
            ),
          if (widget.signature != null && widget.signature!.isNotEmpty)
            _DetailRow(
              label: 'Signature',
              value: widget.signature!,
              selectable: true,
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _obscure(String value) {
    if (value.length <= 6) {
      return '*' * value.length;
    }
    final start = value.substring(0, 3);
    final end = value.substring(value.length - 3);
    return '$start••••••$end';
  }
}

/// Entry mode for credential input - manual fields or JSON paste
enum CredentialEntryMode { manual, json }

class ManualCredentialEntrySheet extends StatefulWidget {
  const ManualCredentialEntrySheet({
    super.key,
    this.onCredentialsSubmitted,
  });

  /// Optional callback for testing - if provided, called instead of Navigator.pop
  final void Function(Map<String, String>)? onCredentialsSubmitted;

  @override
  State<ManualCredentialEntrySheet> createState() =>
      _ManualCredentialEntrySheetState();
}

class _ManualCredentialEntrySheetState
    extends State<ManualCredentialEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _fqdnController = TextEditingController();
  final _loginController = TextEditingController();
  final _tokenController = TextEditingController();
  final _siteController = TextEditingController();
  final _jsonController = TextEditingController();

  CredentialEntryMode _entryMode = CredentialEntryMode.manual;
  String? _jsonError;

  @override
  void dispose() {
    _fqdnController.dispose();
    _loginController.dispose();
    _tokenController.dispose();
    _siteController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  /// Parse JSON credentials and return a Map or null if invalid
  Map<String, String>? _parseJsonCredentials(String jsonString) {
    final trimmed = jsonString.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _jsonError = 'Please enter JSON credentials';
      });
      return null;
    }

    try {
      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) {
        setState(() {
          _jsonError = 'Invalid JSON: Expected an object';
        });
        return null;
      }

      final json = decoded;

      // Extract fields with alternative key support (api_key/apiKey, site_name/siteName)
      final fqdn = json['fqdn']?.toString();
      final login = json['login']?.toString();
      final token = (json['api_key'] ?? json['apiKey'])?.toString();
      final siteName = (json['site_name'] ?? json['siteName'])?.toString();

      // Validate required fields
      if (fqdn == null || fqdn.trim().isEmpty) {
        setState(() {
          _jsonError = 'Missing required field: fqdn';
        });
        return null;
      }

      if (login == null || login.trim().isEmpty) {
        setState(() {
          _jsonError = 'Missing required field: login';
        });
        return null;
      }

      if (token == null || token.trim().isEmpty) {
        setState(() {
          _jsonError = 'Missing required field: api_key or apiKey';
        });
        return null;
      }

      // Clear any previous error
      setState(() {
        _jsonError = null;
      });

      return {
        'fqdn': fqdn.trim(),
        'login': login.trim(),
        'token': token.trim(),
        'siteName': siteName?.trim() ?? '',
      };
    } on FormatException {
      setState(() {
        _jsonError = 'Invalid JSON format';
      });
      return null;
    }
  }

  void _onContinuePressed() {
    if (_entryMode == CredentialEntryMode.manual) {
      // Manual mode: validate form
      if (_formKey.currentState?.validate() != true) {
        return;
      }
      final credentials = <String, String>{
        'fqdn': _fqdnController.text.trim(),
        'login': _loginController.text.trim(),
        'token': _tokenController.text.trim(),
        'siteName': _siteController.text.trim(),
      };
      _submitCredentials(credentials);
    } else {
      // JSON mode: parse JSON
      final credentials = _parseJsonCredentials(_jsonController.text);
      if (credentials != null) {
        _submitCredentials(credentials);
      }
    }
  }

  void _submitCredentials(Map<String, String> credentials) {
    if (widget.onCredentialsSubmitted != null) {
      widget.onCredentialsSubmitted!(credentials);
    } else {
      Navigator.of(context).pop(credentials);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter credentials',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Manual entry or paste JSON credentials.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Mode toggle using SegmentedButton
              SegmentedButton<CredentialEntryMode>(
                segments: const [
                  ButtonSegment<CredentialEntryMode>(
                    value: CredentialEntryMode.manual,
                    label: Text('Manual'),
                    icon: Icon(Icons.edit),
                  ),
                  ButtonSegment<CredentialEntryMode>(
                    value: CredentialEntryMode.json,
                    label: Text('JSON'),
                    icon: Icon(Icons.code),
                  ),
                ],
                selected: {_entryMode},
                onSelectionChanged: (Set<CredentialEntryMode> newSelection) {
                  setState(() {
                    _entryMode = newSelection.first;
                    _jsonError = null; // Clear error on mode switch
                  });
                },
              ),
              const SizedBox(height: 24),
              // Show either manual fields or JSON input based on mode
              if (_entryMode == CredentialEntryMode.manual) ...[
                TextFormField(
                  controller: _fqdnController,
                  decoration: const InputDecoration(
                    labelText: 'Server (fqdn)',
                    hintText: 'example.rxg.com',
                  ),
                  autofillHints: const [AutofillHints.url],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Server is required';
                    }
                    if (value.contains('://')) {
                      return 'Remove protocol (https://)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _loginController,
                  decoration: const InputDecoration(
                    labelText: 'Login',
                    hintText: 'username',
                  ),
                  autofillHints: const [AutofillHints.username],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Login is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Token',
                    hintText: 'api_key_here',
                  ),
                  autofillHints: const [AutofillHints.password],
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'token is required';
                    }
                    if (value.trim().length < 10) {
                      return 'token looks too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _siteController,
                  decoration: const InputDecoration(
                    labelText: 'Site (optional)',
                  ),
                ),
              ] else ...[
                // JSON input mode
                TextFormField(
                  key: const Key('json_input_field'),
                  controller: _jsonController,
                  decoration: InputDecoration(
                    labelText: 'JSON Credentials',
                    hintText: '{\n  "fqdn": "...",\n  "login": "...",\n  "api_key": "..."\n}',
                    alignLabelWithHint: true,
                    errorText: _jsonError,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Paste full JSON credentials. Required fields: fqdn, login, api_key (or apiKey)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _onContinuePressed,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = selectable
        ? SelectableText(
            value,
            style: theme.textTheme.bodyLarge,
          )
        : Text(
            value,
            style: theme.textTheme.bodyLarge,
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          content,
        ],
      ),
    );
  }
}
