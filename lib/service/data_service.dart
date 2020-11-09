import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gms_collector/model/main_model.dart';
import 'package:http/http.dart' as http;

class DataService {
  Future<void> collectAllData(
    List<MainModel> mainModels,
  ) async {
    final response = await http.get(
        "https://xtoinfinity.tech/GCUdupi/collector/gms_php/getAllData.php");
    final jsonResponse = json.decode(response.body);
    final allData = jsonResponse['data'];
    print(allData);
    allData.map((e) => mainModels.add(MainModel.fromJson(e))).toList();
    return;
  }

  Future<void> addCollection(MainModel mainModel) async {
    DateTime startTime = DateTime.now();
    final response = await http.post(
        "https://xtoinfinity.tech/GCUdupi/collector/gms_php/insertCollection.php",
        body: {
          "wardId": mainModel.wardId,
          "vehicleId": "1",
          "startTime": startTime.toString(),
          "endTime": startTime.toString(),
        });
    mainModel.vehicleId = "1";
    mainModel.startTime = startTime;
    mainModel.endTime = startTime;
    mainModel.collectionId = response.body;
    await FirebaseFirestore.instance.collection("notification").add({
      "title": "Garbage truck has entered your zone",
      "body": "Please keep your trash outside",
      "to": "${mainModel.wardId}"
    });
    return;
  }

  Future<void> updateCollection(MainModel mainModel) async {
    print(mainModel.collectionId);
    DateTime endTime = DateTime.now();
    final response = await http.post(
        "https://xtoinfinity.tech/GCUdupi/collector/gms_php/updateCollection.php",
        body: {
          "collectionId": mainModel.collectionId,
          "endTime": endTime.toString(),
        });
    mainModel.endTime = endTime;
    await FirebaseFirestore.instance.collection("notification").add({
      "title": "Garbage has been collected",
      "body": "Click here to report if your garbage was not collected",
      "to": "${mainModel.wardId}"
    });
    return;
  }

  Future<bool> insertLocations(List<Map> locations) async {
    try {
      final response = await http.post(
          "https://xtoinfinity.tech/GCUdupi/collector/gms_php/insertLocation.php",
          body: {
            "latitude": JsonEncoder().convert(locations.map((e) {
              return e['latitude'].toString();
            }).toList()),
            "longitude": JsonEncoder().convert(locations.map((e) {
              return e['longitude'].toString();
            }).toList()),
            "startTime": JsonEncoder().convert(locations.map((e) {
              return e['startTime'].toString();
            }).toList()),
          });
    } catch (e) {
      return false;
    }
    return true;
  }
}
