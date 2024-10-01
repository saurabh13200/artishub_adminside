
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_admin_panel/controllers/MenuController.dart';
import 'package:grocery_admin_panel/screens/loading_manager.dart';
import 'package:grocery_admin_panel/services/global_method.dart';
import 'package:grocery_admin_panel/services/utils.dart';
import 'package:grocery_admin_panel/widgets/buttons.dart';
import 'package:grocery_admin_panel/widgets/header.dart';
import 'package:grocery_admin_panel/widgets/side_menu.dart';
import 'package:grocery_admin_panel/widgets/text_widget.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';


import '../responsive.dart';
import '../screens/main_screen.dart';

class EditProductScreen extends StatefulWidget {
static const routename = '/EditProductScreen';

  const EditProductScreen(
      {super.key,
      required this.id,
      required this.titile,
      required this.price,
      required this.productCat,
      required this.imageUrl,
      required this.isPiece,
      required this.isOnSale,
      required this.salePrice,
       required this.description}); 

 final String id,titile,price,productCat,imageUrl,description;
final bool isPiece,isOnSale;
final double salePrice;
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formkey = GlobalKey<FormState>();
  //Title and price controllers
  late  final TextEditingController _titleController, _descriptionController, _priceController;
  //Category
  late String _catValue;


  //Sale
 String? _salePercent;
  late String percToShow;
 late double _salePrice;
  late bool _isOnSale;


  //Image
  File? _pickedImage;
  Uint8List webImage = Uint8List(10);
  late String _imageUrl;
  //NO-Item or Piece
  late int val;
  late bool _isPiece;
  //while loading
  bool _isLoading = false;

  @override
  void initState() {
    //set the price and titile values and initlization the controller
    _priceController = TextEditingController(text: widget.price);
    _titleController = TextEditingController(text: widget.titile);
    _descriptionController =TextEditingController(text: widget.description );
  

    
    //set variables
   
    _salePrice = widget.salePrice;
    _catValue = widget.productCat;
    _isOnSale = widget.isOnSale;
    _isPiece = widget.isPiece;
    val = _isPiece ? 2: 1;
    _imageUrl = widget.imageUrl;
          
    //Calculae the percentage
    percToShow = (100 - 
        (_salePrice * 100) /
         double.parse(
          widget.price
         ))
            .roundToDouble()
            .toStringAsFixed(1) +
        '%';
    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    //_salePriceController.dispose();
    super.dispose();
  }
  
   
  void _updateProduct() async {
    final _isValid = _formkey.currentState!.validate();
    FocusScope.of(context).unfocus();
    
    
    if (_isValid) {
      _formkey.currentState!.save();
      
         
      try{
        String? imageUrl;
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('userImages')
              .child('${widget.id}.jpg');
          if (kIsWeb) {
            await ref.putData(webImage);
          } else {
            await ref.putFile(_pickedImage!);
          }
          imageUrl = await ref.getDownloadURL();//imageUri
        }

          await FirebaseFirestore.instance.collection('products').doc(widget.id).update({
            
            'title': _titleController.text,
            'Description': _descriptionController.text,
            'price': _priceController.text ,
            'salePrice': _salePrice,
            'imageUrl': _pickedImage == null ? widget.imageUrl : imageUrl.toString(),//imageuri
            'productCategoryName': _catValue,
            'isOnSale': _isOnSale,
            'isPiece': _isPiece,
            
            
          });  
         
        await Fluttertoast.showToast(
          msg: "Product uploaded succefully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
        
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
            subtitle: '${error.message}', context: context);
        setState(() {
          _isLoading = false;
    });
      } catch (error) {
        GlobalMethods.errorDialog(subtitle: '$error', context: context);
        setState(() {
          _isLoading = false;
    });
      } finally {
        setState(() {
          _isLoading = false;
    });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = theme == true? Colors.white : Colors.black;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    var inputDecoration = InputDecoration(
      filled: true,
      fillColor: _scaffoldColor,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1.0,
        ),
      ),
    );
    return  Scaffold(
      //key: context.read<MenuConTroller>().getEditProductscaffoldKey,
    //  drawer: const SideMenu(),
      body: LoadingManager(
                isLoading: _isLoading,
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        // Header(
                        //   showTexField: false,
                        //   fct: (){
                        //     context.read<MenuConTroller>().controlEditProductsMenu();
                        
                        //   },
                        //    title: 'Edit this product',
                        //    ),
                           Container(
                            width: size.width > 650 ? 650 : size.width,
                            color:  Theme.of(context).cardColor,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.all(16),
                            child: Form(
                              key: _formkey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget> [
                                  //for title
                              TextWidget(
                                text: 'Product title*',
                                color: color,
                                isTitle: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _titleController,
                                key: const ValueKey('Title'),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'Please enter a Title';
                                  }
                                  return null;
                                },
                                decoration: inputDecoration,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              //for description
                                TextWidget(
                                text: 'Product description',
                                color: color,
                                isTitle: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _descriptionController,
                                key: const ValueKey('Description'),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                                decoration: inputDecoration,
                              ),
                              //above code for descrption
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: FittedBox(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                            TextWidget(
                                              text: 'Price in \₹*',
                                              color: color,
                                              isTitle: true,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: TextFormField(
                                                controller: _priceController,
                                                key: const ValueKey('Price \₹'),
                                                keyboardType: TextInputType.number,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Price is missed';
                                                  }
                                                  return null;
                                                },
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9.]')),
                                                ],
                                                decoration: inputDecoration,
                                              ),
                                            ),
                                              const Text(
                                                'Do not Enter Multiple of 10 like 1000,5000\n Enter like this 999,5004',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextWidget(
                                              text: 'Product category',
                                              color: color,
                                              isTitle: true,
                                            ),
                                            const SizedBox(height: 10,),
                                            Container(
                                              color: _scaffoldColor,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8
                                                ),
                                                child: catDropDownWidget(color),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextWidget(
                                              text: 'Measure unit*',
                                              color: color,
                                              isTitle: true,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: 'NO-ITEM', color: color,),
                                                Radio(
                                                  value: 1,
                                                   groupValue: val,
                                                    onChanged: (value) {
                                                  setState(() {
                                                      val = 1;
                                                      _isPiece = false;
                                                  }
                                                  );
                                                },
                                                activeColor: Colors.green,
                                                ),
                                                TextWidget(text: 'Piece', color: color),
                                                 Radio(
                                                  value: 2,
                                                   groupValue: val,
                                                    onChanged: (value) {
                                                  setState(() {
                                                      val = 2;
                                                      _isPiece = true;
                                                  }
                                                  );
                                                },
                                                activeColor: Colors.green,
                                                ),
                                                
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: _isOnSale,
                                                  
                                                  checkColor: Colors.green,
                                                 onChanged: (newValue){
                                                  setState(() {
                                                    _isOnSale = newValue!;
                                                  });
                                                 },
                                                 ),
                                               const SizedBox(
                                                  height: 200,
                                                ),
                                                  TextWidget(
                                                    text: 'Sale',
                                                    color: color,
                                                    isTitle: true,
                                                  ),
                                              AnimatedSwitcher(
                                                duration: const Duration(seconds: 1),
                                                child: !_isOnSale
                                                ? Container()
                                                :Row(
                                                  children: [
                                                    //saleprice
                                            //          TextWidget(
                                            //   text: 'salePrice in \₹*',
                                            //   color: color,
                                            //   isTitle: true,
                                            // ),
                                            // const SizedBox(
                                            //   height: 30,
                                            // ),
                                            // SizedBox(
                                            //   width: 100,
                                            //   child: TextFormField(
                                            //     controller: _salePriceController,
                                            //     key: const ValueKey('salePrice \₹'),
                                            //     keyboardType: TextInputType.number,
                                            //     validator: (value) {
                                            //       if (value!.isEmpty) {
                                            //         return 'salePrice is missed';
                                            //       }
                                            //       return null;
                                            //     },
                                            //     inputFormatters: <
                                            //         TextInputFormatter>[
                                            //       FilteringTextInputFormatter
                                            //           .allow(RegExp(r'[0-9.]')),
                                            //     ],
                                            //     decoration: inputDecoration,
                                            //   ),
                                            // ),
                  
                                                            TextWidget(
                                                              text: "/₹" + 
                                                                  _salePrice
                                                                      .toStringAsFixed(
                                                                          2),
                                                              color: color,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            salePourcentageDropDownWidget(
                                                                color),
                                                          ],
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      height: size.width > 650
                                      ? 350
                                      : size.width * 0.45,
                                      decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              
                                      ),
                                      child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12)),
                        
                        
                                      child: _pickedImage == null
                                      ? Image.network(_imageUrl)
                                      : (kIsWeb)
                                      ? Image.memory(
                                        webImage,
                                        fit: BoxFit.fill,
                                      )
                                      :Image.file(
                                        _pickedImage!,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    ),
                                  ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        FittedBox(
                                          child: TextButton(
                                            onPressed: (){
                                              _pickImage();
                                            },
                                              child: TextWidget(
                                                  text: 'Update image',
                                                color: Colors.blue,
                                              ),
                                          ),
                                        )
                                      ],
                                    ) ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ButtonsWidget(
                                        onPressed: () async {
                                          GlobalMethods.warningDialog(
                                            title: 'Delete?',
                                            subtitle: 'Press okay to confirm',
                                            fct: () async {
                                                  await FirebaseFirestore.instance
                                                      .collection('products')
                                                      .doc(widget.id)
                                                      .delete();
                                                  await Fluttertoast.showToast(
                                                    msg:
                                                        "Product has been deleted",
                                                        toastLength: Toast.LENGTH_LONG,
                                                        gravity: ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                  );
                                                  while(Navigator.canPop(context)){
                                                    Navigator.pop(context);
                                                  }  
                                            },
                                            context: context);
                                      },
                                      text: 'Delete',
                                      icon: IconlyBold.danger,
                                      backgroundColor: Colors.red.shade800,
                                    ),
                                    ButtonsWidget(
                                      onPressed: () {
                                        _updateProduct();
                                        Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const MainScreen(),
                                              ),
                                            );
                                      },
                                      text: 'Update',
                                      icon: IconlyBold.setting,
                                      backgroundColor: Colors.blue,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                                  ),
                  ),
              ),
              
      ),
    );
  }



  DropdownButtonHideUnderline salePourcentageDropDownWidget(Color color){
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: TextStyle(color: color),
        items: const [
          DropdownMenuItem<String>(
          child: Text('10%'),
          value: '10',
        ),
        DropdownMenuItem<String>(
          child: Text('15%'),
          value: '15',
        ),
        DropdownMenuItem<String>(
          child: Text('25%'),
          value: '25',
        ),
        DropdownMenuItem<String>(
          child: Text('45%'),
          value: '45',
        ),
        DropdownMenuItem<String>(
          child: Text('50%'),
          value: '50',
        ),
        DropdownMenuItem<String>(
          child: Text('70%'),
          value: '70',
        ),
        DropdownMenuItem<String>(
          child: Text('80%'),
          value: '80',
        ),
        DropdownMenuItem<String>(
          child: Text('90%'),
          value: '90',
        ),
        DropdownMenuItem<String>(
          child: Text('0%'),
          value: '0',
        ),
        ],
        onChanged: (value){
          if(value == '0'){
            return;
          }else{
            setState(() {
              _salePercent = value;
              _salePrice =    double.parse(widget.price) -
              (double.parse(value!) * double.parse(widget.price)/100);
           

            });
          }
        },
        hint: Text(_salePercent ?? percToShow),
        value: _salePercent,
      ),
     );
  }

  DropdownButtonHideUnderline catDropDownWidget(Color color){
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: TextStyle(color: color),
        items: const [
           DropdownMenuItem(
            child: Text(
              'Abstract-Art',
            ),
            value: 'Abstract-Art',
          ),
          DropdownMenuItem(
            child: Text(
              'Canvas-Art',
            ),
            value: 'Canvas-Art',
          ),
           DropdownMenuItem(
            child: Text(
              'Landscape-Art',
            ),
            value: 'Landscape-Art',
          ),
           DropdownMenuItem(
            child: Text(
              'Modern-Art',
            ),
            value: 'Modern-Art',
          ),
           DropdownMenuItem(
            child: Text(
              'Mud-Art',
            ),
            value: 'Mud-Art',
          ),
           DropdownMenuItem(
            child: Text(
              'Oil-Painting',
            ),
            value: 'Oil-Painting',
          ),
           DropdownMenuItem(
            child: Text(
              'Portrait-Painting',
            ),
            value: 'Portrait-Painting',
          ),
           DropdownMenuItem(
            child: Text(
              'Sculpture-Art',
            ),
            value: 'Sculpture-Art',
          ),
           DropdownMenuItem(
            child: Text(
              'Spray-Painting',
            ),
            value: 'Spray-Painting',
          ),
           DropdownMenuItem(
            child: Text(
              'Watercolor-Art',
            ),
            value: 'Watercolor-Art',
          ),
           DropdownMenuItem(
            child: Text(
              'Other-Art',
            ),
            value: 'Other-Art',
          ),
        ],
        onChanged: (value){
          setState(() {
            _catValue =value!;
          });
        },
        hint:  const Text('Select a category'),
        value: _catValue,
      )
      );
  }


  Future<void> _pickImage() async {
  
    
    //MOBILE
    if(!kIsWeb){
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if(image != null){
        var selected = File(image.path);

        setState(() {
          _pickedImage = selected;
        });
      }else{
        print('No file selected');
      }
    }
  //web
  else if(kIsWeb){
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){
        var f = await image.readAsBytes();

        setState(() {
          _pickedImage = File("a");
          webImage = f;
        });
      }else{
        print('No file selected' );
      }
  }else {
    print('Perm not granted' );
  }
  }
}