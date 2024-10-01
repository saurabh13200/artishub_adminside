import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_admin_panel/controllers/MenuController.dart';
import 'package:grocery_admin_panel/responsive.dart';
import 'package:grocery_admin_panel/screens/loading_manager.dart';
import 'package:grocery_admin_panel/services/utils.dart';
import 'package:grocery_admin_panel/widgets/buttons.dart';
import 'package:grocery_admin_panel/widgets/side_menu.dart';
import 'package:grocery_admin_panel/widgets/text_widget.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../screens/main_screen.dart';
import '../services/global_method.dart';
import '../widgets/header.dart';

class UploadProductForm extends StatefulWidget {
  static const routeName = '/UploadProductForm';

  const UploadProductForm({super.key});

  @override
  State<UploadProductForm> createState() => _UploadProductFormState();
}

class _UploadProductFormState extends State<UploadProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _catValue = 'Abstract-Art';

  late final TextEditingController _titleController,_descriptionController ,_PriceController;
  int _groupValue = 1;
  bool isPiece = false;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);

  @override
  void initState() {
    _PriceController  = TextEditingController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _PriceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  bool _isLoading = false;
  void _uploadForm() async {
    final _isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    String? imageUrl;
    if (_isValid) {
      _formKey.currentState!.save();
      if(_pickedImage == null){
        GlobalMethods.errorDialog(
            subtitle: 'Please pick up an image', context: context);
        return;
      }
     final _uuid = const Uuid().v4();
         
      try{
        setState(() {
          _isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child('$_uuid.jpg');
          if(kIsWeb){
            await ref.putData(webImage);
          } else {
            await ref.putFile(_pickedImage!);
          } 
          imageUrl = await ref.getDownloadURL();

          await FirebaseFirestore.instance.collection('products').doc(_uuid).set({
            'id': _uuid,
            'title': _titleController.text,
            'Description': _descriptionController.text,
            'price': _PriceController.text ,
            'salePrice': 0.1,
            'imageUrl': imageUrl.toString(),
            'productCategoryName': _catValue,
            'isOnSale': false,
            'isPiece': isPiece,
            
            'createdAt': Timestamp.now(),
          });  
          _clearForm();
        Fluttertoast.showToast(
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



  void _clearForm(){
    isPiece = false;
    _groupValue = 1;
    _PriceController.clear();
    _titleController.clear();
    _descriptionController.clear();
     setState(() {
      _pickedImage = null;
      webImage = Uint8List(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = Utils(context).color;
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
        ));

    return Scaffold(
      key: context.read<MenuConTroller>().getAddProductscaffoldKey,
      drawer: const SideMenu(),
      body: LoadingManager(
        isLoading: _isLoading,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (Responsive.isDesktop(context))
            const Expanded(
              child: SideMenu(),
            ),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
                child: Column(
              children: [
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Header(
                    fct: () {
                      context.read<MenuConTroller>().controlAddProductsMenu();
                    },
                    title: 'Add product',
                    showTexField: false,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Container(
                  width: size.width > 650 ? 650 : size.width,
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextWidget(
                          text: 'Product title',
                          color: color,
                          isTitle: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // for entering title
                        TextFormField(
                          controller: _titleController,
                          key: const ValueKey('Title'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a Title';
                            }
                            return null;
                          },
                          decoration: inputDecoration,
                        ),
                        const SizedBox(height: 5,),
                        //for description
                         TextWidget(
                          text: 'Product Description',
                          color: color,
                          isTitle: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // for entering description
                        TextFormField(
                          controller: _descriptionController,
                          key: const ValueKey('Description'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a Description';
                            }
                            return null;
                          },
                            decoration: inputDecoration = InputDecoration(
                                filled: true,
                                fillColor: _scaffoldColor,
                                
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: color,
                                    width: 1.0,
                                  ),
                                ),),
                        ),
                        // above code for descrption
      
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: FittedBox(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //for price enter
                                    TextWidget(
                                      text: 'Price in \₹*',
                                      color: color,
                                      isTitle: true,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: TextFormField(
                                        controller: _PriceController  ,
                                        key: const ValueKey('Price \₹'),
                                        keyboardType: TextInputType.number,
                                        
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Price is missed';
                                          }
                                          return null;
                                        },
                                        inputFormatters: <TextInputFormatter>[ 
                                          FilteringTextInputFormatter.allow(
                                            
                                              RegExp(r'[0-9.]')),
                                        ],
                                        decoration: inputDecoration,
                                      ),
                                    ),
                                    const Text('Do not Enter Multiple of 10 like 1000,5000\n Enter like this 999,5004',style: TextStyle(fontSize: 12),),
                                  
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    // for category
                                    TextWidget(
                                      text: 'Product category',
                                      color: color,
                                      isTitle: true,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    //Drop down menu code here
                                    _categoryDropDown(),
                                    
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    // for number of items
                                    TextWidget(
                                      text: 'Measure unit*',
                                      color: color,
                                      isTitle: true,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    //Radio to be picked code is here
                                    Row(
                                      children: [
                                        TextWidget(text: 'NO-ITEM',
                                         color: color,
                                         ),
                                        Radio(
                                            value: 1,
                                            groupValue: _groupValue,
                                            onChanged: (valuee) {
                                          setState(() {
                                            _groupValue = 1;
                                            isPiece = false;
                                          });
                                         },
                                         activeColor: Colors.green,
                                         ),
                                         TextWidget(text: 'No-Piece',
                                         color: color,
                                         ),
                                        Radio(
                                            value: 2,
                                            groupValue: _groupValue,
                                            onChanged: (valuee) {
                                          setState(() {
                                            _groupValue = 2;
                                            isPiece = true;
                                          });
                                         },
                                         activeColor: Colors.green,
                                         ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //Image to be picked code is here
                            Expanded(
                                flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height:
                                      size.width > 650 ? 350 : size.width * 0.45,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(12.0),
                                    
                                    ),
                                   child: _pickedImage == null?
                                    dottedBorder(color: color)
                                    :ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: kIsWeb?
                                    Image.memory(webImage,
                                              fit: BoxFit.fill)
                                          :
                                    Image.file(
                                              _pickedImage!,
                                              fit: BoxFit.fill,
                                            ),
                                    )
                                   
                                  ),
                              ),),
                            //for buttons
                            Expanded(
                                flex: 1,
                                child: FittedBox(
                                  child: Column(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _pickedImage = null;
                                            webImage = Uint8List(8);
                                          });
                                        },
                                        child: TextWidget(
                                          text: 'Clear',
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: TextWidget(
                                          text: 'Update image',
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ButtonsWidget(
                                onPressed: _clearForm,
                                text: 'Clear form',
                                icon: IconlyBold.danger,
                                backgroundColor: Colors.red.shade300,
                              ),
                              ButtonsWidget(
                                onPressed: () {
                                  _uploadForm();
                                    
                                },
                                text: 'Upload',
                                icon: IconlyBold.upload,
                                backgroundColor: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
          )
        ]),
      ),
    );
  }

Future <void> _pickImage() async {
  if(!kIsWeb){
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      var selected = File(image.path);
      setState(() {
        _pickedImage = selected;
      });
    }else{
      print('No Image has been picked');
    }
  }else if(kIsWeb){
     final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image != null){
      var f = await image.readAsBytes();
      setState(() {
        webImage = f;
        _pickedImage = File('a');
      });
    }else{
      print('No Image has been picked');
    }
  }else{
    print('Something went wrong');
  }
}


Widget dottedBorder({
  required Color color,
}){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: DottedBorder(
      dashPattern: const [6.7],
      borderType: BorderType.RRect,
      color: color,
      radius: const Radius.circular(12),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                Icon(
                  Icons.image_outlined,
                  color: color,
                  size: 50,
                ),
                const SizedBox(height: 20,),
                TextButton(
                  onPressed: (()  {
                    _pickImage();
                  }),
                    child: TextWidget(
                      text: 'Choose an image',
                      color: Colors.blue,
                    ))
        ],),
      )),
  );
}





  Widget _categoryDropDown() {
    final color = Utils(context).color;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
      padding: const EdgeInsets.all(8.0),                          
      child: DropdownButtonHideUnderline(

          child: DropdownButton<String>(
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600, fontSize: 16),
        value: _catValue,
        onChanged: (value) {
         
          setState(() {
            _catValue = value!;
          });
          print(_catValue);
        },
        hint: const Text('Select a Category'),
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
      )),),
    );
  }
}
