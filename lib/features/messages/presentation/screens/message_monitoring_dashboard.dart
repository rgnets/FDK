import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/message_metrics.dart';
import 'package:rgnets_fdk/features/messages/presentation/providers/message_center_provider.dart';

/// Production monitoring dashboard for the message system
class MessageMonitoringDashboard extends ConsumerStatefulWidget {
  const MessageMonitoringDashboard({super.key});

  @override
  ConsumerState<MessageMonitoringDashboard> createState() =>
      _MessageMonitoringDashboardState();
}

class _MessageMonitoringDashboardState
    extends ConsumerState<MessageMonitoringDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Auto-refresh every second
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messageCenterNotifierProvider);
    final metrics = state.metrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _exportDiagnostics(metrics),
            tooltip: 'Export',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmClear(context),
            tooltip: 'Clear All',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Analytics'),
            Tab(text: 'Diagnostics'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(metrics: metrics),
          _AnalyticsTab(metrics: metrics),
          _DiagnosticsTab(metrics: metrics),
          _EventsTab(messages: state.messages),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _sendTestMessage(context),
        icon: const Icon(Icons.send),
        label: const Text('Test'),
      ),
    );
  }

  void _exportDiagnostics(MessageMetrics metrics) {
    final buffer = StringBuffer();
    buffer.writeln('=== Message System Diagnostics ===');
    buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    buffer.writeln('Total Shown: ${metrics.totalShown}');
    buffer.writeln('Total Deduplicated: ${metrics.totalDeduplicated}');
    buffer.writeln('Total Dropped: ${metrics.totalDropped}');
    buffer.writeln('Total Errors: ${metrics.totalErrors}');
    buffer.writeln('Queue Size: ${metrics.queueSize}/${metrics.maxQueueSize}');
    buffer.writeln('Health Score: ${metrics.healthScore}/100');
    buffer.writeln();
    buffer.writeln('By Type: ${metrics.byType}');
    buffer.writeln('By Category: ${metrics.byCategory}');
    buffer.writeln('By Source: ${metrics.bySource}');
    buffer.writeln();
    if (metrics.issues.isNotEmpty) {
      buffer.writeln('Issues:');
      for (final issue in metrics.issues) {
        buffer.writeln('  - $issue');
      }
    }
    if (metrics.recommendations.isNotEmpty) {
      buffer.writeln('Recommendations:');
      for (final rec in metrics.recommendations) {
        buffer.writeln('  - $rec');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics copied to clipboard')),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'This will clear all message data and reset metrics. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(messageCenterNotifierProvider.notifier).clear();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _sendTestMessage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _TestMessageSheet(
        onSend: (type, content) {
          final notifier = ref.read(messageCenterNotifierProvider.notifier);
          switch (type) {
            case 'info':
              notifier.showInfo(content, sourceContext: 'test');
              break;
            case 'success':
              notifier.showSuccess(content, sourceContext: 'test');
              break;
            case 'warning':
              notifier.showWarning(content, sourceContext: 'test');
              break;
            case 'error':
              notifier.showError(content, sourceContext: 'test');
              break;
            case 'critical':
              notifier.showCritical(content, sourceContext: 'test');
              break;
          }
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.metrics});

  final MessageMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HealthScoreCard(score: metrics.healthScore),
        const SizedBox(height: 16),
        _QueueStatusCard(
          current: metrics.queueSize,
          max: metrics.maxQueueSize,
        ),
        const SizedBox(height: 16),
        _StatsCard(
          title: 'Message Stats',
          stats: {
            'Total Shown': metrics.totalShown.toString(),
            'Deduplicated': metrics.totalDeduplicated.toString(),
            'Dropped': metrics.totalDropped.toString(),
            'Errors': metrics.totalErrors.toString(),
          },
        ),
        const SizedBox(height: 16),
        if (metrics.issues.isNotEmpty) ...[
          _IssuesCard(issues: metrics.issues),
          const SizedBox(height: 16),
        ],
        if (metrics.recommendations.isNotEmpty)
          _RecommendationsCard(recommendations: metrics.recommendations),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({required this.metrics});

  final MessageMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatsCard(
          title: 'By Type',
          stats: metrics.byType.map((k, v) => MapEntry(k, v.toString())),
        ),
        const SizedBox(height: 16),
        _StatsCard(
          title: 'By Category',
          stats: metrics.byCategory.map((k, v) => MapEntry(k, v.toString())),
        ),
        const SizedBox(height: 16),
        _StatsCard(
          title: 'By Source',
          stats: metrics.bySource.map((k, v) => MapEntry(k, v.toString())),
        ),
        const SizedBox(height: 16),
        _StatsCard(
          title: 'Performance',
          stats: {
            'Queue Utilization': '${metrics.queueUtilization.toStringAsFixed(1)}%',
            'Deduplication Rate': '${metrics.deduplicationRate.toStringAsFixed(1)}%',
            'Error Rate': '${metrics.errorRate.toStringAsFixed(1)}%',
          },
        ),
      ],
    );
  }
}

class _DiagnosticsTab extends StatelessWidget {
  const _DiagnosticsTab({required this.metrics});

  final MessageMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatsCard(
          title: 'Session Info',
          stats: {
            'Session Start': metrics.sessionStart?.toString() ?? 'N/A',
            'Last Message': metrics.lastMessageTime?.toString() ?? 'N/A',
          },
        ),
        const SizedBox(height: 16),
        _StatsCard(
          title: 'Deduplication',
          stats: {
            'Total Deduplicated': metrics.totalDeduplicated.toString(),
            'Rate': '${metrics.deduplicationRate.toStringAsFixed(1)}%',
          },
        ),
        const SizedBox(height: 16),
        _StatsCard(
          title: 'Error Stats',
          stats: {
            'Total Errors': metrics.totalErrors.toString(),
            'Error Rate': '${metrics.errorRate.toStringAsFixed(1)}%',
          },
        ),
      ],
    );
  }
}

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.messages});

  final List<AppMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No messages yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageEventTile(message: message);
      },
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  const _HealthScoreCard({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 80
        ? Colors.green
        : score >= 50
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Health Score',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
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

class _QueueStatusCard extends StatelessWidget {
  const _QueueStatusCard({required this.current, required this.max});

  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final utilization = max > 0 ? current / max : 0.0;
    final color = utilization < 0.5
        ? Colors.green
        : utilization < 0.8
            ? Colors.orange
            : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Queue Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$current / $max',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: utilization,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.title, required this.stats});

  final String title;
  final Map<String, String> stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...stats.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text(
                      e.value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssuesCard extends StatelessWidget {
  const _IssuesCard({required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Issues',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...issues.map(
              (issue) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $issue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.recommendations});

  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $rec'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageEventTile extends StatelessWidget {
  const _MessageEventTile({required this.message});

  final AppMessage message;

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(message.type);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(_getIconForType(message.type), color: color, size: 20),
      ),
      title: Text(
        message.content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${message.type.name} • ${message.category.name} • ${_formatTime(message.timestamp)}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: message.action != null
          ? Chip(
              label: Text(
                message.action!.label,
                style: const TextStyle(fontSize: 10),
              ),
              visualDensity: VisualDensity.compact,
            )
          : null,
    );
  }

  Color _getColorForType(MessageType type) {
    return switch (type) {
      MessageType.transient => Colors.grey,
      MessageType.info => Colors.blue,
      MessageType.success => Colors.green,
      MessageType.warning => Colors.orange,
      MessageType.error => Colors.red,
      MessageType.critical => Colors.purple,
    };
  }

  IconData _getIconForType(MessageType type) {
    return switch (type) {
      MessageType.transient => Icons.info_outline,
      MessageType.info => Icons.info,
      MessageType.success => Icons.check_circle,
      MessageType.warning => Icons.warning,
      MessageType.error => Icons.error,
      MessageType.critical => Icons.dangerous,
    };
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _TestMessageSheet extends StatefulWidget {
  const _TestMessageSheet({required this.onSend});

  final void Function(String type, String content) onSend;

  @override
  State<_TestMessageSheet> createState() => _TestMessageSheetState();
}

class _TestMessageSheetState extends State<_TestMessageSheet> {
  String _selectedType = 'info';
  final _contentController = TextEditingController(text: 'Test message');

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Send Test Message',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'info', label: Text('Info')),
              ButtonSegment(value: 'success', label: Text('Success')),
              ButtonSegment(value: 'warning', label: Text('Warning')),
              ButtonSegment(value: 'error', label: Text('Error')),
            ],
            selected: {_selectedType},
            onSelectionChanged: (selection) {
              setState(() => _selectedType = selection.first);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Message Content',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onSend(_selectedType, _contentController.text);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
