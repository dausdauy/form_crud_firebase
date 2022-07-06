import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

class NetworkServices {
  final Connectivity _connectivity = Connectivity();
  StreamController<NetworkStatus> cNetworkStatus =
      StreamController<NetworkStatus>();

  NetworkServices() {
    _connectivity.onConnectivityChanged
        .listen((status) => _getNetworkStatus(status));
  }

  _getNetworkStatus(ConnectivityResult status) {
    return status == ConnectivityResult.wifi ||
            status == ConnectivityResult.mobile
        ? NetworkStatus.online
        : NetworkStatus.offline;
  }
}
