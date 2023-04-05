import 'package:flutter/material.dart';

class CircleTrack extends StatefulWidget {
  final List<String> titles;

  const CircleTrack({
    Key? key,
    required this.titles,
  }) : super(key: key);

  @override
  State<CircleTrack> createState() => _CircleTrackState();
}

class _CircleTrackState extends State<CircleTrack> {
  List<String> get titles => widget.titles;

  @override
  Widget build(BuildContext context) {
    final double sizeWidthC = MediaQuery.sizeOf(context).width;
    const double sizeHeightC = 250;

    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
        bottom: 20,
      ),
      height: sizeHeightC,
      width: sizeWidthC,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[0],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            titles[1],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 10);
              },
              itemBuilder: (_, __) {
                return const Column(
                  children: [
                    SizedBox(height: 10),
                    Expanded(
                      child: SizedBox(
                        width: 150,
                        child: CircleAvatar(
                          backgroundImage: AssetImage("assets/images/R.jpg"),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        "Chung ta khong thuoc ve nhau",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
