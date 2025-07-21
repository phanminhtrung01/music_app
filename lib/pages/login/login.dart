import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/constants/constant.dart';
import 'package:music_app/pages/login/forgot_pw.dart';
import 'package:music_app/pages/sign_up/sign_up.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/auth_firebase.dart';
import 'package:music_app/repository/user_manager.dart';

class LoginScreen extends StatefulWidget {
  final UserManager userManager;
  final AppManager appManager;

  const LoginScreen({
    super.key,
    required this.userManager,
    required this.appManager,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _rememberMe;
  late bool _passwordVisible;
  late bool _checkEmailCompleted;
  late bool _checkPwCompleted;
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  late ValueNotifier<String> stringEmailNotifier;
  late ValueNotifier<String> stringPasswordNotifier;
  AuthFirebase authFirebase = AuthFirebase();

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _passwordVisible = false;
    _rememberMe = false;
    _checkEmailCompleted = false;
    _checkPwCompleted = false;
    stringEmailNotifier = ValueNotifier<String>("");
    stringPasswordNotifier = ValueNotifier<String>("");
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
            height: 60.0,
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            child: Padding(
              padding: !_checkEmailCompleted
                  ? const EdgeInsets.all(10.0)
                  : EdgeInsets.zero,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  stringEmailNotifier.value = value;
                  setState(() {
                    _formKeyEmail.currentState!.validate()
                        ? _checkEmailCompleted = true
                        : _checkEmailCompleted = false;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
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

  Widget _buildPasswordTF() {
    return Form(
      key: _formKeyPassword,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Password',
            style: kLabelStyle,
          ),
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: Padding(
              padding: !_checkPwCompleted
                  ? const EdgeInsets.all(10.0)
                  : EdgeInsets.zero,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: !_passwordVisible,
                onChanged: (value) {
                  stringPasswordNotifier.value = value;
                  setState(() {
                    _formKeyPassword.currentState!.validate()
                        ? _checkPwCompleted = true
                        : _checkPwCompleted = false;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                // controller: _passwordEditController,
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
                      // Based on passwordVisible state choose the icon
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
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

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => {
          debugPrint('Forgot Password Button Pressed'),
          Navigator.of(context).pushNamed('$ForgotPassword')
        },
        child: const Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return SizedBox(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
          ),
          const Text(
            'Remember me',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.white12,
          ),
        ),
        onPressed: () {
          _formKeyEmail.currentState!.validate();
          _formKeyPassword.currentState!.validate();
          if (_checkEmailCompleted && _checkPwCompleted) {
            String username = stringEmailNotifier.value;
            String password = stringPasswordNotifier.value;
            _userManager.login(context, username, password);
          }
        },
        child: const Text(
          'LOGIN',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildSignupBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Don\'t have an Account? ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('$SignUpPage');
          },
          splashColor: Colors.blue,
          child: const Text(
            'Sign Up!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _appManager.themeModeNotifier,
      builder: (_, valueMode, __) {
        return Scaffold(
          appBar: AppBar(),
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: valueMode
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
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
                      horizontal: 40.0,
                      vertical: 80.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'OpenSans',
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          _buildEmailTF(),
                          const SizedBox(height: 30.0),
                          _buildPasswordTF(),
                          _buildForgotPasswordBtn(),
                          _buildRememberMeCheckbox(),
                          _buildLoginBtn(),
                          _buildSignupBtn(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
