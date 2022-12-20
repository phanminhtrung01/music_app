import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_app/constants/constant.dart';
import 'package:music_app/pages/login/login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late bool _checkEmailCompleted;
  late bool _checkAuthCompleted;
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyAuth = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkEmailCompleted = false;
    _checkAuthCompleted = false;
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
                onChanged: (_) {
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

  Widget _buildAuthTF() {
    return Form(
      key: _formKeyAuth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Verify',
            style: kLabelStyle,
          ),
          const SizedBox(height: 10.0),
          Container(
            height: 60.0,
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            child: Padding(
              padding: !_checkAuthCompleted
                  ? const EdgeInsets.all(10.0)
                  : EdgeInsets.zero,
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  setState(() {
                    _formKeyAuth.currentState!.validate()
                        ? _checkAuthCompleted = true
                        : _checkAuthCompleted = false;
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
                    Icons.verified,
                    color: Colors.white,
                  ),
                  hintText: 'Enter your key',
                  hintStyle: kHintTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBtnSent() {
    return Container(
      height: 88,
      padding: const EdgeInsets.only(top: 33.0),
      margin: const EdgeInsets.only(right: 10.0),
      child: ElevatedButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(50, 50)),
          // padding: MaterialStateProperty.all(const EdgeInsets.only(top: 20)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: Colors.white12))),
          backgroundColor: MaterialStateProperty.all(Colors.black),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sending code')),
          );
        },
        child: Align(
          child: Container(
            padding: const EdgeInsets.only(left: 7.0),
            child: const Text("Sent code"),
          ),
        ),
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
          debugPrint('Submit Button Pressed'),
          _formKeyEmail.currentState!.validate(),
          _formKeyAuth.currentState!.validate(),
          if (_checkEmailCompleted && _checkAuthCompleted)
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

  Widget _buildReLoginBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'You remember the account. ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
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
              'Re-login!',
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
                  horizontal: 20.0,
                  vertical: 80.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Forgot Password',
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
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: _buildBtnSent(),
                          ),
                          Flexible(
                            flex: 3,
                            child: _buildAuthTF(),
                          ),
                        ],
                      ),
                      _buildSubmitBtn(),
                      const SizedBox(height: 30.0),
                      _buildReLoginBtn(),
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
