import 'package:flutter/material.dart';

class CredentialApprovalSheet extends StatefulWidget {
  const CredentialApprovalSheet({
    required this.fqdn,
    required this.login,
    required this.apiKey,
    this.siteName,
    this.issuedAt,
    this.signature,
    super.key,
  });

  final String fqdn;
  final String login;
  final String apiKey;
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
    final keyDisplay = _obscureKey ? _obscure(widget.apiKey) : widget.apiKey;

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
                  label: 'API Key',
                  value: keyDisplay,
                  selectable: !_obscureKey,
                ),
              ),
              IconButton(
                tooltip: _obscureKey ? 'Show API key' : 'Hide API key',
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

class ManualCredentialEntrySheet extends StatefulWidget {
  const ManualCredentialEntrySheet({super.key});

  @override
  State<ManualCredentialEntrySheet> createState() =>
      _ManualCredentialEntrySheetState();
}

class _ManualCredentialEntrySheetState
    extends State<ManualCredentialEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _fqdnController = TextEditingController();
  final _loginController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _siteController = TextEditingController();

  @override
  void dispose() {
    _fqdnController.dispose();
    _loginController.dispose();
    _apiKeyController.dispose();
    _siteController.dispose();
    super.dispose();
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
                'Manual entry is available when a QR code is unavailable.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _fqdnController,
              decoration: const InputDecoration(
                labelText: 'Server (fqdn)',
                hintText: 'zew.netlab.ninja',
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
                hintText: 'fieldtech',
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
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Paste or scan key',
              ),
              autofillHints: const [AutofillHints.password],
              obscureText: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'API key is required';
                }
                if (value.trim().length < 10) {
                  return 'API key looks too short';
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
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) {
                        return;
                      }
                      Navigator.of(context).pop(<String, String>{
                        'fqdn': _fqdnController.text.trim(),
                        'login': _loginController.text.trim(),
                        'apiKey': _apiKeyController.text.trim(),
                        'siteName': _siteController.text.trim(),
                      });
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
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
