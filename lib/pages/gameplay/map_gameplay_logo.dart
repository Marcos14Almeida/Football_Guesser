import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:map_game/class/controller/gameplay_functions.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/values/club_details.dart';
import 'package:map_game/widgets/back_button.dart';
import 'package:map_game/widgets/gameplay/common_widgets.dart';
import 'package:map_game/widgets/theme/textstyle.dart';

class MapGameplayLogo extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const MapGameplayLogo({Key? key,required this.mapGameSettings}) : super(key: key);

  @override
  State<MapGameplayLogo> createState() => _MapGameplayLogoState();
}

class _MapGameplayLogoState extends State<MapGameplayLogo> {
  double imageSize = 200;

  Gameplay gameplay = Gameplay();

  ClubDetails clubDetails = ClubDetails();
  late Timer timer;
////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    initMap();
    setLogoClub();
    setClubOptions();
    super.initState();
  }
  initMap(){
    gameplay.start(widget.mapGameSettings);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      gameplay.updateTimer(widget.mapGameSettings, context);
      setState((){});
    });
  }

  setLogoClub(){
    int clubID = Random().nextInt(gameplay.keysIterable.length);
    gameplay.objectiveClubName = gameplay.keysIterable.elementAt(clubID);
    String continent = clubDetails.getContinent(gameplay.objectiveClubName);
    if(clubDetails.getCoordinate(gameplay.objectiveClubName).latitude != 0 &&
        widget.mapGameSettings.selectedContinents.contains(continent) &&
        widget.mapGameSettings.stadiumSizeMin < clubDetails.getStadiumCapacity(gameplay.objectiveClubName)){
      //
    }else{
      setLogoClub();
    }
  }

  setClubOptions(){
    gameplay.listClubOptions = [];
    int clubMarkerPosition = Random().nextInt(6);
    for(int i=0;i<6;i++){
      if(i!=clubMarkerPosition){
        bool isValidOption = false;
        String clubName = '';
        int i=0;
        while(!isValidOption && i<100){
          i++;
          int clubID = Random().nextInt(gameplay.keysIterable.length);
          clubName = gameplay.keysIterable.elementAt(clubID);
          isValidOption = gameplay.isTeamPermitted(clubName, widget.mapGameSettings, clubDetails);
        }
        gameplay.listClubOptions.add(clubName);

      }else{
        gameplay.listClubOptions.add(gameplay.objectiveClubName);
      }
    }
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
              backButtonText(context, 'Map Gameplay Logo'),
              gameInfosBar(
                gameplay,
                widget.mapGameSettings,
                const Spacer(),
              ),

              SizedBox(
                height: imageSize,width: imageSize,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Images().getEscudoWidget(gameplay.objectiveClubName,imageSize-3,imageSize-3),
                      ),
                    ),
                    ClipRRect( // Clip it cleanly.
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(child: options()),

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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                optionBox(gameplay.listClubOptions[0]),
                optionBox(gameplay.listClubOptions[1]),
              ],
            ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              optionBox(gameplay.listClubOptions[2]),
              optionBox(gameplay.listClubOptions[3]),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              optionBox(gameplay.listClubOptions[4]),
              optionBox(gameplay.listClubOptions[5]),
            ],
          ),
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
              gameplay.correct(widget.mapGameSettings,clubName);
              setState((){});
              await Future.delayed(const Duration(seconds: 1));

              gameplay.guessedClubName = '';
              setLogoClub();
              setClubOptions();
            }else {
              gameplay.lostLife(widget.mapGameSettings, clubName);
            }
            if(gameplay.nLifes==0){
              gameplay.gameOver(widget.mapGameSettings, context);
            }

            setState((){});
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(clubName,textAlign:TextAlign.center,maxLines:2,style: EstiloTextoBranco.negrito22)),
              ],
            ),
          ),
      ),
    );
  }





}



