import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';

class ClinicPicker extends StatefulWidget {
  const ClinicPicker({super.key});

  @override
  State<ClinicPicker> createState() => _ClinicPickerState();
}

class _ClinicPickerState extends State<ClinicPicker> {
  GoogleMapController? mapController;
  LatLng? currentPosition;
  final Set<Marker> markers = {};

  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyDR9b3MPhOpE1T4OMfwksOxP-VCCcj_CfM');

  @override
  void initState() {
    super.initState();
    _determinePositionAndLoadClinics();
  }

  Future<void> _determinePositionAndLoadClinics() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    print('Location permission: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location permissions are permanently denied")),
      );
      return;
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = LatLng(position.latitude, position.longitude);
    print('Current position: $currentPosition');

    await _searchNearbyClinics();

    setState(() {});
  }

  Future<void> _searchNearbyClinics() async {
    if (currentPosition == null) return;

    final result = await places.searchNearbyWithRadius(
      Location(lat: currentPosition!.latitude, lng: currentPosition!.longitude),
      5000,
      type: "health",
      keyword: "clinic",
    );

    if (result.status == "OK") {
      markers.clear();
      for (var place in result.results) {
        if (place.types != null &&
            (place.types!.contains('clinic') ||
                place.types!.contains('doctor') ||
                place.types!.contains('health'))) {
          markers.add(Marker(
            markerId: MarkerId(place.placeId),
            position: LatLng(
                place.geometry!.location.lat, place.geometry!.location.lng),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.vicinity,
              onTap: () {
                Navigator.pop(context, "${place.name}, ${place.vicinity}");
              },
            ),
          ));
        }
      }
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nearby search error: ${result.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Nearby Clinic'),
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentPosition!,
                zoom: 14,
              ),
              markers: markers,
              onMapCreated: (controller) {
                mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
