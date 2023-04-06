import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ListView _buildListViewOfDevices(BluetoothProvider bluetoothProvider) {
    return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (context, index) => Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(bluetoothProvider.devicesList[index].name == ''
                          ? '(unknown device)'
                          : bluetoothProvider.devicesList[index].name),
                      Text(bluetoothProvider.devicesList[index].id.toString()),
                    ],
                  ),
                ),
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Color(0xE5E59234)),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    bluetoothProvider.flutterBlue.stopScan();
                    try {
                      await bluetoothProvider.devicesList[index].connect();
                    } catch (e) {
                      if (e != 'already_connected') {
                        rethrow;
                      }
                    } finally {
                      bluetoothProvider.bluetoothServices =
                          await bluetoothProvider.devicesList[index]
                              .discoverServices();
                    }

                    setState(() {
                      bluetoothProvider.connectedDevice =
                          bluetoothProvider.devicesList[index];
                    });
                  },
                ),
              ],
            ),
        separatorBuilder: (context, index) => const Divider(
              thickness: 0.5,
              color: Color(0xE5E59234),
            ),
        itemCount: bluetoothProvider.devicesList.length);
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic,
      BluetoothProvider bluetoothProvider) {
    List<ButtonTheme> buttons = <ButtonTheme>[];

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xE5E59234)),
              ),
              child: const Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  // setState(() {
                  //   bluetoothProvider.readValues[characteristic.uuid] = value;
                  // });
                  bluetoothProvider.getReadValue(
                      characteristic: characteristic, value: value);
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xE5E59234)),
              ),
              child: const Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: bluetoothProvider.textController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Send"),
                            onPressed: () {
                              characteristic.write(utf8.encode(
                                  bluetoothProvider.textController.value.text));
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xE5E59234)),
              ),
              child:
                  const Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  bluetoothProvider.readValues[characteristic.uuid] = value;
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  _buildConnectDeviceView(BluetoothProvider bluetoothProvider) {
    List<Widget> containers = <Widget>[];

    for (BluetoothService service in bluetoothProvider.bluetoothServices!) {
      List<Widget> characteristicsWidget = <Widget>[];

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(
                        characteristic, bluetoothProvider),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                          'Value: ${bluetoothProvider.readValues[characteristic.uuid]}'),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        ExpansionTile(
            title: Text(service.uuid.toString()),
            children: characteristicsWidget),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              ...containers,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xE5E75C5C),
              minimumSize: const Size.fromHeight(50), // NEW
            ),
            onPressed: () async {
              bluetoothProvider.disconnectBluetooth();
            },
            child: const Text(
              'Disconnect',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ],
    );
  }

  _buildView(BluetoothProvider bluetoothProvider) {
    if (bluetoothProvider.connectedDevice != null) {
      return _buildConnectDeviceView(bluetoothProvider);
    }
    return _buildListViewOfDevices(bluetoothProvider);
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => BluetoothProvider()..onInitProvider(),
        child: Consumer<BluetoothProvider>(
          builder: (context, bltProvider, _) => Scaffold(
            appBar: AppBar(
              elevation: 15,
              backgroundColor: const Color(0xE5E59234),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              centerTitle: true,
              title: Text(bltProvider.connectedDevice != null
                  ? bltProvider.connectedDevice?.name ?? ''
                  : "Bluetooth Device"),
            ),
            body: _buildView(bltProvider),
          ),
        ),
      );
}
