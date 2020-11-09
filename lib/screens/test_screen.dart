import 'dart:async';
import 'dart:math';

import 'package:gms_collector/model/main_model.dart';
import 'package:gms_collector/service/data_service.dart';
import 'package:gms_collector/widgets/arrow_icon.dart';
import 'package:gms_collector/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_utils/google_maps_utils.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Completer<GoogleMapController> _controller = Completer();
  bool isLoad = true;
  DataService dataService = DataService();
  List<MainModel> mainModels = [];
  LatLng userLocation = LatLng(13.333767, 74.743146);
  BitmapDescriptor userIcon;
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  MainModel currentModel;
  bool isUploading = false;

  startCollecting() async {
    await dataService.addCollection(currentModel);
    print(currentModel.collectionId);
    polygons.removeWhere(
        (polygon) => polygon.polygonId.value == currentModel.wardId);
    polygons.add(Polygon(
        polygonId: PolygonId(currentModel.wardId),
        fillColor: Colors.yellow.withOpacity(0.15),
        strokeWidth: 1,
        points: currentModel.latitude.map((lat) {
          return LatLng(
              double.parse(lat),
              double.parse(
                  currentModel.longitude[currentModel.latitude.indexOf(lat)]));
        }).toList()));
    isUploading = false;
    setState(() {});
  }

  finishCollecting() async {
    await dataService.updateCollection(currentModel);
    polygons.removeWhere(
        (polygon) => polygon.polygonId.value == currentModel.wardId);
    polygons.add(Polygon(
        polygonId: PolygonId(currentModel.wardId),
        fillColor: Colors.green.withOpacity(0.15),
        strokeWidth: 1,
        points: currentModel.latitude.map((lat) {
          return LatLng(
              double.parse(lat),
              double.parse(
                  currentModel.longitude[currentModel.latitude.indexOf(lat)]));
        }).toList()));
    currentModel = null;

    isUploading = false;
    setState(() {});
  }

  createUserIcon() async {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    userIcon = await BitmapDescriptor.fromAssetImage(
        configuration, 'assets/images/userLocation.png');
    markers.add(Marker(
      markerId: MarkerId("user"),
      position: userLocation,
      icon: userIcon,
      anchor: Offset(0.5, 0.5),
    ));
    isLoad = false;
    setState(() {});
  }

  updateUserLocation(double lat, double lon) async {
    markers.clear();
    userLocation =
        LatLng(userLocation.latitude + lat, userLocation.longitude + lon);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: userLocation, zoom: 18)));
    markers.add(Marker(
      markerId: MarkerId("user"),
      position: userLocation,
      icon: userIcon,
      anchor: Offset(0.5, 0.5),
    ));
    if (!isUploading) {
      if (currentModel == null) {
        mainModels.map((mainModel) {
          if (mainModel.startTime == null) {
            List<Point> pointPolygon = mainModel.latitude.map((lat) {
              return Point(
                  double.parse(lat),
                  double.parse(
                      mainModel.longitude[mainModel.latitude.indexOf(lat)]));
            }).toList();
            if (PolyUtils.containsLocationPoly(
                Point(userLocation.latitude, userLocation.longitude),
                pointPolygon)) {
              currentModel = mainModel;
              isUploading = true;
              startCollecting();
            }
          }
        }).toList();
      } else {
        List<Point> pointPolygon = currentModel.latitude.map((lat) {
          return Point(
              double.parse(lat),
              double.parse(
                  currentModel.longitude[currentModel.latitude.indexOf(lat)]));
        }).toList();
        if (!PolyUtils.containsLocationPoly(
            Point(userLocation.latitude, userLocation.longitude),
            pointPolygon)) {
          isUploading = true;
          finishCollecting();
        }
      }
    }
    setState(() {});
  }

  addPolygon() {
    mainModels.map((mm) {
      int code = 0;
      if (mm.startTime != null) {
        if (mm.startTime == mm.endTime) {
          code = 1;
        } else {
          code = 2;
        }
      }
      polygons.add(Polygon(
          polygonId: PolygonId(mm.wardId),
          fillColor: code == 0
              ? Colors.red.withOpacity(0.15)
              : code == 1
                  ? Colors.yellow.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
          strokeWidth: 1,
          points: mm.latitude.map((lat) {
            return LatLng(double.parse(lat),
                double.parse(mm.longitude[mm.latitude.indexOf(lat)]));
          }).toList()));
    }).toList();
  }

  collectData() async {
    await dataService.collectAllData(mainModels);
    createUserIcon();
    addPolygon();
    mainModels.map((mainModel) {
      if (mainModel.startTime != null &&
          mainModel.startTime == mainModel.endTime) {
        currentModel = mainModel;
      }
    }).toList();
    isLoad = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    collectData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoad
          ? CustomLoading()
          : Stack(
              children: <Widget>[
                GoogleMap(
                  markers: markers,
                  polygons: polygons,
                  initialCameraPosition: CameraPosition(
                      zoom: 18, tilt: 0, bearing: 0, target: userLocation),
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ArrowIcon(
                            iconData: Icons.keyboard_arrow_left,
                            lat: 0,
                            long: -0.0001,
                            updateLocation: updateUserLocation,
                          ),
                          ArrowIcon(
                            iconData: Icons.keyboard_arrow_down,
                            lat: -0.0001,
                            long: 0,
                            updateLocation: updateUserLocation,
                          ),
                          ArrowIcon(
                            iconData: Icons.keyboard_arrow_up,
                            lat: 0.0001,
                            long: 0,
                            updateLocation: updateUserLocation,
                          ),
                          ArrowIcon(
                            iconData: Icons.keyboard_arrow_right,
                            lat: 0,
                            long: 0.0001,
                            updateLocation: updateUserLocation,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
