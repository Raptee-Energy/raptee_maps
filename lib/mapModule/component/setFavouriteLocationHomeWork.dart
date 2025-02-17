import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../BLoC/mapBLoC/setHomeLocation.dart';
import '../../../BLoC/mapBLoC/setOfficeLocation.dart';
import '../../../Constants/colors.dart';
import '../../../Models/locationHistoryDataModel.dart';
import '../../Methods/hideKeyboard.dart';

SetLocAsHomeWorkDialog(
    BuildContext context, LocationHistoryDataModel location) {
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width / 1.4,
            height: MediaQuery.of(context).size.height / 4,
            decoration: BoxDecoration(
                color: Clr.black1,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(12, 26),
                      blurRadius: 50,
                      spreadRadius: 0,
                      color: Colors.grey.withOpacity(.1)),
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(location.locationTitle ?? "",
                    maxLines: 3,
                    style: TextStyle(
                        color: Clr.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 3.5,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(location.locationDescription ?? "",
                      maxLines: 3,
                      style: TextStyle(
                          color: Clr.mainGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.w300)),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SimpleBtn1(
                        text: "Set as Home",
                        onPressed: () {
                          context.read<SetHomeLocationBloc>().add(
                              SetHomeLocationChangeEvent(
                                  locationHistoryDataModel: location));

                          printMsg("Home location set successfully");

                          Navigator.pop(context);
                        }),
                    SimpleBtn1(
                      text: "Set As Office",
                      onPressed: () {
                        context.read<SetOfficeLocationBloc>().add(
                            SetOfficeLocationChangedEvent(location: location));
                        printMsg("Work location set successfully");

                        Navigator.pop(context);
                      },
                      invertedColors: false,
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
}

class SimpleBtn1 extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final bool invertedColors;
  SimpleBtn1(
      {required this.text,
      required this.onPressed,
      this.invertedColors = false,
      Key? key})
      : super(key: key);
  final primaryColor = Clr.teal;
  final accentColor = Clr.white;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            alignment: Alignment.center,
            side: MaterialStateProperty.all(
                BorderSide(width: 1, color: primaryColor)),
            padding: MaterialStateProperty.all(
                const EdgeInsets.only(right: 10, left: 10, top: 0, bottom: 0)),
            backgroundColor: MaterialStateProperty.all(
                invertedColors ? accentColor : primaryColor),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            )),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: Clr.constWhite, fontSize: 14),
        ));
  }
}
