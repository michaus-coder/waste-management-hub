import 'dart:math';

import 'package:flutter/material.dart';
// Import the Google Maps package
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// Initial location of the Map view
CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

// For controlling the view of the Map
late GoogleMapController mapController;

late Position _currentPosition;
Set<Marker> _markers = {};

late PolylinePoints polylinePoints;
List<LatLng> polylineCoordinates = [];
Map<PolylineId, Polyline> _polylines = {};

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _generateMarkers();
  }

  @override
  Widget build(BuildContext context) {
    // Determining the screen width & height
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              markers: Set<Marker>.of(_markers),
              polylines: Set<Polyline>.of(_polylines.values),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          _getCurrentLocation();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Row(
                    children: [
                      ClipOval(
                        child: Material(
                          color: Colors.orange.shade100, // button color
                          child: InkWell(
                              splashColor: Colors.orange, // inkwell color
                              child: const SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(Icons.zoom_in),
                              ),
                              onTap: () {
                                mapController.animateCamera(
                                  CameraUpdate.zoomIn(),
                                );
                              }),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ClipOval(
                        child: Material(
                          color: Colors.orange.shade100, // button color
                          child: InkWell(
                              splashColor: Colors.orange, // inkwell color
                              child: const SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(Icons.zoom_out),
                              ),
                              onTap: () {
                                mapController.animateCamera(
                                  CameraUpdate.zoomOut(),
                                );
                              }),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          mapController.getZoomLevel().then((zoom) {
                            if (zoom != 14) {
                              mapController.animateCamera(
                                CameraUpdate.zoomTo(14),
                              );
                            }
                          });
                          setState(() {
                            _polylines.clear();
                          });
                          Marker shortest =
                              calculateShortestPath(_currentPosition, _markers);
                          _createPolylines(
                              _currentPosition.latitude,
                              _currentPosition.longitude,
                              shortest.position.latitude,
                              shortest.position.longitude);
                        },
                        child: const Text("Find the nearest garbage bank"),
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method for retrieving the current location

  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        // Store the position in the variable
        _currentPosition = position;

        print('CURRENT POS: $_currentPosition');

        // For moving the camera to current location
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _MapViewState();
    }).catchError((e) {
      print(e);
    });
  }

  LatLng getRandomLocation(LatLng point, int radius) {
    //This is to generate 10 random points
    double x0 = point.latitude;
    double y0 = point.longitude;

    Random random = new Random();

    // Convert radius from meters to degrees
    double radiusInDegrees = radius / 111000;

    double u = random.nextDouble();
    double v = random.nextDouble();
    double w = radiusInDegrees * sqrt(u);
    double t = 2 * pi * v;
    double x = w * cos(t);
    double y = w * sin(t) * 1.75;

    // Adjust the x-coordinate for the shrinking of the east-west distances
    double new_x = x / sin(y0);

    double foundLatitude = new_x + x0;
    double foundLongitude = y + y0;
    LatLng randomLatLng = new LatLng(foundLatitude, foundLongitude);

    return randomLatLng;
  }

  _generateMarkers() async {
    await _getCurrentLocation();
    // This is to generate 10 random points
    for (int i = 0; i < 10; i++) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(i.toString()),
          position: getRandomLocation(
              LatLng(
                _currentPosition.latitude,
                _currentPosition.longitude,
              ),
              1000),
          infoWindow: const InfoWindow(
            title: 'Garbage Bank',
            snippet: 'This is a random location',
          ),
        ));
      });
    }
  }

  Marker calculateShortestPath(Position currentPosition, Set<Marker> markers) {
    var lat = currentPosition.latitude;
    var lng = currentPosition.longitude;
    var R = 6371e3; // metres
    var distances = [];
    var closest = -1;
    for (Marker marker in markers) {
      var lat2 = marker.position.latitude;
      var lng2 = marker.position.longitude;
      var dLat = rad(lat2 - lat);
      var dLon = rad(lng2 - lng);
      var a = sin(dLat / 2) * sin(dLat / 2) +
          cos(rad(lat)) * cos(rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
      var c = 2 * atan2(sqrt(a), sqrt(1 - a));
      var d = R * c;
      distances.add(d);
      if (closest == -1 || d < distances[closest]) {
        closest = distances.indexOf(d);
      }
    }
    return markers.elementAt(closest);
  }

  double rad(double x) {
    return x * pi / 180;
  }

  _createPolylines(double latitude, double longitude, double latitude2,
      double longitude2) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyD5jBkjxe54oAvjQdcHWEi7QrWyZtpypuQ", // Google Maps API Key
      PointLatLng(latitude, longitude),
      PointLatLng(latitude2, longitude2),
      travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    // polylines[id] = polyline;

    setState(() {
      _polylines[id] = polyline;
    });
  }
}
