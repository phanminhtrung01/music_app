import 'package:flutter/material.dart';
import 'package:music_app/model/radio_model.dart';

class RadioItem extends StatelessWidget {
  final RadioModel item;
  final double radius;

  const RadioItem({
    super.key,
    required this.item,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      // color: Colors.white12,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color:
                item.isSelected ? Colors.white.withAlpha(80) : Colors.white70,
            width: item.isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        ),
        color: item.isSelected ? Colors.white24 : Colors.white12,
      ),
      child: Text(
        item.nameString,
        style: TextStyle(
          color: item.isSelected ? Colors.white : Colors.black,
          // fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
    );
  }
}
