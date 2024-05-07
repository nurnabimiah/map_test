import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:syncfusion_flutter_maps/maps.dart';



import 'home_controller.dart';


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
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Test'),
        ),


        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Trigger the action to show the map
              Get.find<HomeController>().getPossition();
            },
            child: Text('Show Map'),
          ),
        ),
      ),
    );
  }
}


class CurrentLocationMapScreen extends StatelessWidget {
  final double latitude, longitude;

  const CurrentLocationMapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: LocationSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: SfMaps(
        layers: [
          MapTileLayer(
            zoomPanBehavior: MapZoomPanBehavior(),
            initialFocalLatLng: MapLatLng(latitude, longitude),
            initialZoomLevel: 9,
            initialMarkersCount: 1,
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            markerBuilder: (BuildContext context, int index) {
              return MapMarker(
                latitude: latitude,
                longitude: longitude,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red[800],
                ),
                size: Size(20, 20),
              );
            },
          ),
        ],
      ),
    );
  }
}


class LocationSearchDelegate extends SearchDelegate<String> {

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Return an empty string instead of null
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement location search suggestions UI
    return const Center(
      child: Text('Search suggestions'),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  Future<List<Map<String, dynamic>>?> searchLocations(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      List<Map<String, dynamic>> locationInfo = [];
      for (var loc in locations) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            loc.latitude, loc.longitude);
        String address = placemarks.isNotEmpty ? placemarks[0].name ?? '' : '';
        locationInfo.add({
          'name': address,
          'latitude': loc.latitude,
          'longitude': loc.longitude,
        });
      }
      return locationInfo;
    } catch (e) {
      print('Error searching locations: $e');
      return null;
    }
  }



  // @override
  // Widget buildResults(BuildContext context) {
  //   return FutureBuilder<List<Map<String, dynamic>>?>(
  //     future: searchLocations(query),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return Center(child: CircularProgressIndicator());
  //       } else if (snapshot.hasError) {
  //         return Center(child: Text('Error: ${snapshot.error}'));
  //       } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
  //         return ListView.builder(
  //           itemCount: snapshot.data!.length,
  //           itemBuilder: (context, index) {
  //
  //             print('>>>sshgsdhjdsdkjf>>>>>>>>>>>>>>>>>>>>>${snapshot.data![index]}');
  //
  //             return ListTile(
  //               title: Text(snapshot.data![index]['name']),
  //               onTap: () {
  //
  //                 print('Selected Latitude: ${snapshot.data![index]['latitude']}, Longitude: ${snapshot.data![index]['longitude']}');
  //                 // Navigate to map screen with selected latitude and longitude
  //                 Navigator.of(context).push(
  //                   MaterialPageRoute(
  //                     builder: (context) =>
  //                         CurrentLocationMapScreen(
  //                           latitude: snapshot.data![index]['latitude'],
  //                           longitude: snapshot.data![index]['longitude'],
  //                         ),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         );
  //       } else {
  //         return Center(child: Text('No results found'));
  //       }
  //     },
  //   );
  // }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: searchLocations(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final location = snapshot.data![index];
              return ListTile(
                title: Text(location['name']),
                onTap: () async {
                  final latitude = location['latitude'];
                  final longitude = location['longitude'];

                  // Get the location name using reverse geocoding
                  String placeName = await getPlaceName(latitude, longitude);
                  print('Selected Location: $placeName');

                  // Navigate to map screen with selected latitude and longitude
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CurrentLocationMapScreen(
                        latitude: latitude,
                        longitude: longitude,
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else {
          return Center(child: Text('No results found'));
        }
      },
    );
  }


  Future<String> getPlaceName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks[0].name ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print('Error getting place name: $e');
      return 'Unknown';
    }
  }






}
