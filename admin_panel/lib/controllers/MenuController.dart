import 'package:flutter/material.dart';

class MenuConTroller extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _gridScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _addProductScaffoldKey = GlobalKey<ScaffoldState>();
   final GlobalKey<ScaffoldState> _editProductScaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _ordersScaffoldKey = GlobalKey<ScaffoldState>();
  // Getters
  GlobalKey<ScaffoldState> get getScaffoldKey => _scaffoldKey;
  GlobalKey<ScaffoldState> get getgridscaffoldKey => _gridScaffoldKey;
  GlobalKey<ScaffoldState> get getAddProductscaffoldKey => _addProductScaffoldKey;
  GlobalKey<ScaffoldState> get getEditProductscaffoldKey => _editProductScaffoldKey;
  GlobalKey<ScaffoldState> get getOrdersScaffoldKey  => _ordersScaffoldKey;

  // Callbacks
  void controlDashboarkMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  void controlProductsMenu() {
    if (!_gridScaffoldKey.currentState!.isDrawerOpen) {
      _gridScaffoldKey.currentState!.openDrawer();
    }
  }

  void controlAddProductsMenu() {
    if (!_editProductScaffoldKey.currentState!.isDrawerOpen) {
      _addProductScaffoldKey.currentState!.openDrawer();
    }
  }
  void controlEditProductsMenu() {
    if (!_addProductScaffoldKey.currentState!.isDrawerOpen) {
      _editProductScaffoldKey.currentState!.openDrawer();
    }
  }
   void controlAllOrder() {
    if (!_ordersScaffoldKey.currentState!.isDrawerOpen) {
      _ordersScaffoldKey.currentState!.openDrawer();
    }
  }
}
