import 'package:flutter/material.dart';

class RecentSearch extends StatefulWidget {
  const RecentSearch({super.key});

  @override
  State<RecentSearch> createState() => _RecentSearchState();
}

class _RecentSearchState extends State<RecentSearch> {
  List<String> recentSearches = [
    'Lạc Lối',
    'Lạc Lòi',
    'Lạc Đường',
    'Lạc Trôi',
    'Hey K',
  ];

  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.colorScheme.background,
      appBar: AppBar(
        title: const Text('Recent Search'),
        backgroundColor: themeData.primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeData.buttonTheme.colorScheme!.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: recentSearches.map((search) {
                return InputChip(
                  label: Text(search),
                  tooltip: 'Hello',
                  avatar: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/R.jpg'),
                  ),
                  labelStyle: themeData.textTheme.bodySmall,
                  backgroundColor: themeData.focusColor,
                  deleteIcon: Icon(
                    Icons.clear,
                    size: 18,
                    color: themeData.buttonTheme.colorScheme!.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  onDeleted: () {
                    setState(() {
                      recentSearches.remove(search);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Add song more...'),
          ],
        ),
      ),
    );
  }
}
