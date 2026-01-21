import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';

class APUplinkInfo {
  const APUplinkInfo({
    required this.apId,
    this.linkSpeed,
    this.speedInBps,
    this.portName,
    this.portNumber,
    this.rawPortData,
  });

  final int apId;
  final int? linkSpeed;
  final int? speedInBps;
  final String? portName;
  final int? portNumber;
  final Map<String, dynamic>? rawPortData;
}

class APUplinkService {
  APUplinkService({
    required WebSocketService webSocketService,
    Logger? logger,
    Map<int, APUplinkInfo>? cache,
  })  : _webSocketService = webSocketService,
        _logger = logger ?? Logger(),
        _cache = cache ?? <int, APUplinkInfo>{};

  final WebSocketService _webSocketService;
  final Logger _logger;
  final Map<int, APUplinkInfo> _cache;
  final Map<int, Future<APUplinkInfo?>> _inFlight = {};

  Map<int, APUplinkInfo> get cache => _cache;

  APUplinkInfo? getCachedUplink(int apId) {
    return _cache[apId];
  }

  Future<APUplinkInfo?> getAPUplinkPortDetail(int apId) {
    final cached = _cache[apId];
    if (cached != null) {
      return Future.value(cached);
    }

    final inflight = _inFlight[apId];
    if (inflight != null) {
      return inflight;
    }

    final request = fetchAPUplinkDetail(apId);
    _inFlight[apId] = request;
    return request.whenComplete(() => _inFlight.remove(apId));
  }

  Future<APUplinkInfo?> fetchAPUplinkDetail(int apId) async {
    if (!_webSocketService.isConnected) {
      _logger.w(
        'APUplinkService: WebSocket disconnected, cannot fetch uplink for AP $apId',
      );
      return null;
    }

    try {
      final apResponse = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: 'access_points',
        additionalData: {'crud_action': 'show', 'id': apId},
        timeout: const Duration(seconds: 15),
      );

      final infrastructureLinkId = _parseInt(
        apResponse.payload['data']?['infrastructure_link_id'],
      );
      if (infrastructureLinkId == null) {
        _logger.i(
          'APUplinkService: No infrastructure_link_id found for AP $apId',
        );
        return null;
      }

      final linkResponse = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: 'infrastructure_links',
        additionalData: {'crud_action': 'show', 'id': infrastructureLinkId},
        timeout: const Duration(seconds: 15),
      );

      final switchPorts = linkResponse.payload['data']?['switch_ports'];
      if (switchPorts is! List || switchPorts.isEmpty) {
        _logger.i(
          'APUplinkService: No switch_ports found for infrastructure link $infrastructureLinkId',
        );
        return null;
      }

      final firstPort = switchPorts.first;
      final portId = firstPort is Map<String, dynamic>
          ? _parseInt(firstPort['id'])
          : _parseInt(firstPort);
      if (portId == null) {
        _logger.w(
          'APUplinkService: Could not determine switch port id for AP $apId',
        );
        return null;
      }

      final portResponse = await _webSocketService.requestActionCable(
        action: 'resource_action',
        resourceType: 'switch_ports',
        additionalData: {'crud_action': 'show', 'id': portId},
        timeout: const Duration(seconds: 15),
      );

      final portData = portResponse.payload['data'];
      if (portData is! Map<String, dynamic>) {
        _logger.w(
          'APUplinkService: Invalid switch_port payload for port $portId',
        );
        return null;
      }

      final info = APUplinkInfo(
        apId: apId,
        linkSpeed: _parseInt(portData['link_speed']),
        speedInBps: _parseInt(portData['speed_in_bps']),
        portName: portData['name']?.toString(),
        portNumber: _parseInt(portData['port']),
        rawPortData: portData,
      );

      _cache[apId] = info;
      return info;
    } catch (e) {
      _logger.e('APUplinkService: Failed to fetch uplink for AP $apId: $e');
      return null;
    }
  }

  void clearCache() {
    _cache.clear();
    _inFlight.clear();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return int.tryParse(value.toString());
  }
}
