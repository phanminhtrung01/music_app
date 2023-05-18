import 'package:flutter/material.dart';

class InfoUser extends StatefulWidget {
  const InfoUser({super.key});

  @override
  State<InfoUser> createState() => InfoUserState();
}

class InfoUserState extends State<InfoUser> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
      body: SingleChildScrollView(
        child: buildTest(context),
      ),
    );
  }

  Widget buildTest(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.black26,
      width: double.maxFinite,
      child: Column(
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 50,
            backgroundImage: const Image(
              image: NetworkImage(
                  "https://dntech.vn/uploads/details/2021/11/images/ai%20l%C3%A0%20g%C3%AC.jpg"),
            ).image,
          ),
          const SizedBox(height: 10),
          const Text(
            "PHAN MING TRUNG",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Text(
            "Bạn đang sử dụng gói nghe nhạc miễn phí, nâng cấp tài khoản để "
            "trải nghiệm âm nhạc tốt hơn",
            style: TextStyle(fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
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
                  fontWeight: FontWeight.w600,
                ),
              )),
          const SizedBox(height: 20),
          const SizedBox(
            width: double.maxFinite,
            child: Text(
              "Cá Nhân",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text(
                "Dịch vụ",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
                textAlign: TextAlign.left,
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
        ],
      ),
    );
  }
}
