import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_maps/maps.dart';


void main() {
  Get.put(HomeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  Scaffold(
        appBar: AppBar(
          title: Text('Flutter Test'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Trigger the action to show the map
              await Get.find<HomeController>().getPossition();
            },
            child: Text('Show Map'),
          ),
        ),
      ),
    );

  }
}

class HomeController extends GetxController {

  Future<void> getPossition() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      Position position = await _determinePosition();
      double lat = position.latitude;
      double lon = position.longitude;
      // Navigate to the map screen directly
      Get.to(() => CurrentLocationMapScreen(
        latitude: lat,
        longitude: lon,
      ));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }
    return await Geolocator.getCurrentPosition();
  }
}

class CurrentLocationMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  CurrentLocationMapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<CurrentLocationMapScreen> createState() => _CurrentLocationMapScreenState();
}

class _CurrentLocationMapScreenState extends State<CurrentLocationMapScreen> {
  late MapLatLng _markerPosition;
  late MapZoomPanBehavior _mapZoomPanBehavior;
  late MapTileLayerController _controller;
  String _selectLocationName = '';

  @override
  void initState() {
    _controller = MapTileLayerController();
    _mapZoomPanBehavior = MapZoomPanBehavior(minZoomLevel: 9);
    _markerPosition = MapLatLng(widget.latitude, widget.longitude);
    _getLocationDetails(widget.latitude, widget.longitude);
    print('>>>>>>>>>>>>>>>>>>>> laitude: ${widget.latitude} and longitude:  ${widget.longitude}');

    super.initState();
  }


  // getLocation details
  Future<void> _getLocationDetails(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude'));
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          _selectLocationName = decodedResponse['display_name'] ?? 'Unknown location';
          // You can print other location details here if needed
          print('Location Name: $_selectLocationName');
        });
      } else {
        setState(() {
          _selectLocationName = 'Unknown location';
        });
      }
    } catch (e) {
      print('Error getting location details: $e');
      setState(() {
        _selectLocationName = 'Unknown location';
      });
    }
  }




  void updateMarkerChange(Offset position) {

    _markerPosition = _controller.pixelToLatLng(position);
    _getLocationDetails(_markerPosition.latitude, _markerPosition.longitude);

    // Print the latitude and longitude of the new position
    print('New Latitude: ${_markerPosition.latitude}');
    print('New Longitude: ${_markerPosition.longitude}');

    if (_controller.markersCount > 0) {
      _controller.clearMarkers();
    }
    _controller.insertMarker(0);


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marker sample')),
      body: GestureDetector(
        onTapUp: (TapUpDetails details) {
          updateMarkerChange(details.localPosition);
        },
        child: SfMaps(
          layers: [
            MapTileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              zoomPanBehavior: _mapZoomPanBehavior,
              initialFocalLatLng: _markerPosition,
              controller: _controller,
              initialMarkersCount: 1,
              markerBuilder: (BuildContext context, int index) {
                return MapMarker(
                  latitude: _markerPosition.latitude,
                  longitude: _markerPosition.longitude,
                  child: Icon(Icons.location_on, color: Colors.red),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


}