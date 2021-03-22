import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:gms_collector/data/custom_constants.dart';
import 'package:gms_collector/model/main_model.dart';
import 'package:http/http.dart' as http;

class DataService {
  Future<void> collectAllData(
    List<MainModel> mainModels,
  ) async {
    final response = await http.get("${CustomConstants.url}getAllData.php");
    final jsonResponse = json.decode(response.body);
    final allData = jsonResponse['data'];
    print(allData);
    allData.map((e) => mainModels.add(MainModel.fromJson(e))).toList();
    return;
  }

  Future<void> addCollection(MainModel mainModel) async {
    DateTime startTime = DateTime.now();
    Dio dio = new Dio();

    try {
      Response response =
          await dio.post("${CustomConstants.url}collection", data: {
        "sector_id": "1",
        "collector_id": "1",
        "vehicle_id": "1",
        "start_time": startTime.toString(),
        "end_time": startTime.toString()
      });
      if (response.data['success']) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> updateCollection(MainModel mainModel) async {
    DateTime endTime = DateTime.now();
    Dio dio = new Dio();

    try {
      Response response = await dio.patch("${CustomConstants.url}collection",
          data: {"collection_id": mainModel.collectionId, "end_time": endTime});
      if (response.data['success']) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> insertLocations(List<Map> locations) async {
    Dio dio = new Dio();

    try {
      Response response =
          await dio.post("${CustomConstants.url}addtrucklocations", data: {
        "latitude": JsonEncoder().convert(locations.map((e) {
          return e['latitude'].toString();
        }).toList()),
        "longitude": JsonEncoder().convert(locations.map((e) {
          return e['longitude'].toString();
        }).toList()),
        "startTime": JsonEncoder().convert(locations.map((e) {
          return e['startTime'].toString();
        }).toList()),
        "speed": JsonEncoder().convert(locations.map((e) {
          return e['speed'].toString();
        }).toList()),
      });
      if (response.data['success']) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
