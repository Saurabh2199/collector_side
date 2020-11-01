import 'package:flutter/material.dart';

class ArrowIcon extends StatefulWidget {
  final IconData iconData;
  final double lat;
  final double long;
  final Function updateLocation;

  ArrowIcon({this.iconData, this.lat, this.long, this.updateLocation});

  @override
  _ArrowIconState createState() => _ArrowIconState();
}

class _ArrowIconState extends State<ArrowIcon> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      color: Colors.teal,
      child: IconButton(
        icon: Icon(
          widget.iconData,
          color: Colors.white,
        ),
        onPressed: () => widget.updateLocation(widget.lat, widget.long),
      ),
    );
  }
}
