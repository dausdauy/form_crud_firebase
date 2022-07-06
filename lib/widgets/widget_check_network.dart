import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/network_services.dart';

class WidgetCheckNetwork extends StatelessWidget {
  const WidgetCheckNetwork({
    Key? key,
    required this.childOnline,
    required this.childOffline,
  }) : super(key: key);

  final Widget childOnline;
  final Widget childOffline;

  @override
  Widget build(BuildContext context) {
    NetworkStatus? networkStatus = Provider.of<NetworkStatus?>(context);
    if (networkStatus == NetworkStatus.online) {
      return childOnline;
    } else {
      return childOffline;
    }
  }
}
