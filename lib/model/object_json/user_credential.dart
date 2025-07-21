class UserCredential {
  final int idCredential;
  final int? code;
  final String? timeVerify;
  final bool checkLogin;

  UserCredential({
    required this.idCredential,
    required this.checkLogin,
    this.code,
    this.timeVerify,
  });

  Map<String, dynamic> toJson() => {
        'idCredential': idCredential,
        'code': code,
        'timeVerify': timeVerify,
        'checkLogin': checkLogin,
      };

  factory UserCredential.userFromJson(Map<String, dynamic> json) {
    return UserCredential(
      idCredential: json['idCredential'],
      checkLogin: json['checkLogin'],
      code: json['code'],
      timeVerify: json['timeVerify'],
    );
  }
}
