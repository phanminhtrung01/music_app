import 'package:flutter/material.dart';

Widget buildAlContain(BuildContext context) {
  return IntrinsicHeight(
    child: Column(
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.white12,
            alignment: Alignment.center,
            child: const Text('Al'),
          ),
        ),
      ],
    ),
  );
}
