import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/roundedButton.dart';

class WelcomeScreen extends StatefulWidget {

  //static allows class wide variable and constant
  //thus we dont need to create object to acces it
  //thus saving our resources
  static String id='welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{

  AnimationController controller;
  Animation animation;
  @override
  void initState(){
    super.initState();
    controller=AnimationController(
      duration: Duration(seconds:1),
      //ticker will be current state object 
      //thus this
      vsync: this,
      //upperBound: 100.0,
    );
    
    animation =ColorTween(
      begin:Colors.blueGrey,
      end:Colors.white,
    ).animate(controller);
    controller.forward();

    controller.addListener(() {
      //from completly transparent to red
      setState(() {});
      //print(controller.value);
    });
    
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60.0,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  //'${controller.value.toInt()}%'
                  text:['Chat App'],
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              title:'Log In',
              color:Colors.lightBlueAccent,
              onPressed:(){
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              title:'Register',
              color:Colors.lightBlueAccent,
              onPressed:(){
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

