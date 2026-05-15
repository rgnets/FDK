/// Classification of iperf3 failures, derived from the native `errorCode`
/// (iperf3's internal `i_errno`) returned by the JNI bridge.
///
/// The bridge passes `i_errno` straight through as the `errorCode` field of
/// the run-client result map, plus two sentinels: `-999` for a user cancel
/// and `-1` for a setup failure with no JSON output.
enum IperfErrorCategory {
  /// User cancelled the test (or it was interrupted on purpose).
  cancelled,

  /// Test could not be created/initialized - failed before any traffic.
  setup,

  /// Could not reach the server: control or data socket never connected.
  cannotConnect,

  /// Control channel dropped mid-handshake or mid-test (cookie/params/
  /// results exchange, control socket read/write, select()).
  controlChannelLost,

  /// Data stream was interrupted mid-transfer: stream socket read/write
  /// failed or the peer closed it unexpectedly. This is the "unable to
  /// read stream" case - usually a symptom of the connection going bad
  /// after the test was already running.
  streamInterrupted,

  /// Server is busy running another test.
  serverBusy,

  /// The peer (client or server) terminated the test.
  peerTerminated,

  /// Anything not specifically classified.
  unknown;

  /// Short label for logs / debugging.
  String get debugLabel {
    switch (this) {
      case IperfErrorCategory.cancelled:
        return 'cancelled';
      case IperfErrorCategory.setup:
        return 'setup-failure';
      case IperfErrorCategory.cannotConnect:
        return 'cannot-connect';
      case IperfErrorCategory.controlChannelLost:
        return 'control-channel-lost';
      case IperfErrorCategory.streamInterrupted:
        return 'stream-interrupted';
      case IperfErrorCategory.serverBusy:
        return 'server-busy';
      case IperfErrorCategory.peerTerminated:
        return 'peer-terminated';
      case IperfErrorCategory.unknown:
        return 'unknown';
    }
  }

  /// User-facing message for this failure category.
  String get userMessage {
    switch (this) {
      case IperfErrorCategory.cancelled:
        return 'Test cancelled.';
      case IperfErrorCategory.setup:
        return 'Unable to start the speed test. Please try again.';
      case IperfErrorCategory.cannotConnect:
        return 'Could not reach the test server. '
            'Check your network connection.';
      case IperfErrorCategory.controlChannelLost:
        return 'Lost connection to the test server during setup.';
      case IperfErrorCategory.streamInterrupted:
        return 'The connection dropped during the test. '
            'Check your signal and try again.';
      case IperfErrorCategory.serverBusy:
        return 'The test server is busy. Please try again in a moment.';
      case IperfErrorCategory.peerTerminated:
        return 'The test server ended the test unexpectedly.';
      case IperfErrorCategory.unknown:
        return 'Unable to connect to server. '
            'Please check your internet connection.';
    }
  }
}

/// Map a native iperf3 `errorCode` to a [IperfErrorCategory].
///
/// Codes mirror the `i_errno` enum in `iperf_api.h`. `null` (no code
/// reported) maps to [IperfErrorCategory.unknown].
IperfErrorCategory classifyIperfError(int? code) {
  if (code == null) {
    return IperfErrorCategory.unknown;
  }

  switch (code) {
    // Bridge sentinels.
    case -999:
      return IperfErrorCategory.cancelled;
    case -1:
      return IperfErrorCategory.setup;

    // Test/stream creation & initialization.
    case 100: // IENEWTEST
    case 101: // IEINITTEST
    case 200: // IECREATESTREAM
    case 201: // IEINITSTREAM
      return IperfErrorCategory.setup;

    // Could not establish a connection to the server.
    case 103: // IECONNECT
    case 203: // IESTREAMCONNECT
      return IperfErrorCategory.cannotConnect;

    // Control channel problems (handshake or mid-test control traffic).
    case 105: // IESENDCOOKIE
    case 106: // IERECVCOOKIE
    case 107: // IECTRLWRITE
    case 108: // IECTRLREAD
    case 109: // IECTRLCLOSE
    case 110: // IEMESSAGE
    case 111: // IESENDMESSAGE
    case 112: // IERECVMESSAGE
    case 113: // IESENDPARAMS
    case 114: // IERECVPARAMS
    case 116: // IESENDRESULTS
    case 117: // IERECVRESULTS
    case 118: // IESELECT
      return IperfErrorCategory.controlChannelLost;

    // Peer terminated the test.
    case 119: // IECLIENTTERM
    case 120: // IESERVERTERM
      return IperfErrorCategory.peerTerminated;

    // Server busy with another test.
    case 121: // IEACCESSDENIED
      return IperfErrorCategory.serverBusy;

    // Data stream interrupted mid-transfer.
    case 205: // IESTREAMWRITE
    case 206: // IESTREAMREAD
    case 207: // IESTREAMCLOSE
      return IperfErrorCategory.streamInterrupted;

    default:
      return IperfErrorCategory.unknown;
  }
}
