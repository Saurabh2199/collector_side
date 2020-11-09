import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gms_collector/model/main_model.dart';
import 'package:gms_collector/service/data_service.dart';
import 'package:gms_collector/widgets/arrow_icon.dart';
import 'package:gms_collector/widgets/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_utils/google_maps_utils.dart';
import 'package:location/location.dart';
import 'package:screen/screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
  final box = GetStorage();
  Timer timer;
  List<Map<String, dynamic>> locations = [];
  int count = 0;
  double prevLat = 0, prevLong = 0;
  Uint8List curImg;

  distance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

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

  Future<void> createUserIcon() async {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    userIcon = await BitmapDescriptor.fromAssetImage(
      configuration,
      'assets/images/truck_marker.png',
    );
    markers.add(Marker(
      markerId: MarkerId("user"),
      position: userLocation,
      icon: BitmapDescriptor.fromBytes(curImg),
    ));
    return;
  }

  Future<void> updateUserLocation(double lat, double lon) async {
    double dist = distance(prevLat, prevLong, lat, lon);
    if (prevLat == 0 || (dist > 0.02)) {
      prevLat = lat;
      prevLong = lon;
      print(dist.toString());
      locations.add({
        "startTime": DateTime.now(),
        "latitude": lat,
        "longitude": lon,
      });
      markers.clear();

      markers.add(Marker(
        markerId: MarkerId("user"),
        position: userLocation,
        icon: BitmapDescriptor.fromBytes(curImg),
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
                double.parse(currentModel
                    .longitude[currentModel.latitude.indexOf(lat)]));
          }).toList();
          if (!PolyUtils.containsLocationPoly(
              Point(userLocation.latitude, userLocation.longitude),
              pointPolygon)) {
            isUploading = true;
            finishCollecting();
          }
        }
      }
    }
    //setState(() {});
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

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  collectData() async {
    await dataService.collectAllData(mainModels);
    // await createUserIcon();
    curImg = await getBytesFromAsset(
      "assets/images/current_marker.png",
      150,
    );
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

  uploadUserLocation() async {
    if (locations.length > 0) {
      DataService dataService = DataService();
      if (await dataService.insertLocations(locations)) {
        locations.clear();
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 120), (Timer t) => uploadUserLocation());
    Screen.keepOn(true);
    collectData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoad
          ? CustomLoading()
          : StreamBuilder<Position>(
              stream: Geolocator.getPositionStream(),
              builder: (context, snapshot) {
                if (snapshot.data == null || !snapshot.hasData) {
                  return CustomLoading();
                } else {
                  userLocation =
                      LatLng(snapshot.data.latitude, snapshot.data.longitude);
                  updateUserLocation(
                      snapshot.data.latitude, snapshot.data.longitude);
                  return GoogleMap(
                    markers: markers,
                    polygons: polygons,
                    initialCameraPosition: CameraPosition(
                      zoom: 17,
                      target: userLocation,
                    ),
                    zoomGesturesEnabled: true,
                    mapType: MapType.normal,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  );
                }
              },
            ),
    );
  }
}
