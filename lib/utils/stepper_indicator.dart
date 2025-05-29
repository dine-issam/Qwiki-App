import 'package:flutter/material.dart';
import 'package:delivery_app/constants/my_colors.dart';

class StepperIndicator extends StatelessWidget {
  final int step;

  const StepperIndicator({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: MyColors.primaryColor,
          radius: 12,
          child: Text(
            "1",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: 40,
          height: 2,
          color: MyColors.primaryColor,
        ),
        CircleAvatar(
          backgroundColor: step == 2 ? MyColors.primaryColor : Colors.grey,
          radius: 12,
          child: Text(
            "2",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
