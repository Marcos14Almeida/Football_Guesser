import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_game/class/controller/gameplay_functions.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/class/size.dart';
import 'package:map_game/widgets/gameplay/common_widgets.dart';
import 'package:map_game/widgets/theme/textstyle.dart';
import 'package:map_game/values/club_details.dart';
import 'package:map_game/widgets/back_button.dart';

class MapGameplayMarkers extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const MapGameplayMarkers({Key? key,required this.mapGameSettings}) : super(key: key);

  @override
  State<MapGameplayMarkers> createState() => _MapGameplayMarkersState();
}

class _MapGameplayMarkersState extends State<MapGameplayMarkers> {


  Gameplay gameplay = Gameplay();

  ClubDetails clubDetails = ClubDetails();
  List<Marker> _markers = <Marker>[];
  late GoogleMapController controller;
  final List<Coordinates> coordinates = [];

  late Timer timer;

////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    initMap();
    defineNewClubTarget();
    super.initState();
  }
  initMap(){

    gameplay.start(widget.mapGameSettings);

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      gameplay.updateTimer(widget.mapGameSettings, context);
      setState((){});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    controller.dispose();
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

              gameInfosBar(),
              Expanded(
                child: GoogleMap(
                  mapType: MapType.satellite,
                  tiltGesturesEnabled: false,
                  indoorViewEnabled: false,
                  rotateGesturesEnabled: false,
                  //zoomGesturesEnabled: false, //SEM ZOOM
                  //zoomControlsEnabled: false, //SEM ZOOM
                  initialCameraPosition: CameraPosition(
                    target: LatLng(ClubDetails().getCoordinate(gameplay.objectiveClubName).latitude, 10),
                    zoom: 3.0,
                  ),
                  onMapCreated: getClubsLocation,
                  markers: Set<Marker>.of(_markers),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
////////////////////////////////////////////////////////////////////////////
//                               WIDGETS                                  //
////////////////////////////////////////////////////////////////////////////
  Widget gameInfosBar(){
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white38,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Text(gameplay.getTimeStr(),style: EstiloTextoBranco.text20),
                const Icon(Icons.watch_later_outlined,color: Colors.white,),
              ],
            ),
          ),
          Images().getEscudoWidget(gameplay.objectiveClubName,35,35),
          SizedBox(
              width: Sized(context).width*0.4,
              child: Text(gameplay.objectiveClubName,textAlign:TextAlign.center,overflow:TextOverflow.ellipsis,style: EstiloTextoBranco.negrito18)
          ),

          Column(
            children: [
              Text('${gameplay.nCorrect}/${MapGameModeNames().mapStarsValue(widget.mapGameSettings.mode)}',style: EstiloTextoBranco.text16),
              hearts(gameplay.nLifes),
            ],
          ),
        ],
      ),
    );
  }


////////////////////////////////////////////////////////////////////////////
//                               FUNCTIONS                                //
////////////////////////////////////////////////////////////////////////////
  defineNewClubTarget(){
    int clubID = Random().nextInt(gameplay.keysIterable.length);
    gameplay.objectiveClubName = gameplay.keysIterable.elementAt(clubID);

    if(!gameplay.isTeamPermitted(gameplay.objectiveClubName, widget.mapGameSettings, clubDetails)){
      defineNewClubTarget();
    }
    setState((){});
  }

  Future<void> getClubsLocation(GoogleMapController googleMapController) async{
    controller = googleMapController;
    _markers = [];
    List shuffledTeamKeys = shuffle(clubDetails.map.keys.toList());

    addMarker(gameplay.objectiveClubName, googleMapController);

    for (var clubName in shuffledTeamKeys) {

      if (gameplay.isTeamPermitted(clubName, widget.mapGameSettings, clubDetails) &&
          _markers.length<20
      ) {
        coordinates.add(clubDetails.getCoordinate(clubName));

        addMarker(clubName, googleMapController);

      }
    }

    setState((){});
  }

  addMarker(String clubName, GoogleMapController googleMapController){
    //ADD MARKER
    _markers.add(
      Marker(
        markerId: MarkerId(clubName),
        position: LatLng(
            clubDetails.getCoordinate(clubName).latitude, clubDetails.getCoordinate(clubName).longitude),
        onTap: () async {
          if(clubName == gameplay.objectiveClubName){
            gameplay.correct(widget.mapGameSettings, clubName);
            setState((){});
            await Future.delayed(const Duration(seconds: 1));
            defineNewClubTarget();
            getClubsLocation(googleMapController);
            //Zoom
            var newPosition = CameraPosition(
                target: LatLng(clubDetails.getCoordinate(clubName).latitude, clubDetails.getCoordinate(clubName).longitude),
                zoom: 3);
            CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(newPosition);
            controller.moveCamera(cameraUpdate);

          }else{
            gameplay.lostLife(widget.mapGameSettings, clubName);
          }
          if(gameplay.nLifes==0){
            gameplay.gameOver(widget.mapGameSettings, context);
          }
        },
        infoWindow: InfoWindow(title: clubName),
        //icon: clubsAllNameList.indexOf(clubName) < 40 ? _markersIcons[clubsAllNameList.indexOf(clubName)] : BitmapDescriptor.defaultMarker,
      ),
    );
  }
  List shuffle(List items) {
    var random = Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {

      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }
}
