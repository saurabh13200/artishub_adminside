import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:grocery_admin_panel/services/utils.dart';
import 'package:grocery_admin_panel/widgets/text_widget.dart';

class OrdersWidget extends StatefulWidget {
  const OrdersWidget({
    super.key,
    required this.price,
    required this.totalPrice,
    required this.productId,
    required this.userId,
    required this.imageUrl,
    required this.userName,
    required this.quantity,
    required this.orderDate,
    
  });
  final double price, totalPrice;
  final String productId,userId,imageUrl, userName;
  final int quantity;
  final Timestamp orderDate;

  @override
  State<OrdersWidget> createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends State<OrdersWidget> {
  late String orderDateStr;
  @override
  void initState() {
    var postDate = widget.orderDate.toDate();
    orderDateStr = '${postDate.day}/${postDate.month}/${postDate.year}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    Color color = theme == true ? Colors.white : Colors.black;
    Size size = Utils(context).getScreenSize;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(8.0),
        color:  Theme.of(context).cardColor.withOpacity(0.4),
        child: Padding(
          padding: const EdgeInsets.all(0.0),//adding space between background and row 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                flex: size.width < 650 ? 3 : 1,
                child: Image.network(
                widget.imageUrl,
        
                fit: BoxFit.fill,
                // heigth: screenwidth * 0.15,
                // width : screenwidth * 0.15,
              ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: '${widget.quantity}X For \₹${widget.price.toStringAsFixed(2)}',
                     color: color,
                     textSize: 16,
                     isTitle: true,
                     ),
                      // TextWidget(
                      //       text: ('address 1'),
                      //      color: color,
                      //      textSize: 14,
                      //      isTitle: true,
                      //      ),
                     FittedBox(
                      child: Row(children: [
                          TextWidget(
                            text: 'By',
                            color: Colors.blue,
                            textSize: 16,
                            isTitle: true,
                          ),
                          TextWidget(
                            text: ('${widget.userName}'),
                           color: color,
                           textSize: 14,
                           isTitle: true,
                           ),
                           
                      ]),
                     ),
                       Text(
                        orderDateStr,
                      ),
                  ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}