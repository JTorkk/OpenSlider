import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:numberpicker/numberpicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenSlider control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(title: 'OpenSlider control'),
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key key, this.title}) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  BluetoothDevice _slider;
  var deviceName;
  var changeView = false;
  bool b = false;
  List<BluetoothService> _services;

  var _buttonState = false;

  void _scanForDevices() async {
    widget.flutterBlue.startScan(timeout: Duration(seconds: 5));

    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult r in results) {
        if (r.device.name == 'OpenSlider') {
          setState(() {
            _slider = r.device;
            deviceName = r.device.name;
            _buttonState = true;
          });
          break;
        }
      }
    });
    widget.flutterBlue.stopScan();
  }

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

/* WILL BE USED SOME DAY
  void _button(var text, var data,
      /*var color,*/ BluetoothCharacteristic characteristic) {
    return (FlatButton(
        color: Colors.green,
        padding: EdgeInsets.all(8.0),
        splashColor: Colors.greenAccent,
        child: Text(text),
        onPressed: () async {
          characteristic.write(utf8.encode(data));
        }));
  }*/

  ListView _buildConnectView() {
    List<Container> containers = new List<Container>();

    containers.add(
      Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),
            ButtonTheme(
                minWidth: 10,
                height: 40,
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: RaisedButton(
                      child: Text('Search for sliders',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () {
                        _scanForDevices();
                      },
                    ))),
            SizedBox(height: 20),
            Text('Found These sliders:', style: TextStyle(fontSize: 20)),
            Text(deviceName == null ? ' ' : '$deviceName',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic)),
            SizedBox(height: 20),
            if (deviceName != null)
              ButtonTheme(
                minWidth: 10,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: RaisedButton(
                      child: Text('CONNECT',
                          style: TextStyle(color: Colors.white, fontSize: 30)),
                      onPressed: _buttonState
                          ? () async {
                              widget.flutterBlue.stopScan();
                              try {
                                await _slider.connect();
                              } catch (e) {
                                if (e.code != 'already_connected') {
                                  throw e;
                                }
                              } finally {
                                _services = await _slider.discoverServices();
                              }
                              setState(() {
                                changeView = true;
                              });
                            }
                          : null),
                ),
              ),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildControlView() {
    List<Container> containers = new List<Container>();

    int _speed = 1;
    int _accelaration = 0;

    for (BluetoothService service in _services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.write) {
          containers.add(
            Container(
                child: Column(
              children: <Widget>[
                //? Move buttons
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(202, 208, 219, 1),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  //height: 40,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FlatButton(
                              onPressed: () {},
                              child: Container(
                                child: GestureDetector(
                                  onTapDown: (_) async {
                                    c.write(utf8.encode('s'));
                                  },
                                  onTapUp: (_) async {
                                    c.write(utf8.encode('P'));
                                  },
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {},
                              child: Container(
                                child: GestureDetector(
                                  onTapDown: (_) async {
                                    c.write(utf8.encode('S'));
                                  },
                                  onTapUp: (_) async {
                                    c.write(utf8.encode('P'));
                                  },
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FlatButton(
                              onPressed: () {},
                              child: Container(
                                child: GestureDetector(
                                  onTapDown: (_) async {
                                    c.write(utf8.encode('t'));
                                  },
                                  onTapUp: (_) async {
                                    c.write(utf8.encode('P'));
                                  },
                                  child: Icon(
                                    Icons.rotate_left_rounded,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {},
                              child: Container(
                                child: GestureDetector(
                                  onTapDown: (_) async {
                                    c.write(utf8.encode('T'));
                                  },
                                  onTapUp: (_) async {
                                    c.write(utf8.encode('P'));
                                  },
                                  child: Icon(
                                    Icons.rotate_right_rounded,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //! uncomment if third motor is added!!!
                      /*
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FlatButton(
                              onPressed: () {},
                              child: Container(
                                child: GestureDetector(
                                  onTapDown: (_) async {
                                    c.write(utf8.encode('0'));
                                  },
                                  onTapUp: (_) async {
                                    c.write(utf8.encode('4'));
                                  },
                                  child: Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                            FlatButton(
                              onPressed: () {},
                              child: Container(
                                child: GestureDetector(
                                  onTapDown: (_) async {
                                    c.write(utf8.encode('0'));
                                  },
                                  onTapUp: (_) async {
                                    c.write(utf8.encode('4'));
                                  },
                                  child: Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),*/
                    ],
                  ),
                ),
                //?speed and accel picker
                //!uncomment when working
                /*Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(202, 208, 219, 1),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  //height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          NumberPicker.integer(
                            initialValue: _speed,
                            minValue: 1,
                            maxValue: 5,
                            onChanged: (newValue) =>
                                setState(() => _speed = newValue),
                          ),
                          Text("Speed: $_speed"),
                        ],
                      ),
                      Column(
                        children: [
                          NumberPicker.integer(
                            initialValue: _accelaration,
                            minValue: 0,
                            maxValue: 4,
                            onChanged: (newValue) =>
                                setState(() => _accelaration = newValue),
                          ),
                          Text("Accelaration: $_accelaration"),
                        ],
                      ),
                    ],
                  ),
                ),
*/
                //? Set keyframes
                Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(202, 208, 219, 1),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  //height: 40,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),

                              //padding: EdgeInsets.zero,
                              color: Colors.blueAccent,
                              onPressed: () {},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () async {
                                    c.write(utf8.encode('j'));
                                  },
                                  onLongPress: () async {
                                    c.write(utf8.encode('J'));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Position 1',
                                        textAlign: TextAlign.center,
                                      ),
                                      Icon(
                                        Icons.add_rounded,
                                        size: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),

                              //padding: EdgeInsets.zero,
                              color: Colors.blueAccent,
                              onPressed: () {},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () async {
                                    c.write(utf8.encode('k'));
                                  },
                                  onLongPress: () async {
                                    c.write(utf8.encode('K'));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Position 2',
                                        textAlign: TextAlign.center,
                                      ),
                                      Icon(
                                        Icons.add_rounded,
                                        size: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),

                              //padding: EdgeInsets.zero,
                              color: Colors.blueAccent,
                              onPressed: () {},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () async {
                                    c.write(utf8.encode('l'));
                                  },
                                  onLongPress: () async {
                                    c.write(utf8.encode('L'));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Position 3',
                                        textAlign: TextAlign.center,
                                      ),
                                      Icon(
                                        Icons.add_rounded,
                                        size: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),

                              //padding: EdgeInsets.zero,
                              color: Colors.blueAccent,
                              onPressed: () {},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () async {
                                    c.write(utf8.encode('m'));
                                  },
                                  onLongPress: () async {
                                    c.write(utf8.encode('M'));
                                  },
                                  child: Column(
                                    children: [
                                      Text(
                                        'Position 4',
                                        textAlign: TextAlign.center,
                                      ),
                                      Icon(
                                        Icons.add_rounded,
                                        size: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //? record, start and stop
                Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      //color: Color.fromRGBO(202, 208, 219, 1),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.blue[800],
                        onPressed: () {},
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () async {
                              c.write(utf8.encode('F'));
                            },
                            onLongPress: () async {
                              c.write(utf8.encode('f'));
                            },
                            child: Column(
                              children: [
                                Text(
                                  'Record',
                                  textAlign: TextAlign.center,
                                ),
                                Icon(
                                  Icons.circle,
                                  size: 40,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      FlatButton(
                        //minWidth: 120,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.green,
                        onPressed: () {},
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () async {
                              c.write(utf8.encode('p'));
                            },
                            child: Column(
                              children: [
                                Text(
                                  'start',
                                  textAlign: TextAlign.center,
                                ),
                                Icon(
                                  Icons.not_started,
                                  size: 40,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      FlatButton(
                        //minWidth: 120,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Colors.red,
                        onPressed: () {},
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: GestureDetector(
                            onTap: () async {
                              c.write(utf8.encode('P'));
                            },
                            child: Column(
                              children: [
                                Text(
                                  'Stop',
                                  textAlign: TextAlign.center,
                                ),
                                Icon(
                                  Icons.stop_rounded,
                                  size: 40,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //? disconnect button
                Container(
                  margin: EdgeInsets.all(10),
                  child: FlatButton(
                      child: Text('DISCONNECT',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          changeView = false;
                          _slider.disconnect();
                          deviceName = null;
                          _slider = null;
                          _buttonState = false;
                        });
                      }),
                )
              ],
            )),
          );
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (changeView) {
      return _buildControlView();
    }
    return _buildConnectView();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _buildView(),
      );
}
