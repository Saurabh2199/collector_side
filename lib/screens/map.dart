import 'dart:async';
import 'dart:convert';
import 'package:collector_side/model/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

/*const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 50;
const double CAMERA_BEARING = 30;*/
const LatLng SOURCE_LOCATION = LatLng(13.3409, 74.7421);
const LatLng DEST_LOCATION = LatLng(12.9141, 74.8560);
var lat=new List(40);
var lon=new List(40);
class GetData {
  Future<void> getData(List<Locations> _l) async {
    final response = await http.post(
        "https://xtoinfinity.tech/GCUdupi/user/php/mapMarker.php",
        body: {});
    final jsonRespone = json.decode(response.body);
    List location = jsonRespone['locations'].cast<Map<String, dynamic>>();
    location.map((e) {
      return _l.add(Locations(
        lat: e["lat"],
        lon: e["lon"],
        time: e["time"],
      ));
    }).toList();
    print(location[0]['lat']);
    for(int i=0;i<location.length;i++){
      lat[i]=location[i]['lat'];
      lon[i]=location[i]['lon'];
    }
    print(lat);
    return;
  }

  Future<void> addMarkers(
    Set<Marker> cm,
    List<Locations> loc,
    DateTime todayDate,
  ) async {
    List<Locations> todayList = [];

    loc.map((e) {
      DateTime _date = DateTime.parse(e.time);
      if (todayDate.day != _date.day) {
        todayList.add(e);
        cm.add(
          Marker(
            infoWindow: InfoWindow(title: DateFormat("H:m:s").format(_date)),
            markerId: MarkerId('1'),
            position: LatLng(
              double.parse(e.lat),
              double.parse(e.lon),
            ),
          ),
        );
      }
    }).toList();
    return;
  }
}

class MapSample extends StatefulWidget {
  static const routeName = '/map';

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> allMarkers = {};
  Set<Marker> _markers = Set<Marker>();
  GetData _getData = GetData();
  List<Locations> l = [];
  bool _isload = true;
  bool _isloc = false;
  String googleAPIKey = "AIzaSyD5MZNN_4fBFMknyklkwg-ZFPWY_1kc4O8";
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  LocationData currentLocation;
  LocationData destinationLocation;
  Location location;
  var pinPosition;

  @override
  void initState() {
    super.initState();
    location = new Location();
    /*location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
      //updatePinOnMap();
    });*/
    setSourceAndDestinationIcons();
    setInitialLocation();
    getData();
  }



  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/map_complete.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/map_incomplete.png');
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
    destinationLocation = LocationData.fromMap({
      "latitude": DEST_LOCATION.latitude,
      "longitude": DEST_LOCATION.longitude
    });
  }

  Future<void> getData() async {
    DateTime date = DateTime.now();
    allMarkers.clear();
    await _getData.getData(l);
    await _getData.addMarkers(allMarkers, l, date);
    print(lat);
    print(currentLocation.latitude);
    print(currentLocation.longitude);
    setState(() {
      _isload = false;
    });
    return;
  }

  void updatePinOnMap(double latitude,double longitude) async {
    CameraPosition cPosition = CameraPosition(
      zoom: 16,
      tilt: 50,
      bearing: 30,
      target: LatLng(latitude,longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));

      pinPosition = LatLng(latitude,longitude);
      //allMarkers.removeWhere((m) => m.markerId.value == 'sourcePin');
      allMarkers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: pinPosition, // updated position
          //icon: sourceIcon
      ));
  }

  update(){
    for(int i=0;i<lat.length;i++){
      if(double.parse(lat[i])==currentLocation.latitude && double.parse(lon[i])==currentLocation.longitude)return true;
      else return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: 16,
        tilt: 50,
        bearing: 30,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: 16,
          tilt: 50,
          bearing: 30);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Garbage Van Locations'),
        backgroundColor: Color(0xff00B198),
      ),
      body: (_isload)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<LocationData>(
        stream: location.onLocationChanged,
        builder: (context, snapshot) {
          allMarkers.removeWhere((m) => m.markerId.value == 'sourcePin');
          updatePinOnMap(snapshot.data.latitude,snapshot.data.longitude);
          return Stack(
            children: <Widget>[
              GoogleMap(
                markers: allMarkers,
                initialCameraPosition: initialCameraPosition,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 50,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text('Collected'),
                        RaisedButton(onPressed: (){},child: Text('YES'),),
                      ],
                    )
                ),
              ),
            ],
          );
        },
      ),/*Stack(
            children: <Widget>[
              GoogleMap(
                  markers: allMarkers,
                  initialCameraPosition: initialCameraPosition,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 50,
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text('Collected'),
                        RaisedButton(onPressed: (){},child: Text('YES'),),
                      ],
                    )
                  ),
              ),
            ],
          ),*/
    );
  }
}

