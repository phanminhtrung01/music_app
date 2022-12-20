import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/constants/constant.dart';
import 'package:music_app/pages/login/login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late bool _passwordVisible;
  late bool _checkEmailCompleted;
  late bool _checkPwCompleted;
  late bool _checkCfPwCompleted;
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();
  final _formKeyConfirmPassword = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _passwordVisible = false;
    _checkEmailCompleted = false;
    _checkPwCompleted = false;
    _checkCfPwCompleted = false;
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
              padding: !_checkEmailCompleted
                  ? const EdgeInsets.all(10.0)
                  : EdgeInsets.zero,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (_) => {
                  setState(() {
                    _formKeyEmail.currentState!.validate()
                        ? _checkEmailCompleted = true
                        : _checkEmailCompleted = false;
                  }),
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
            "Password",
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
                keyboardType: TextInputType.text,
                obscureText: !_passwordVisible,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (_) {
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
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your password',
                  hintStyle: kHintTextStyle,
                  contentPadding: const EdgeInsets.only(top: 14.0),
                  prefixIcon: const Icon(
                    Icons.password,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCfPasswordTF() {
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
              padding: !_checkCfPwCompleted
                  ? const EdgeInsets.all(10.0)
                  : EdgeInsets.zero,
              child: TextFormField(
                keyboardType: TextInputType.text,
                obscureText: !_passwordVisible,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (_) {
                  setState(() {
                    _formKeyConfirmPassword.currentState!.validate()
                        ? _checkCfPwCompleted = true
                        : _checkCfPwCompleted = false;
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your password',
                  hintStyle: kHintTextStyle,
                  contentPadding: const EdgeInsets.only(top: 14.0),
                  prefixIcon: const Icon(
                    Icons.password,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white12)),
        onPressed: () => {
          _formKeyEmail.currentState!.validate(),
          _formKeyPassword.currentState!.validate(),
          _formKeyConfirmPassword.currentState!.validate(),
          if (_checkEmailCompleted && _checkPwCompleted && _checkCfPwCompleted)
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              )
            }
        },
        child: const Text(
          'SUBMIT',
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
                      _buildCfPasswordTF(),
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
