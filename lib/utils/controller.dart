import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class C extends GetxController {
  var isConnected = RxString('');

  final Connectivity _connectivity = Connectivity();

  getNetworkStatus(ConnectivityResult status) {
    return status == ConnectivityResult.wifi ||
            status == ConnectivityResult.mobile
        ? isConnected('konek')
        : isConnected('gak');
  }

  @override
  void onInit() {
    _connectivity.onConnectivityChanged
        .listen((status) => getNetworkStatus(status));
    super.onInit();
  }
}
