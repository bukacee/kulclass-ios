import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:auralive/utils/utils.dart';

class InternetConnection {
  // Default to true to be optimistic, or false if you prefer strict checking
  static RxBool isConnect = true.obs; 

  static Future<void> init() async {
    final connectivity = Connectivity();

    // ✅ FIX 1: Check the current status IMMEDIATELY
    // Don't wait for a change. Ask "Are we connected right now?"
    List<ConnectivityResult> initialResult = await connectivity.checkConnectivity();
    _updateConnectionStatus(initialResult);

    // ✅ FIX 2: Listen for FUTURE changes
    connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // Helper method to avoid duplicating logic
  static void _updateConnectionStatus(List<ConnectivityResult> result) {
    // If the list is empty or contains 'none', we are disconnected
    if (result.contains(ConnectivityResult.none) || result.isEmpty) {
      isConnect.value = false;
      Utils.showLog("Network Not Connected...");
    } else {
      // Otherwise, we are connected (Wifi, Mobile, etc.)
      isConnect.value = true;
      Utils.showLog("Network Connected: ${result.first}");
    }
  }
}