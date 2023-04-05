import 'package:flutter/material.dart';

class RectangleTrack extends StatefulWidget {
  final List<String> titles;

  const RectangleTrack({
    Key? key,
    required this.titles,
  }) : super(key: key);

  @override
  State<RectangleTrack> createState() => _RectangleTrackState();
}

class _RectangleTrackState extends State<RectangleTrack> {
  List<String> get _titles => widget.titles;

  @override
  Widget build(BuildContext context) {
    final double sizeWidthC = MediaQuery.sizeOf(context).width;
    const double sizeHeightC = 250;

    return Container(
      height: sizeHeightC,
      width: sizeWidthC,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_titles[0]),
          Text(_titles[1]),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
                itemCount: 6,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 5);
                },
                itemBuilder: (_, __) {
                  return Stack(
                    children: [
                      Container(
                        width: sizeWidthC - 20,
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8)),
                        child: Container(
                          height: double.maxFinite,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  color: Colors.transparent,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              //const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Chung ta khong thuoc ve nhau dsfdsf sdfsdf sdfdsf  dfdsfdsfs",
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w600),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "Son Tung-MTP",
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
          )
        ],
      ),
    );
  }
}
