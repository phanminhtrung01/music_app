import 'package:flutter/material.dart';

class InfoUser1 extends StatefulWidget {
  const InfoUser1({super.key});

  @override
  State<InfoUser1> createState() => InfoUser1State();
}

class InfoUser1State extends State<InfoUser1> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.transparent,
            title: const Text('Tài Khoản cá nhân'),
          ),
          body: buildtest(context)),
      title: "Tài Khoản cá nhân",
      debugShowCheckedModeBanner: false,
    );
  }

  Widget buildtest(BuildContext context) {
    // TODO: implement build

    return IntrinsicHeight(
        child: Container(
      color: Colors.black26,
      height: double.maxFinite,
      width: double.maxFinite,
      child: Column(children: [
        Container(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 20.0,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: const Image(
                image: NetworkImage(
                    "https://dntech.vn/uploads/details/2021/11/images/ai%20l%C3%A0%20g%C3%AC.jpg"),
              ).image,
            )),
        Container(
            padding: const EdgeInsets.only(
              top: 20.0,
              bottom: 10.0,
            ),
            child: const Text(
              "PHAN MING TRUNG",
              style: TextStyle(fontWeight: FontWeight.w600),
            )),
        Container(
          padding: const EdgeInsets.only(
            bottom: 20.0,
            left: 20,
            right: 20,
          ),
          child: const Text(
            "Bạn đang sử dụng gói nghe nhạc miễn phí, nâng cấp tài khoản để "
            "trải nghiệm âm nhạc tốt hơn",
            style: TextStyle(fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(
            bottom: 10.0,
            left: 10,
            right: 10,
          ),
          child: ElevatedButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.only(
                    top: 10.0, bottom: 10.0, right: 10, left: 10)),
                backgroundColor: MaterialStateProperty.all(Colors.amber),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Colors.white70,
                          width: 2,
                        ))),
              ),
              onPressed: () => {},
              child: const Text(
                "Nâng Cấp Tài khoản",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              )),
        ),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 10.0,
            left: 10,
            right: 10,
          ),
          child: const Text(
            "Cá Nhân",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // canh giữa các phần tử trong cột
            children: [
              InkWell(
                onTap: () => {},
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.supervised_user_circle,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.navigate_next,
                    size: 30,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Danh Sách Quan Tâm',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  enabled: true,
                ),
              ),
              InkWell(
                onTap: () => {},
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.block,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.navigate_next,
                    size: 30,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Danh Sách Chăn',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  enabled: true,
                ),
              ),
              InkWell(
                onTap: () => {},
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.hide_image_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.navigate_next,
                    size: 30,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Danh Sách Tạm Ẩn',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  enabled: true,
                ),
              ),
              const Divider(
                height: 10,
                thickness: 2,
                indent: 20,
                endIndent: 20,
                color: Colors.white70,
              ),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 10.0,
                  left: 10,
                  right: 10,
                ),
                child: const Text(
                  "Dịch vụ",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
                  textAlign: TextAlign.left,
                ),
              ),
              InkWell(
                onTap: () => {},
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.four_g_mobiledata_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.navigate_next,
                    size: 30,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Tiết Kiệm 3g/4g Khi truy cập',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  enabled: true,
                ),
              ),
              InkWell(
                onTap: () => {},
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.document_scanner,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  trailing: Icon(
                    Icons.navigate_next,
                    size: 30,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Nhập Code Vip',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  enabled: true,
                ),
              ),
            ],
          ),
        ),
      ]),
    ));
    throw UnimplementedError();
  }
}
