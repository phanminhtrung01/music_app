import 'package:flutter/material.dart';

@override
Widget buildUserContain(BuildContext context) {
  return IntrinsicHeight(
    child: Column(
      children: <Widget>[
        Expanded(
          child: Container(
            // A fixed-height child.
            color: Colors.white12,
            alignment: Alignment.center,
            child: const Text('User'),
          ),
        ),
      ],
    ),
  );
}
