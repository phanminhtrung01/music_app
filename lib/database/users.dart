import 'package:on_audio_query/on_audio_query.dart';

class Users {
  final int? idUser;
  final String userName;
  final String password;
  final int age;
  final bool gender;
  final int reputation;
  final DeviceModel deviceModel;

  Users({
    this.idUser,
    required this.userName,
    required this.password,
    required this.age,
    required this.gender,
    required this.reputation,
    required this.deviceModel,
  });

  @override
  String toString() {
    // TODO: implement toString
    return "User: {UserName: $userName; Password: $password; Age: $age; "
        "Gender: $gender; Reputation: $reputation; DeviceModel: $deviceModel}";
  }
}
