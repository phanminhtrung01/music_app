import 'package:flutter/material.dart';

class IntroduceMusicScreen extends StatelessWidget {
  const IntroduceMusicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.black54,
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          children: [

            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxWidth * 9 / 10;
                final buttonWidth = containerWidth * 8 / 10;

                return Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.only(top: 10.0),
                  width: containerWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.deepPurpleAccent,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Music App',
                              style: TextStyle(
                                fontSize: 25.0,
                                color: Colors.deepPurpleAccent[100],
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Plus',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.circle, color: Colors.white, size: 10),
                        title: Text('Không Quảng Cáo', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'nghe nhạc thoải thích không có quản cáo',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.circle, color: Colors.white, size: 10),
                        title: Text('Chất lượng cao', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Nghe và tải nhạc chất lượng Lossless',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.circle, color: Colors.white, size: 10),
                        title: Text('Trải Nghiệm', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Tính năng nghe nhạc nâng cao',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        height: 40,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle button press
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepPurpleAccent[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Mua Gói (20.000đ)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final containerWidth = constraints.maxWidth * 9 / 10;
                final buttonWidth = containerWidth * 8 / 10;

                return Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  padding: const EdgeInsets.only(top: 10.0),
                  width: containerWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orangeAccent[200],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Music App',
                              style: TextStyle(
                                fontSize: 25.0,
                                color: Colors.orange,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Premium',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.circle, color: Colors.white, size: 10),
                        title: Text('Kho nhạc độc quyền', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Nghe các bài hát độc quyền của music app',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.circle, color: Colors.white, size: 10),
                        title: Text('Không Quảng Cáo', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'nghe nhạc thoải thích không có quản cáo',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.circle, color: Colors.white, size: 10),
                        title: Text('Chất lượng cao', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Nghe và tải nhạc chất lượng Lossless',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.circle, color: Colors.white, size: 10),
                        title: Text('Trải Nghiệm', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Tính năng nghe nhạc nâng cao',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        height: 40,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle button press
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.amberAccent[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Mua Gói (49.000đ)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
