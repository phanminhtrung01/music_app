import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    Key? key,
  }) : super(key: key);

  final double _radiusBorder = 25.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.white12,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
                splashRadius: _radiusBorder,
                onPressed: () => {Navigator.of(context).pop()},
                icon: const Icon(Icons.arrow_back_sharp)),
            Expanded(
              child: TextField(
                autofocus: true,
                autocorrect: true,
                cursorColor: Colors.lightBlueAccent,
                cursorWidth: 3,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  isCollapsed: true,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15),
                  suffixIcon: IconButton(
                    onPressed: () => {},
                    splashRadius: _radiusBorder,
                    icon: const Icon(
                      Icons.search,
                    ),
                    color: Colors.white,
                  ),
                  focusColor: Colors.white,
                  enabled: true,
                  hintText: "Enter your song",
                  hintStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white12,
          child: const Text("12"),
        ),
      ),
    );
  }
}
