import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/class/countries_continents.dart';
import 'package:map_game/class/flags_list.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/words.dart';
import 'package:map_game/widgets/theme/colors.dart';
import 'package:map_game/widgets/theme/textstyle.dart';
import 'package:map_game/values/club_details.dart';
import 'package:map_game/widgets/back_button.dart';

class MapListAllClubs extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const MapListAllClubs({Key? key, required this.mapGameSettings}) : super(key: key);

  @override
  State<MapListAllClubs> createState() => _MapListAllClubsState();
}

class _MapListAllClubsState extends State<MapListAllClubs> {

  List<String> countryOptions = [];
  String selectedCountry = Words.country.brazil;
  ClubDetails clubDetails = ClubDetails();
  Iterable keysIterable = ClubDetails().map.keys;
  late Iterable showList;
////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    getFlagsList();
    super.initState();
  }
  getFlagsList(){
    countryOptions = [];

    showList = keysIterable;
    showList = showList.where((clubName) => clubDetails.getCoordinate(clubName).latitude != 0);
    showList = showList.where((clubName) => clubDetails.getStadiumCapacity(clubName) > widget.mapGameSettings.stadiumSizeMin);
    showList = showList.where((clubName) => clubDetails.getStadiumCapacity(clubName) < widget.mapGameSettings.stadiumSizeMax);

    clubDetails.map.forEach((key, value) {
      if(showList.contains(key)) {
        if (!countryOptions.contains(clubDetails.getCountry(key))) {
          String continent = Continents().funcCountryContinents(
              clubDetails.getCountry(key));
          if (widget.mapGameSettings.selectedContinents.contains(continent)) {
            countryOptions.add(clubDetails.getCountry(key));
          }
        }
      }
    });
    selectedCountry = countryOptions.first;
    setState((){});
    countryOptions.sort();
    setState((){});
  }

////////////////////////////////////////////////////////////////////////////
//                               BUILD                                    //
////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    //Filtra os clubes do país
    showList = keysIterable.where((clubName) => selectedCountry == clubDetails.getCountry(clubName));
    showList = showList.where((clubName) => clubDetails.getCoordinate(clubName).latitude != 0);
    showList = showList.where((clubName) => clubDetails.getStadiumCapacity(clubName) > widget.mapGameSettings.stadiumSizeMin);
    showList = showList.where((clubName) => clubDetails.getStadiumCapacity(clubName) < widget.mapGameSettings.stadiumSizeMax);

    return Scaffold(
      body: Stack(
        children: [
          Images().getWallpaper(),

          Column(
            children: [
              Row(
                children: [
                  backButtonText(context, 'Clubes - '+selectedCountry),
                  const Spacer(),
                  Padding(padding:const EdgeInsets.only(top:18),
                      child: Text(showList.length.toString(),style: EstiloTextoBranco.text20)),
                  const SizedBox(width: 8),
                ],
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.builder(
                      itemCount: showList.length,
                      itemBuilder: (c,i)=>clubRow(showList.elementAt(i))
                  ),
                ),
              ),
              selectCountryRow(),

            ],
          ),
        ],
      ),
    );
  }
////////////////////////////////////////////////////////////////////////////
//                               WIDGETS                                  //
////////////////////////////////////////////////////////////////////////////
  Widget clubRow(String clubName){
    return GestureDetector(
      onTap: (){
          showClubMap(clubName);
        },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: clubDetails.getColors(clubName).primaryColor.withOpacity(0.2),
        child: Stack(
              children: [

                //LOGO DE FUNDO OPACA
                // SizedBox(
                //   height: 100,width: 150,
                //   child: Opacity(
                //     opacity: 0.2,
                //     child: AspectRatio(
                //       aspectRatio: 350 / 451,
                //       child: Container(
                //         decoration: BoxDecoration(
                //             image: DecorationImage(
                //               fit: BoxFit.fitWidth,
                //               alignment: FractionalOffset.center,
                //               image: AssetImage(Images().getEscudo(clubName)),
                //             )
                //         ),
                //       ),
                //     ),
                //   ),
                // ),


                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Images().getEscudoWidget(clubName,50,50),

                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(clubName,overflow: TextOverflow.ellipsis,style: EstiloTextoBranco.negrito18)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        funcFlagsList(clubDetails.getCountry(clubName), 15, 25),
                                        const SizedBox(width: 16),
                                        Text(clubDetails.getFoundationYear(clubName).toString(),style: EstiloTextoBranco.text16),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          Row(
                            children: [
                              Text('(${clubDetails.getStadiumCapacityPointFormat(clubName).toString()}) ',style: EstiloTextoBranco.text16),
                              Expanded(child: Text(clubDetails.getStadium(clubName),maxLines: 2,overflow: TextOverflow.ellipsis,style: EstiloTextoBranco.text14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                //UNIFORME
                Padding(
                    padding: const EdgeInsets.only(left:300,top: 10),
                    child: Images().getUniformWidget(clubName,80,100)
                ),


              ],
            ),
      ),
    );
  }

  Widget selectCountryRow(){
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors().greyTransparent,
      ),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: countryOptions.length,
          itemBuilder: (c,i)=>countrySelection(countryOptions[i])
      ),
    );
  }
  Widget countrySelection(String country){
    return GestureDetector(
      onTap: (){
        selectedCountry = country;
        setState((){});
      },
      child: Center(
          child: Container(
            height: 60,
            color: country == selectedCountry ? Colors.green[300] : Colors.transparent,
           padding: const EdgeInsets.symmetric(horizontal: 2.0,vertical: 10),
            child: funcFlagsList(country, 40, 50),
      )),
    );
  }

  showClubMap(String clubName){
   return         showModalBottomSheet(
       barrierColor: Colors.transparent,
       context: context, builder: (c)
   {
     List<Marker> _markers =          [
       Marker(
        markerId: MarkerId(clubName),
        position: LatLng(clubDetails.getCoordinate(clubName).latitude, clubDetails.getCoordinate(clubName).longitude),
        infoWindow: InfoWindow(title: clubName),
        //icon: clubsAllNameList.indexOf(clubName) < 40 ? _markersIcons[clubsAllNameList.indexOf(clubName)] : BitmapDescriptor.defaultMarker,
     )];
     return SizedBox(
       height: 300,
       child: Stack(
         children: [

           Expanded(
             child: GoogleMap(
               mapType: MapType.satellite,
               tiltGesturesEnabled: false,
               indoorViewEnabled: false,
               rotateGesturesEnabled: false,
               //zoomGesturesEnabled: false, //SEM ZOOM
               //zoomControlsEnabled: false, //SEM ZOOM
               initialCameraPosition: CameraPosition(
                 target: LatLng(clubDetails.getCoordinate(clubName).latitude, clubDetails.getCoordinate(clubName).longitude),
                 zoom: 15.0,
               ),
               //onMapCreated: getClubsLocation,
               markers: Set<Marker>.of(_markers),
             ),
           ),

           //MINI-MAP
           SizedBox(
             height: 100,width: 100,
             child: GoogleMap(
               mapType: MapType.satellite,
               tiltGesturesEnabled: false,
               indoorViewEnabled: false,
               rotateGesturesEnabled: false,
               zoomGesturesEnabled: false, //SEM ZOOM
               zoomControlsEnabled: false, //SEM ZOOM
               initialCameraPosition: CameraPosition(
                 target: LatLng(clubDetails.getCoordinate(clubName).latitude, clubDetails.getCoordinate(clubName).longitude),
                 zoom: 3.0,
               ),
               //onMapCreated: getClubsLocation,
               markers: Set<Marker>.of(_markers),
             ),
           ),

           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 Text(clubName,style: EstiloTextoBranco.negrito18),
                 Images().getEscudoWidget(clubName,25,25),
               ],
             ),
           ),


         ],
       ),
     );
   });
  }
}
