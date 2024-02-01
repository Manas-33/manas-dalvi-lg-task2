import 'package:flutter/material.dart';

class ConnectionFlag extends StatelessWidget {
  ConnectionFlag({required this.status});
  final bool status;

  @override
  Widget build(BuildContext context) {
    Color color = status ? Colors.green : Colors.red;
    String label = status ? 'CONNECTED' : 'DISCONNECTED';
    return Container(
      padding: EdgeInsets.only(left: 20),
      height: 50,
      width: 200,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.withOpacity(.3)
              // Colors.blue
            ],
          ),
          borderRadius: BorderRadius.circular(50)),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            color: color,
          ),
          SizedBox(
            width: 5.0,
          ),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
  }
}