import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothProvider extends ChangeNotifier {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
  final textController = TextEditingController();
  BluetoothDevice? connectedDevice;
  List<BluetoothService>? bluetoothServices;

  onInitProvider() {
    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        showDeviceToList(device);
      }
    });
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        showDeviceToList(result.device);
      }
    });
    flutterBlue.startScan(scanMode: ScanMode.balanced,allowDuplicates: false);
  }

  showDeviceToList(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      devicesList.add(device);
      notifyListeners();
    }
  }

  getReadValue({BluetoothCharacteristic? characteristic, dynamic value}) {
    readValues[characteristic!.uuid] = value;
    notifyListeners();
  }

  disconnectBluetooth() async {
    flutterBlue.stopScan();
    await connectedDevice?.disconnect();
    connectedDevice = null;
    notifyListeners();
  }
}
