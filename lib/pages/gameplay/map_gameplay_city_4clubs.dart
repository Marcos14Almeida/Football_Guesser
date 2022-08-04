import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_game/class/controller/gameplay_functions.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/size.dart';
import 'package:map_game/values/club_details.dart';
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
  ClubDetails clubDetails = ClubDetails();

  List<Marker> _markers = <Marker>[];
  late GoogleMapController controller;
  late Timer timer;
  String city = '';

  ////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    initMap();
    super.initState();
  }
  initMap(){
    gameplay.start(widget.mapGameSettings);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      gameplay.updateTimer(widget.mapGameSettings, context);
      setState((){});
    });
  }


////////////////////////////////////////////////////////////////////////////
//                               FUNCTIONS                                //
////////////////////////////////////////////////////////////////////////////

  Future<void> getClubsLocation(GoogleMapController googleMapController) async{
    controller = googleMapController;

    int clubID = Random().nextInt(gameplay.keysIterable.length);
    gameplay.objectiveClubName = gameplay.keysIterable.elementAt(clubID);

    if(gameplay.isTeamPermitted(gameplay.objectiveClubName, widget.mapGameSettings, clubDetails)
    ){
      setZoom();
      _markers = [];
      addMarker(gameplay.objectiveClubName, googleMapController);
    }else{
      getClubsLocation(googleMapController);
    }


    setClubOptions();

    setState((){});
  }

  setClubOptions(){
    gameplay.listClubOptions = [];
    int clubMarkerPosition = Random().nextInt(4);
    for(int i=0;i<4;i++){
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

  setZoom(){
    //Zoom
    var newPosition = CameraPosition(
        target: LatLng(clubDetails.getCoordinate(gameplay.objectiveClubName).latitude,clubDetails.getCoordinate(gameplay.objectiveClubName).longitude),
        zoom: 5);
    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(newPosition);
    controller.moveCamera(cameraUpdate);
  }

  addMarker(String clubName, GoogleMapController googleMapController){
    //ADD MARKER
    _markers.add(
      Marker(
        markerId: MarkerId(clubName),
        position: LatLng(
            clubDetails.getCoordinate(clubName).latitude, clubDetails.getCoordinate(clubName).longitude),
        onTap: () async {
        },
        ),
    );
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
                  SizedBox(
                      width: Sized(context).width*0.55,
                      child: const Text('',textAlign:TextAlign.center,overflow:TextOverflow.ellipsis,style: EstiloTextoBranco.negrito18)
                  ),
              ),

              Expanded(
                child: GoogleMap(
                  mapType: MapType.satellite,
                  tiltGesturesEnabled: false,
                  indoorViewEnabled: false,
                  rotateGesturesEnabled: false,
                  zoomGesturesEnabled: false, //SEM ZOOM
                  zoomControlsEnabled: false, //SEM ZOOM
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(10, 10),
                    zoom: 5.0,
                  ),
                  onMapCreated: getClubsLocation,
                  markers: Set<Marker>.of(_markers),
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
    return Expanded(
      child: GestureDetector(
        onTap: () async{

          if(clubName == gameplay.objectiveClubName){
            gameplay.correct(widget.mapGameSettings, clubName);
            setState((){});
            await Future.delayed(const Duration(seconds: 1));
            getClubsLocation(controller);
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
            color: gameplay.boxColor(clubName),
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
