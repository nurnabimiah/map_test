



import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location_test/main.dart';
import 'package:permission_handler/permission_handler.dart';

// class HomeController extends GetxController {
//   Rx<Position?> currentLocation = Rx<Position?>(null);
//
//   Future<void> getPossition() async {
//     var status = await Permission.location.request();
//     if (status == PermissionStatus.granted) {
//       Position datas = await _determinePosition();
//
//       print("Current Location: $datas");
//
//       currentLocation.value = datas;
//       GetAddressFromLatLong(datas);
//     }
//   }
//
//   Future<Position> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error('Location services are disabled.');
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }
//     return await Geolocator.getCurrentPosition();
//   }
//
//   Future<void> GetAddressFromLatLong(Position position) async {
//     List<Placemark> placemarks =
//     await placemarkFromCoordinates(position.latitude, position.longitude);
//     print(placemarks);
//     Placemark place = placemarks[0];
//     var Address = '${place.street},${place.subLocality}, ${place.thoroughfare},${place.locality}, ${place.postalCode}, ${place.country}';
//     print(Address);
//     var lat = position.latitude;
//     var lon = position.longitude;
//     Get.to(() => CurrentLocationMapScreen(
//       latitude: lat,
//       longitude: lon,
//       currentLocation: currentLocation.value,
//     ));
//   }
// }



class HomeController extends GetxController {
  Future<void> getPossition() async {
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      Position position = await _determinePosition();
      double lat = position.latitude;
      double lon = position.longitude;
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