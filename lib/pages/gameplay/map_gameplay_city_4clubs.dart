import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_game/class/controller/gameplay_functions.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/size.dart';
import 'package:map_game/widgets/back_button.dart';
import 'package:map_game/widgets/gameplay/common_widgets.dart';
import 'package:map_game/widgets/theme/textstyle.dart';

class GameplayCity4Clubs extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const GameplayCity4Clubs({Key? key,required this.mapGameSettings}) : super(key: key);

  @override
  State<GameplayCity4Clubs> createState() => _GameplayCity4ClubsState();
}

class _GameplayCity4ClubsState extends State<GameplayCity4Clubs> {

  Gameplay gameplay = Gameplay();
  late Timer timer;

  ////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    initMap();
    super.initState();
  }
  initMap(){
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      gameplay.milis++;
      setState((){});
    });
  }
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
////////////////////////////////////////////////////////////////////////////
//                               BUILD                                    //
////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Images().getWallpaper(),

          Column(
            children: [
              backButtonText(context, 'Gameplay'),

              gameInfosBar(
                gameplay,
                widget.mapGameSettings,
                SizedBox(width: Sized(context).width*0.55),
              ),

              const Expanded(
                child: GoogleMap(
                  mapType: MapType.satellite,
                  tiltGesturesEnabled: false,
                  indoorViewEnabled: false,
                  rotateGesturesEnabled: false,
                  zoomGesturesEnabled: false, //SEM ZOOM
                  zoomControlsEnabled: false, //SEM ZOOM
                  initialCameraPosition: CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 7.0,
                  ),
                  //onMapCreated: getClubsLocation,
                  //markers: Set<Marker>.of(_markers),
                ),
              ),


              options(),

            ],
          ),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////////////////////
//                               WIDGETS                                  //
////////////////////////////////////////////////////////////////////////////
  Widget options(){
    return Column(
      children: [
        Row(
          children: [
            optionBox(gameplay.listClubOptions[0]),
            optionBox(gameplay.listClubOptions[1]),
          ],
        ),
        Row(
          children: [
            optionBox(gameplay.listClubOptions[2]),
            optionBox(gameplay.listClubOptions[3]),
          ],
        ),
      ],
    );
  }
  Widget optionBox(String clubName){
    Color color = Colors.white38;
    if(gameplay.wrongAnswers.contains(clubName)){
      color = Colors.red;
    }else if(gameplay.guessedClubName.contains(clubName)){
      color = Colors.green;
    }
    return Expanded(
      child: GestureDetector(
        onTap: () async{

          if(clubName == gameplay.objectiveClubName){
            gameplay.correct(widget.mapGameSettings, clubName);
            setState((){});
            await Future.delayed(const Duration(seconds: 1));
          }else {
            gameplay.lostLife(widget.mapGameSettings, clubName);
          }
          if(gameplay.nLifes==0){
            gameplay.gameOver(widget.mapGameSettings, context);
          }

          setState((){});
        },
        child: Container(
          height: 80,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Text(clubName,textAlign:TextAlign.center,maxLines:2,style: EstiloTextoBranco.negrito18)),
              const SizedBox(width: 8),
              Images().getEscudoWidget(clubName,30,30),
            ],
          ),
        ),
      ),
    );
  }

}
