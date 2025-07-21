import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/constants/constant.dart';
import 'package:music_app/model/object_json/user.dart';
import 'package:music_app/pages/login/login.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/user_manager.dart';

class SignUpPage extends StatefulWidget {
  final UserManager userManager;
  final AppManager appManager;

  const SignUpPage({
    Key? key,
    required this.userManager,
    required this.appManager,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late bool _passwordVisible;
  late bool _checkEmailCompleted;
  late bool _confirmPasswordVisible;
  late bool _submitPressed;
  late bool _checkConfirmPwCompleted;
  late bool _checkPwCompleted;
  late bool _isEmailValid;
  late bool _showEmailError;
  late String _selectedGender = 'Male';

  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  final _formKeyConfirmPassword = GlobalKey<FormState>();
  final _formKeyGender = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _geneController = TextEditingController();

  UserManager get _userManager => widget.userManager;

  AppManager get _appManager => widget.appManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _passwordVisible = false;
    _checkEmailCompleted = false;
    _confirmPasswordVisible = false;
    _checkConfirmPwCompleted = false;
    _submitPressed = false;
    _checkPwCompleted = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _buildEmailTF() {
    return Form(
      key: _formKeyEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Email',
            style: kLabelStyle,
          ),
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {
                    _checkEmailCompleted = _validateEmail(value);
                  });
                },
                validator: (value) {
                  if (!_submitPressed) {
                    return null; // Do not show error message when not pressed submit
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!_validateEmail(value)) {
                    return 'Please enter a valid Gmail address';
                  }
                  return null;
                },
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.white,
                  ),
                  hintText: 'Enter your Email',
                  hintStyle: kHintTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@gmail\.com$');
    return emailRegExp.hasMatch(email);
  }

  bool _validatePassword(String password) {
    if (password.length < 8) {
      return false;
    }

    return true;
  }

  Widget _buildPasswordTF() {
    return Form(
      key: _formKeyPassword,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Password",
            style: kLabelStyle,
          ),
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: Padding(
              padding: !_submitPressed
                  ? const EdgeInsets.all(10.0)
                  : EdgeInsets.zero,
              child: TextFormField(
                controller: _passwordController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {
                    _checkPwCompleted = _validatePassword(value);
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  if (!_validatePassword(value)) {
                    return 'Please enter a valid password';
                  }
                  return null;
                },
                obscureText: !_passwordVisible,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 14.0),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  hintText: 'Enter your Password',
                  hintStyle: kHintTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordTF() {
    return Form(
      key: _formKeyConfirmPassword,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Confirm Password",
            style: kLabelStyle,
          ),
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  setState(() {
                    _checkConfirmPwCompleted = _validateConfirmPassword(value);
                  });
                },
                validator: (value) {
                  if (!_submitPressed) {
                    return null; // Do not show error message when not pressed submit
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password again';
                  }
                  if (!_validateConfirmPassword(value)) {
                    return 'The passwords do not match';
                  }
                  return null;
                },
                obscureText: !_confirmPasswordVisible,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(top: 14.0),
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                  hintText: 'Confirm your Password',
                  hintStyle: kHintTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateConfirmPassword(String value) {
    return value == _passwordController.text;
  }

  Widget _buildGenderDropdown() {
    List<String> genders = ['Male', 'Female'];

    return Form(
      key: _formKeyGender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Gender',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                items: genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 14.0),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  icon: Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                  ),
                  fillColor: Colors.black,
                  filled: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'You remember the account. ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('$LoginScreen');
            },
            splashColor: Colors.blue,
            child: const Text(
              'Login!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _submitPressed = true;
          });

          if (_formKeyEmail.currentState!.validate() &&
              _formKeyPassword.currentState!.validate() &&
              _formKeyConfirmPassword.currentState!.validate() &&
              _formKeyGender.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registering')),
            );
            User user = User(
              email: _emailController.text,
              password: _passwordController.text,
              gender: _selectedGender,
              avatar: '',
            );
            _userManager.registerUser(user).then((value) {
              _appManager.notifierBottom(
                context,
                "Register user successful!. I'll back login page",
              );
              Navigator.pop(context);
            }).catchError((error) {
              _appManager.notifierBottom(
                context,
                'Error: $error',
              );
            });
          } else {
            _appManager.notifierBottom(
              context,
              'Please fix the errors in the form',
            );
          }
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white12),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          ),
        ),
        child: const Text(
          'SIGN UP',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black87,
                      Colors.black54,
                      Colors.black87,
                      Colors.black45
                    ],
                    stops: [0.1, 0.4, 0.7, 0.9],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 80.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'OpenSans',
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      _buildEmailTF(),
                      const SizedBox(
                        height: 30.0,
                      ),
                      _buildPasswordTF(),
                      const SizedBox(
                        height: 30.0,
                      ),
                      _buildConfirmPasswordTF(),
                      const SizedBox(
                        height: 30.0,
                      ),
                      _buildGenderDropdown(),
                      _buildSubmitBtn(),
                      _buildSignInBtn(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
