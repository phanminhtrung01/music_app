import 'package:equatable/equatable.dart';
import 'package:music_app/model/object_json/user_credential.dart';

class User extends Equatable {
  final String? id;
  final String email;
  final String? username;
  final String? name;
  final String password;
  final String avatar;
  final String? gender;
  final String? phoneNumber;
  final String? birthday;
  final UserCredential? userCredential;

  const User({
    required this.email,
    required this.password,
    required this.avatar,
    this.username,
    this.name,
    this.id,
    this.gender,
    this.phoneNumber,
    this.birthday,
    this.userCredential,
  });

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    String? password,
    String? avatar,
    String? gender,
    String? phoneNumber,
    String? birthday,
    UserCredential? userCredential,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthday: birthday ?? this.birthday,
      userCredential: userCredential ?? this.userCredential,
    );
  }

  factory User.userFromJson(Map<String, dynamic> json) {
    final dataUserCredential = json['userCredential'];
    UserCredential? userCredential;
    if (dataUserCredential != null) {
      userCredential = UserCredential.userFromJson(dataUserCredential);
    }

    return User(
      id: json['idUser'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      avatar: json['avatar'] ?? '',
      gender: json['gender'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      birthday: json['birthday'] ?? '',
      name: json['name'] ?? '',
      userCredential: userCredential,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'name': name,
        'password': password,
        'avatar': avatar,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'birthday': birthday,
        'userCredential': userCredential,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [name, username, phoneNumber, birthday, gender];
}
