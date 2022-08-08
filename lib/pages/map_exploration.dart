import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_game/class/controller/gameplay_functions.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/class/flags_list.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/size.dart';
import 'package:map_game/class/words.dart';
import 'package:map_game/widgets/theme/colors.dart';
import 'package:map_game/widgets/theme/textstyle.dart';
import 'package:map_game/values/club_details.dart';
import 'package:map_game/widgets/back_button.dart';

class MapPage extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const MapPage({Key? key, required this.mapGameSettings}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final List<Coordinates> coordinates = [];
  List<Marker> _markers = <Marker>[];
  List<Marker> _markersShow = <Marker>[];
  late GoogleMapController controller;
  //Controle Ano fundação
  ClubDetails clubDetails = ClubDetails();
  TextEditingController controllerMin = TextEditingController();
  TextEditingController controllerMax = TextEditingController();
  TextEditingController controllerStadiumMin = TextEditingController();
  TextEditingController controllerStadiumMax = TextEditingController();

  //TIMELINE
  TextEditingController controllerSimulationYear = TextEditingController();
  bool showTimeline = false;
  bool playTimeline = false;
  bool removePreviousFoundedTeams = false;
  int yearTimeline = 1860;
  int anoFinal = 2022;
  late Timer timer;
  ////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    controllerSimulationYear.text = '1865';
    initMap();
    super.initState();
  }
  initMap() async{
    //GARANTE QUE A PÁGINA VAI DAR SETSTATE E CARREGAR OS MARKERS
    await Future.delayed(const Duration(seconds: 1));
    setState((){});
    await Future.delayed(const Duration(seconds: 3));
      setState((){});
    await Future.delayed(const Duration(seconds: 6));
    setState((){});
  }
  getClubsLocation(GoogleMapController googleMapController) {
    controller = googleMapController;
    _markers = [];
    clubDetails.map.forEach((key, value) {
      String clubName = key;

      if(Gameplay().isTeamPermitted(clubName,widget.mapGameSettings,clubDetails)){
        coordinates.add(clubDetails.getCoordinate(clubName));

        //ADD MARKER
        _markers.add(
          Marker(
            markerId: MarkerId(clubName),
            position: LatLng(coordinates.last.latitude,coordinates.last.longitude),
            onTap: () async{
              onMarkerTap(clubName);
            },
            //infoWindow: InfoWindow(title: clubName),
            //icon: clubsAllNameList.indexOf(clubName) < 40 ? _markersIcons[clubsAllNameList.indexOf(clubName)] : BitmapDescriptor.defaultMarker,
          ),
        );
        _markersShow = List.from(_markers);
      }
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

              header(),

              Expanded(
                child: GoogleMap(
                mapType: MapType.satellite,
                tiltGesturesEnabled: false,
                indoorViewEnabled: false,
                rotateGesturesEnabled: false,
                compassEnabled: false,

                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 3.0,
                ),
                onMapCreated: getClubsLocation,
                markers: Set<Marker>.of(_markersShow),
              ),
              ),

            ],
          ),

          SizedBox(
            height: Sized(context).height,
            child: Column(
              children: [
                const Spacer(),
                Row(
                  children: [
                    buttonZoomOut(),
                    buttonZoomMedium(),
                  ],
                )
              ],
            ),
          ),

        ],
      ),
    );
  }
////////////////////////////////////////////////////////////////////////////
//                               WIDGETS                                  //
////////////////////////////////////////////////////////////////////////////

  clubsFoundedTimelapse(){
    try{
      timer.cancel();
    }catch(e){
      //1ªvez que o botao foi clicado, entao o timer ainda nao existe
      //Se existir entao ele é apagado antes de ser iniciado de novo.
    }
    timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {

      if(playTimeline){
        yearTimeline++;
        List temp = List.from(_markers);
        _markersShow = List.from(_markers);
        temp.removeWhere((element) => clubDetails.getFoundationYear(element.markerId.value) < yearTimeline);
        _markersShow.removeWhere((element) => temp.contains(element));
        if(removePreviousFoundedTeams){
          _markersShow.removeWhere((element) => clubDetails.getFoundationYear(element.markerId.value) < int.parse(controllerSimulationYear.text));
        }
        setState((){});
      }

      if (yearTimeline >= anoFinal) {
        yearTimeline = int.parse(controllerSimulationYear.text);
        showTimeline = false;
        timer.cancel();
      }
    });
  }

  Widget header(){
    return               Container(
      margin: const EdgeInsets.only(top:30),
      child: Row(
        children: [
          const SizedBox(width: 8),
          backButton(context),
          SizedBox(
            width: Sized(context).width*0.5,
            child: const Text('Mapa',overflow:TextOverflow.ellipsis,style: EstiloTextoBranco.text20),
          ),

          const Spacer(),

          showTimeline ?
          playTimeline ? GestureDetector(
            onTap: (){
              playTimeline = false;
              setState((){});
            },
            child: const Icon(Icons.pause,size:35,color:Colors.white),
          ) : GestureDetector(
            onTap: (){
              playTimeline = true;
              setState((){});
            },
            child: const Icon(Icons.play_arrow,size:35,color:Colors.white),
          )
              : Container(),


          Column(
            children: [

              //MOSTRAR ANO
              showTimeline ? Text(yearTimeline.toString(),style: EstiloTextoBranco.text14,) : Container(),

              //TIMELINE BUTTON
              GestureDetector(
                onTap: (){
                  showTimeline = true;
                  playTimeline = true;
                  yearTimeline = int.parse(controllerSimulationYear.text);
                  clubsFoundedTimelapse();
                  setState((){});
                },
                child: const Icon(Icons.timelapse,size:35,color:Colors.white),
              ),
            ],
          ),
          GestureDetector(
            onTap: (){
              filterBottomMessage();
              setState((){});
            },
            child: const Icon(Icons.filter_alt,size:35,color:Colors.white),
          ),

          const SizedBox(width: 10),

        ],
      ),
    );
  }
  Widget buttonZoomOut(){
    return GestureDetector(
      onTap: (){
        CameraUpdate zoom = CameraUpdate.zoomTo(5);
        controller.moveCamera(zoom);
      },
      child: Container(
        height: 50,
        width: 50,
        margin: const EdgeInsets.all(8),
        color: AppColors().greyTransparent,
        child: const Center(child: Text('Zoom Out',textAlign:TextAlign.center,style: EstiloTextoBranco.text14,)),
      ),
    );
  }
  Widget buttonZoomMedium(){
    return GestureDetector(
      onTap: (){
        CameraUpdate zoom = CameraUpdate.zoomTo(8);
        controller.moveCamera(zoom);
      },
      child: Container(
        height: 50,
        width: 80,
        margin: const EdgeInsets.all(8),
        color: AppColors().greyTransparent,
        child: const Center(child: Text('Zoom Medium',textAlign:TextAlign.center,style: EstiloTextoBranco.text14,)),
      ),
    );
  }

  onMarkerTap(String clubName) {

    return showModalBottomSheet(
        barrierColor: Colors.black.withAlpha(30),
        context: context, builder: (c){

        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(c);
        });
        return bottomSheetGenericClub(clubName);

    });
  }

  bottomSheetGenericClub(String clubName){
    return GestureDetector(
      onTap: () {
        //Zoom
        var newPosition = CameraPosition(
            target: LatLng(clubDetails.getCoordinate(clubName).latitude, clubDetails.getCoordinate(clubName).longitude),
            zoom: 16);
        CameraUpdate cameraUpdate = CameraUpdate.newCameraPosition(newPosition);
        controller.moveCamera(cameraUpdate);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        color: clubDetails.getColors(clubName).primaryColor.withOpacity(0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(clubDetails.getStadium(clubName)+': ',style: EstiloTextoPreto.text16),
                Text(clubDetails.getStadiumCapacity(clubName).toString()),
                const Spacer(),
                funcFlagsList(clubDetails.getCountry(clubName), 15, 25),
              ],
            ),
            Row(
              children: [
                Images().getUniformWidget(clubName,40,40),
                Images().getEscudoWidget(clubName),
                Text(clubName,style: EstiloTextoPreto.text20,),
                const Spacer(),
                Text(clubDetails.getFoundationYear(clubName).toString()),
              ],
            ),

          ],
        ),
      ),
    );
  }



  /////////////////////////////////////////////////////////////////////////////
  //FILTER

  Future filterBottomMessage(){
    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        context: context, builder: (c){
      return Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtrar por: ',style: EstiloTextoPreto.text22),
            GestureDetector(
                onTap:(){
                  Navigator.pop(c);
                  filterFoundationYearBottomSheet();
            },child: Container(padding:const EdgeInsets.all(10),child: const Text('Fundação',style: EstiloTextoPreto.text16))),

            GestureDetector(
                onTap:(){
                  Navigator.pop(c);
                  filterStadiumSizeBottomSheet();
            }, child: Container(padding:const EdgeInsets.all(10),child: const Text('Tamanho do estádio',style: EstiloTextoPreto.text16))),

            GestureDetector(
                onTap:(){
                  Navigator.pop(c);
                  filterCountryBottomSheet();
                },
                child: Container(padding:const EdgeInsets.all(10),child: const Text('País',style: EstiloTextoPreto.text16))),

            GestureDetector(
                onTap:(){
                  Navigator.pop(c);
                  filterSimulationStartYearBottomSheet();
                },
                child: Container(padding:const EdgeInsets.all(10),child: const Text('Ano Inicial de Simulação',style: EstiloTextoPreto.text16))),

            GestureDetector(
                onTap:(){
              _markersShow = List.from(_markers);
              setState((){});
              Navigator.pop(c);
            },child: Container(padding:const EdgeInsets.all(10),child: const Text('Restaurar Todos',style: EstiloTextoPreto.text16))),
          ],
        ),
      );
    }
    );
  }

  Future filterCountryBottomSheet(){

    List<DropdownMenuItem<String>> finalResultCountries = globalCountryNames.map((String dropDownStringItem) {
      return DropdownMenuItem<String>(
        value: dropDownStringItem,
        child: Text(dropDownStringItem),
      );
    }).toList();


    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        context: context, builder: (c){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            child: DropdownButton<String>(
              isExpanded: true,
              value: Words.country.brazil,
              items: finalResultCountries,
              onChanged: (Object? nationality) {
                _markersShow = List.from(_markers);
                _markersShow.removeWhere((element) => clubDetails.getCountry(element.markerId.value) != nationality.toString());
                setState((){});
                Navigator.pop(c);
              },
            ),
          ),
        ],
      );
    });
  }


  Future filterFoundationYearBottomSheet(){
    controllerMin.text = '1800';
    controllerMax.text = '2050';

    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        context: context, builder: (c){

      return Container(
        height: MediaQuery.of(context).viewInsets.bottom+50,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            const Text('Desde: ',style: EstiloTextoPreto.text20),
            const SizedBox(width: 10),
            widgetTextField(controllerMin,autofocus: true),
            const SizedBox(width: 20),
            const Text('Até: ',style: EstiloTextoPreto.text20),
            const SizedBox(width: 10),
            widgetTextField(controllerMax),
            const SizedBox(width: 20),

            GestureDetector(
                  onTap:() {
                    Navigator.pop(c);
                  _markersShow.removeWhere((element) => clubDetails.getFoundationYear(element.markerId.value) < int.parse(controllerMin.text));
                  _markersShow.removeWhere((element) => clubDetails.getFoundationYear(element.markerId.value) > int.parse(controllerMax.text));

                  },child: Container(
                    color: Colors.grey,
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('ok',style: EstiloTextoPreto.text20),
                  ),
            ),

              ]
        ),
      );
    });
  }

  Future filterSimulationStartYearBottomSheet(){
    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        context: context, builder: (c){

      return Container(
        height: MediaQuery.of(context).viewInsets.bottom+80,
        padding: const EdgeInsets.all(8.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              const Text('Ano Inicial: ',style: EstiloTextoPreto.text20),
              const SizedBox(width: 10),
              widgetTextField(controllerSimulationYear),
              const SizedBox(width: 20),

              GestureDetector(
                onTap:() {
                  Navigator.pop(c);
                  removePreviousFoundedTeams = true;
                },child: Container(
                color: Colors.red,
                padding: const EdgeInsets.all(8.0),
                child: const Text('Sim. 1',style: EstiloTextoPreto.text20),
              ),
              ),

              GestureDetector(
                onTap:() {
                  Navigator.pop(c);
                  removePreviousFoundedTeams = false;
                },child: Container(
                color: Colors.grey,
                padding: const EdgeInsets.all(8.0),
                child: const Text('Sim. 2',style: EstiloTextoPreto.text20),
              ),
              ),

            ]
        ),
      );
    });
  }

  Future filterStadiumSizeBottomSheet(){
    controllerStadiumMin.text = '0';
    controllerStadiumMax.text = '99900';

    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        context: context, builder: (c){

      return Container(
        height: MediaQuery.of(context).viewInsets.bottom+50,
        padding: const EdgeInsets.all(8.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              const Text('Min: ',style: EstiloTextoPreto.text20),
              const SizedBox(width: 10),
              widgetTextField(controllerStadiumMin,autofocus: true),
              const SizedBox(width: 20),
              const Text('Max: ',style: EstiloTextoPreto.text20),
              const SizedBox(width: 10),
              widgetTextField(controllerStadiumMax),
              const SizedBox(width: 20),

              GestureDetector(
                onTap:() {
                  Navigator.pop(c);
                  _markersShow.removeWhere((element) => clubDetails.getStadiumCapacity(element.markerId.value) < int.parse(controllerStadiumMin.text));
                  _markersShow.removeWhere((element) => clubDetails.getStadiumCapacity(element.markerId.value) > int.parse(controllerStadiumMax.text));

                },child: Container(
                color: Colors.grey,
                padding: const EdgeInsets.all(8.0),
                child: const Text('ok',style: EstiloTextoPreto.text20),
              ),
              ),

            ]
        ),
      );
    });
  }

  Widget widgetTextField(TextEditingController controller,{bool autofocus = false}) {
    return Container(
      height: 30,
      width: 50,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: Colors.grey,
        ),
      ),
      margin: const EdgeInsets.only(left: 4),
      child: TextField(
        autofocus: autofocus,
        textAlign: TextAlign.center,
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(border: InputBorder.none,),
      ),
    );
  }
}
