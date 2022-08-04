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

class MapGameplayClubStadium extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const MapGameplayClubStadium({Key? key,required this.mapGameSettings}) : super(key: key);

  @override
  State<MapGameplayClubStadium> createState() => _MapGameplayClubStadiumState();
}

class _MapGameplayClubStadiumState extends State<MapGameplayClubStadium> {

  Gameplay gameplay = Gameplay();

  ClubDetails clubDetails = ClubDetails();
  List<Marker> _markers = <Marker>[];
  late GoogleMapController controller;
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

  getClubsLocation(GoogleMapController googleMapController) async{
    controller = googleMapController;


    int clubID = Random().nextInt(gameplay.keysIterable.length);
    gameplay.objectiveClubName = gameplay.keysIterable.elementAt(clubID);


    if(gameplay.isTeamPermitted(gameplay.objectiveClubName, widget.mapGameSettings, clubDetails)){
      coordinates.add(clubDetails.getCoordinate(gameplay.objectiveClubName));
      //Zoom
      var newPosition = CameraPosition(
          target: LatLng(coordinates.last.latitude,coordinates.last.longitude),
          zoom: 16);
      CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(newPosition);
      controller.moveCamera(cameraUpdate);

      city = clubDetails.getStadium(gameplay.objectiveClubName);


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
                SizedBox(width: Sized(context).width*0.55,child: Text(city,textAlign:TextAlign.center,overflow:TextOverflow.ellipsis,style: EstiloTextoBranco.text16)),
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
        onTap: ()async{
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
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
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
                  onMapCreated: getClubsLocation,
                  markers: Set<Marker>.of(_markers),
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

////////////////////////////////////////////////////////////////////////////
//                               FUNCTIONS                                //
////////////////////////////////////////////////////////////////////////////

}
