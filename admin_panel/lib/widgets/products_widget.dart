import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/inner_screens/edit_prod.dart';


import '../services/global_method.dart';
import '../services/utils.dart';
import 'text_widget.dart';

//product design


class ProductWidget extends StatefulWidget {
  const ProductWidget({
    Key? key, required this.id,
  }) : super(key: key);
  final String id;

  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
 
  String title = '';
  String description = '';
  String productCat = '';
  String? imageUrl; 
  var price = '0.0';
  double salePrice = 0.0;
  bool isOnSale = false;
  bool isPiece = false;


@override
  void initState() {
    getProductsData();
    super.initState();
  }

  
  Future<void> getProductsData() async {
    try {
     

      final DocumentSnapshot productsDoc = await
          FirebaseFirestore.instance
          .collection('products')
          .doc(widget.id)
          .get();
          if(productsDoc == null){
            return;
          }else{
          setState(() {
          title = productsDoc.get('title');
          description = productsDoc.get('Description');
          productCat = productsDoc.get('productCategoryName');
          imageUrl = productsDoc.get('imageUrl');
          price = productsDoc.get('price');
          salePrice = productsDoc.get('salePrice');
          isOnSale = productsDoc.get('isOnSale');
          isPiece = productsDoc.get('isPiece');
          });
    
           
          }

    } catch (error) {   
     GlobalMethods.errorDialog(
            subtitle: '$error', context: context);
    } finally {
        
    }


  }

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;

    final color = Utils(context).color;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor.withOpacity(0.6),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute
              (builder: (context)=> EditProductScreen(
                      id: widget.id,
                      titile: title,
                      description: description,
                      price: price,
                      productCat: productCat,
                      imageUrl:  imageUrl==null
                        ? 'https://i.ibb.co/XFXCrCm/noimageloaded.jpg'
                        : imageUrl!,
                      isPiece: isPiece,
                      isOnSale: isOnSale,
                      salePrice: salePrice,
                     
                    )),
                    );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Image.network(
                        imageUrl==null
                        ? 'https://i.ibb.co/XFXCrCm/noimageloaded.jpg'
                        : imageUrl!,
                        fit: BoxFit.fill,
                        // width: screenWidth * 0.12,
                        height: size.width * 0.12,
                      ),
                    ),
                    const Spacer(),
                    // PopupMenuButton(
                    //     itemBuilder: (context) => [
                    //           PopupMenuItem(
                    //             onTap: () {},
                    //             child: const Text('Edit'),
                    //             value: 1,
                    //           ),
                    //           PopupMenuItem(
                    //             onTap: () {},
                    //             child: const Text(
                    //               'Delete',
                    //               style: TextStyle(color: Colors.red),
                    //             ),
                    //             value: 2,
                    //           ),
                    //         ])
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    TextWidget(
                      text: isOnSale
                      ? '\₹${salePrice.toStringAsFixed(2)}'
                      : '\₹$price',
                      color: color,
                      textSize: 13,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Visibility(
                        visible: isOnSale,
                        child: Text(
                          '\₹$price',
                          style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                             fontSize: 10,
                              color: color),
                        )),
                    const Spacer(),
                    TextWidget(
                      text: isPiece? 'No-Piece': 'NO-ITEM',
                      color: color,
                      textSize: 8,
                    ),
                   
                  ],
                 
                ),
                const SizedBox(
                  height: 2,
                ),
                TextWidget(
                  text: title,
                  color: color,
                  textSize: 16,
                  maxLines: 2,
                  isTitle: true,
                ),
                // add for item desciption
                 TextWidget(
                  text: description,
                  color: color,
                  textSize: 10,
                  isTitle: true,
                ),
                
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}
