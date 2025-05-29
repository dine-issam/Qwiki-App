import 'package:delivery_app/constants/my_colors.dart';
import 'package:delivery_app/utils/my_history_card.dart';
import 'package:delivery_app/utils/my_order_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isOrdering = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // 👈 go back to HomeScreen properly
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: MyColors.whiteColor,
          ),
        ),
        backgroundColor: MyColors.primaryColor,
        toolbarHeight: 70.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: Text(
          "My Orders",
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isOrdering = true;
                  });
                },
                child: Text(
                  "ORDERING",
                  style: GoogleFonts.nunitoSans(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isOrdering
                          ? MyColors.primaryColor
                          : MyColors.blackColor,
                      decoration: TextDecoration.underline,
                      decorationColor: isOrdering
                          ? MyColors.primaryColor
                          : MyColors.blackColor,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isOrdering = false;
                  });
                },
                child: Text(
                  "HISTORY",
                  style: GoogleFonts.nunitoSans(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: !isOrdering
                          ? MyColors.primaryColor
                          : MyColors.blackColor,
                      decoration: TextDecoration.underline,
                      decorationColor: !isOrdering
                          ? MyColors.primaryColor
                          : MyColors.blackColor,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: isOrdering
                  ? List.generate(5, (index) => MyOrderCard())
                  : List.generate(5, (index) => MyHistoryCard()),
            ),
          ),
        ],
      ),
    );
  }
}
