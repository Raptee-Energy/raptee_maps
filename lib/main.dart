import 'package:flutter/material.dart';
import 'Screens/MapScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raptee Maps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapScreen(),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'BLoC/mapBLoC/setHomeLocation.dart';
// import 'BLoC/mapBLoC/setOfficeLocation.dart';
// import 'Screens/MapScreen.dart';
//
// void main() {
//
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//             create: (context) =>
//             SetHomeLocationBloc()..add(SetHomeLocationInitEvent())),
//         BlocProvider(
//             create: (context) =>
//             SetOfficeLocationBloc()..add(SetOfficeLocationInitialEvent())),
//       ],
//       child: MaterialApp(
//         title: 'Dino Maps',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           brightness: Brightness.light,
//           useMaterial3: true,
//         ),
//         darkTheme: ThemeData(brightness: Brightness.dark),
//         themeMode: ThemeMode.light,
//         home: const MapScreen(),
//       ),
//     );
//   }
// }
//
