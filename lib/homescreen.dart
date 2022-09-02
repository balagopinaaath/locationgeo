import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentUserPosition;
  double? distanceImMeter = 0.0;
  Data data = Data();
  String lastKnownPosition = '';

  void getLastKnownPosition() async {
    Position? position = await Geolocator.getLastKnownPosition();
    setState(() {
      lastKnownPosition = '$position';
      print(lastKnownPosition);
    });
  }


  void getLocationUpdates() async {
    StreamSubscription<Position>? positionStream;

    positionStream = Geolocator.getPositionStream().listen((Position position) {
      _currentUserPosition = position;
      print(positionStream);
    });
  }


  Future _getTheDistance() async {
    //
    bool serviceEnabled;
    LocationPermission permission;
    Position? position;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    setState(() {
      _currentUserPosition = position;
    });


    _currentUserPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    for (int i = 0; i < data.allstores.length; i++) {
      double storelat = data.allstores[i]['lat'];
      double storelng = data.allstores[i]['lng'];

      distanceImMeter = await Geolocator.distanceBetween(
        _currentUserPosition!.latitude,
        _currentUserPosition!.longitude,
        storelat,
        storelng,
      );
      var distance = distanceImMeter?.round().toInt();

      data.allstores[i]['distance'] = (distance! / 1000);
      setState(() {
        print(_currentUserPosition);
        print(data.allstores[1]);
      });
    }
  }

  @override
  void initState() {
    _getTheDistance();
    getLocationUpdates();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('GeoLocator'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
        child: GridView.builder(
            itemCount: data.allstores.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 3 / 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return Container(
                color: Color(0xff3498db),
                height: height * 0.9,
                width: width * 0.3,
                child: Column(
                  children: [
                    Text('Last Known Position: $lastKnownPosition',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text('Current Position: $_currentUserPosition',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    ),
                    // Container(
                    //   height: height * 0.12,
                    //   width: width,
                    //   child: Image.network(
                    //     data.allstores[index]['image'],
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      data.allstores[index]['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on),
                        Text(
                          "${data.allstores[index]['distance'].round()} KM Away",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
        ),
      )
    );
  }

}












class Data {
  List allstores = [
    {
      "name": "Mandela Nagar",
      "image":
      "https://mediacdn.99acres.com/media1/17984/4/359684254M-1652205720401.jpg",
      "lat": 9.841038808583313,
      "lng": 78.10469370479055,
      "distance": 0,
    },
    {
      "name": "Venzo Technologies",
      "image": "https://www.venzotechnologies.com/wp-content/uploads/2022/02/Why-Selenium-is-most-widely-used-Test-Automation-Tool.png",
      "lat": 9.928999633610541,
      "lng": 78.16747418436951,
      "distance": 0,
    },
    {
      "name": "Velammal Hospital",
      "image": "https://dqcu705oe4ovf.cloudfront.net/8460fac6-6f0e-442e-9b4b-23242cd6ee34/gK0mAFhCyJ.jpeg",
      "lat": 9.886941521931771,
      "lng": 78.15010325553365,
      "distance": 0,
    },
    {
      "name": "Madurai Meenakshi Amman Temple",
      "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Main_Gate_of_Meenakshi_temple%2C_Madurai.jpg/220px-Main_Gate_of_Meenakshi_temple%2C_Madurai.jpg",
      "lat": 9.857188877111206,
      "lng": 78.0280424420403,
      "distance": 0,
    },

  ];
}















// _getCurrentLocation() {
//   Geolocator
//       .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
//       .then((Position position) {
//     setState(() {
//       _currentPosition = position;
//       print(_currentPosition);
//       _getAddressFromLatLng();
//     });
//   }).catchError((e) {
//     print(e);
//   });
// }
