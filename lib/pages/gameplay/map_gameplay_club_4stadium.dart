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
import 'package:map_game/widgets/theme/custom_toast.dart';
import 'package:map_game/widgets/theme/textstyle.dart';

class MapGameplayClubStadium extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const MapGameplayClubStadium({Key? key,required this.mapGameSettings}) : super(key: key);

  @override
  State<MapGameplayClubStadium> createState() => _MapGameplayClubStadiumState();
}

class _MapGameplayClubStadiumState extends State<MapGameplayClubStadium> {

  Gameplay gameplay = Gameplay();

  ClubDetails clubDetails = ClubDetails();
  late GoogleMapController controller0;
  late GoogleMapController controller1;
  late GoogleMapController controller2;
  late GoogleMapController controller3;
  int clubMarkerPosition = 0;
  List<Coordinates> coordinates = [];
  String city = '';
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
    gameplay.start(widget.mapGameSettings);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      gameplay.updateTimer(widget.mapGameSettings, context);
      setState((){});
    });
  }
////////////////////////////////////////////////////////////////////////////
//                               FUNCTIONS                                //
////////////////////////////////////////////////////////////////////////////
  selectController(mapNumber){
    if(mapNumber==0){return controller0;}
    if(mapNumber==1){return controller1;}
    if(mapNumber==2){return controller2;}
    if(mapNumber==3){return controller3;}
  }
  getController0(GoogleMapController googleMapController){
    controller0 = googleMapController;
    selectMainClub();
    setClubOptions(googleMapController,0);
  }
  getController1(GoogleMapController googleMapController){
    controller1 = googleMapController;
    setClubOptions(googleMapController,1);
  }
  getController2(GoogleMapController googleMapController){
    controller2 = googleMapController;
    setClubOptions(googleMapController,2);
  }
  getController3(GoogleMapController googleMapController){
    controller3 = googleMapController;
    setClubOptions(googleMapController,3);
  }

  selectMainClub(){
    clubMarkerPosition = Random().nextInt(4);
    gameplay.listClubOptions = [];
    coordinates = [];

    int clubID = Random().nextInt(gameplay.keysIterable.length);
    gameplay.objectiveClubName = gameplay.keysIterable.elementAt(clubID);

    if(gameplay.isTeamPermitted(gameplay.objectiveClubName, widget.mapGameSettings, clubDetails)){
      city = clubDetails.getStadium(gameplay.objectiveClubName);
    }else{
      selectMainClub();
    }

  }

  setClubOptions(GoogleMapController googleMapController, int mapNumber){
      if(mapNumber != clubMarkerPosition){
        bool isValidOption = false;
        String clubName = '';
        int i=0;
        while(!isValidOption && i<100){
          i++;
          int clubID = Random().nextInt(gameplay.keysIterable.length);
          clubName = gameplay.keysIterable.elementAt(clubID);
          isValidOption = gameplay.isTeamPermitted(clubName, widget.mapGameSettings, clubDetails);
        }
        coordinates.add(clubDetails.getCoordinate(clubName));
        gameplay.listClubOptions.add(clubName);
      }else{
        coordinates.add(clubDetails.getCoordinate(gameplay.objectiveClubName));
        gameplay.listClubOptions.add(gameplay.objectiveClubName);
      }

      setZoom(googleMapController);

      setState((){});
  }

  setZoom(GoogleMapController googleMapController){
    //Zoom
    var newPosition = CameraPosition(
        target: LatLng(coordinates.last.latitude,coordinates.last.longitude),
        zoom: 15.6);
    CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(newPosition);
    googleMapController.moveCamera(cameraUpdate);
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
                SizedBox(width: Sized(context).width*0.55,child: Row(
                  children: [
                    Expanded(child: Text(city+clubMarkerPosition.toString(),textAlign:TextAlign.center,overflow:TextOverflow.ellipsis,maxLines:2,style: EstiloTextoBranco.text16)),
                  ],
                )),
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
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              optionBox(gameplay.listClubOptions[0],getController0),
              optionBox(gameplay.listClubOptions[1],getController1),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              optionBox(gameplay.listClubOptions[2], getController2),
              optionBox(gameplay.listClubOptions[3], getController3),
            ],
          ),
        ),
      ],
    );
  }

  Widget optionBox(String clubName, Function(GoogleMapController) controllerFunc){

    return Expanded(
      child: GestureDetector(
        onTap: () {
          tapOption(clubName);
        },
        onDoubleTap: (){
          tapOption(clubName);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: gameplay.boxColor(clubName),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Column(
            children: [

              Expanded(
                child: GoogleMap(
                  mapType: MapType.satellite,
                  indoorViewEnabled: false,
                  mapToolbarEnabled: false,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false, //SEM ZOOM
                  zoomControlsEnabled: false, //SEM ZOOM
                  tiltGesturesEnabled: false,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(clubDetails.getCoordinate(clubName).latitude, clubDetails.getCoordinate(clubName).longitude),
                    zoom: 6.0,
                  ),
                  onMapCreated: controllerFunc,
                ),
              ),


              SizedBox(
                height: 40,
                child: GestureDetector(
                  onTap: (){},
                    child: Row(
                      children: [
                        Images().getEscudoWidget(clubName,25,25),
                        const SizedBox(width: 8),
                        Expanded(child: Text(clubName,maxLines:2,style: EstiloTextoBranco.text12)),
                      ],
                    )),),
            ],
          ),
        ),
      ),
    );
  }

  tapOption(String clubName){
    if(clubName == gameplay.objectiveClubName){
      gameplay.correct(widget.mapGameSettings, clubName);
      setState((){});
      getController0(controller0);
      getController1(controller1);
      getController2(controller2);
      getController3(controller3);

    }else {
      gameplay.lostLife(widget.mapGameSettings, clubName);
    }
    if(gameplay.nLifes==0){
      gameplay.gameOver(widget.mapGameSettings, context);
    }

    setState((){});
  }

}
