import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/inner_screens/add_prod.dart';
import 'package:grocery_admin_panel/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'consts/theme_data.dart';
import 'controllers/MenuController.dart';
import 'providers/dark_theme_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: const FirebaseOptions(
     apiKey: "AIzaSyCIRrFLDSYxMEi3ZwEkUmVheyZZEF5dcsQ",
      authDomain: "artisthub-15cf8.firebaseapp.com",
      projectId: "artisthub-15cf8",
      storageBucket: "artisthub-15cf8.appspot.com",
      messagingSenderId: "562870161347",
      appId: "1:562870161347:web:ecfafb900bdba442c03776",
      measurementId: "G-LLBQ4HQMQY"
       ));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
      return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Center(
                  child: Text('App is being initialized'),
                ),
              ),
            ),
          );
          }else if (snapshot.hasError){
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text('An error has been occured ${snapshot.error}'),
                  ),
                ),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => MenuConTroller(),
              ),
              ChangeNotifierProvider(
                create: (_) {
                return themeChangeProvider;
              },
              ),
            ],
            child: Consumer<DarkThemeProvider>(
              builder: (context, themeProvider, child){
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Artisthub',
                  theme: Styles.themeData(themeProvider.getDarkTheme, context),
                  home: const MainScreen(),
                  routes: {
                    UploadProductForm.routeName:(context) =>
                    const UploadProductForm(),
                  
                  },
                );
              },
            ),
          );
        } 
        );
       
      
    
 
  }
}
