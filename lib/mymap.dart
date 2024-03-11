import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  final String user_id;
  MyMap(this.user_id);
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  List<LatLng> polylineCoordinates = [];

  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     "AIzaSyDSKHfDf_aJ05PQxaPwQw8N14V428ZUEZw", // Your Google Map Key
  //     PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //     PointLatLng(destination.latitude, destination.longitude),
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach(
  //           (PointLatLng point) => polylineCoordinates.add(
  //         LatLng(point.latitude, point.longitude),
  //       ),
  //     );
  //     setState(() {});
  //   }
  // }

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/location.png")
        .then(
          (icon) {
        sourceIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/location.png")
        .then(
          (icon) {
        destinationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, "assets/pin.png")
        .then(
          (icon) {
        currentLocationIcon = icon;
      },
    );
  }

  @override
  void initState() {
    // getPolyPoints();
    setCustomMarkerIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('location').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (_added) {
          mymap(snapshot);
        }
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return GoogleMap(
          mapType: MapType.normal,
          markers: {
            //for one icon
            Marker(
                position: LatLng(
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.user_id)['latitude'],
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.user_id)['longitude'],
                ),
                markerId: MarkerId('id'),
                icon: currentLocationIcon
            ),


            //for 3 icon
            // Marker(
            //   markerId: const MarkerId("currentLocation"),
            //   icon: currentLocationIcon,
            //     position: LatLng(
            //       snapshot.data!.docs.singleWhere(
            //               (element) => element.id == widget.user_id)['latitude'],
            //       snapshot.data!.docs.singleWhere(
            //               (element) => element.id == widget.user_id)['longitude'],
            //     )
            // ),
            // Marker(
            //   markerId: const MarkerId("source"),
            //   icon: sourceIcon,
            //     position: LatLng(
            //       snapshot.data!.docs.singleWhere(
            //               (element) => element.id == widget.user_id)['latitude'],
            //       snapshot.data!.docs.singleWhere(
            //               (element) => element.id == widget.user_id)['longitude'],
            //     )
            // ),
            // Marker(
            //   markerId: MarkerId("destination"),
            //   icon: destinationIcon,
            //     position: LatLng(
            //       snapshot.data!.docs.singleWhere(
            //               (element) => element.id == widget.user_id)['latitude'],
            //       snapshot.data!.docs.singleWhere(
            //               (element) => element.id == widget.user_id)['longitude'],
            //     )
            // ),
          },
          initialCameraPosition: CameraPosition(
              target: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.user_id)['latitude'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.user_id)['longitude'],
              ),
              zoom: 14.47),
          onMapCreated: (GoogleMapController controller) async {
            setState(() {
              _controller = controller;
              _added = true;
            });
          },
          polylines: {
            Polyline(
              polylineId: const PolylineId("route"),
              points: polylineCoordinates,
              color: const Color(0xFF7B61FF),
              width: 6,
            ),
          },

        );
      },
    ));
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['latitude'],
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == widget.user_id)['longitude'],
            ),
            zoom: 14.47)));
  }
}
