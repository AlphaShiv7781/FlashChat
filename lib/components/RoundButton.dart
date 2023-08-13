import 'package:flutter/material.dart';
class RoundedButton extends StatelessWidget {
  RoundedButton({required this.title,required this.colour,required this.onPress});
  final String title;
  final Function onPress;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: colour,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: (){
            onPress!();
          },
          minWidth: 200.0,
          height: 42.0,
          child:  Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
