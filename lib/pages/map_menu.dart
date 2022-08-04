
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:map_game/class/countries_continents.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/class/size.dart';
import 'package:map_game/pages/config/map_config1.dart';
import 'package:map_game/pages/map_exploration.dart';
import 'package:map_game/pages/map_list_all_clubs.dart';
import 'package:map_game/pages/settings/settings.dart';
import 'package:map_game/widgets/theme/colors.dart';
import 'package:map_game/widgets/theme/textstyle.dart';

class MapMenu extends StatefulWidget {
  const MapMenu({Key? key}) : super(key: key);

  @override
  State<MapMenu> createState() => _MapMenuState();
}

class _MapMenuState extends State<MapMenu> {


 MapGameSettings mapGameSettings = MapGameSettings();
 bool loaded = false;
////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    onInit();
    super.initState();
  }

  onInit() async{
    mapGameSettings = MapGameSettings();
    mapGameSettings.setDifficulty(0);
    await mapGameSettings.getRecords();
    mapGameSettings.getStarsNames();
    loaded=true;
    setState((){});
  }

////////////////////////////////////////////////////////////////////////////
//                               BUILD                                    //
////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    onInit();

    return Scaffold(
        body: Stack(
          children: [
            Images().getWallpaper(),

            Column(
              children: [
                const SizedBox(height: 35),
                const Text('FOOTBALL GUESSER',style: EstiloTextoBranco.text30),

                loaded ? Expanded(
                  child: Container(
                    width: Sized(context).width,
                    margin: const EdgeInsets.only(top: 12,left:12,right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.6,1],
                          colors: [
                            Colors.white24,
                            Colors.transparent,
                          ],
                        ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                              gameButton('Nível 1',MapGameModeNames().nivel1,(){
                                mapGameSettings.setDifficulty(1);
                                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig1(mapGameSettings: mapGameSettings)));
                              }),
                              gameButton('Nível 2',MapGameModeNames().nivel2,(){
                                mapGameSettings.setDifficulty(2);
                                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig1(mapGameSettings: mapGameSettings)));
                              }),
                              gameButton('Nível 3',MapGameModeNames().nivel3,(){
                                mapGameSettings.setDifficulty(3);
                                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig1(mapGameSettings: mapGameSettings)));
                              }),
                          const SizedBox(height: 12),
                              gameButton('Europa',Continents().europa,(){
                                mapGameSettings.selectedContinents = [Continents().europa];
                                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig1(mapGameSettings: mapGameSettings)));
                              }),
                              gameButton('América do Sul',Continents().americaSul,(){
                                mapGameSettings.selectedContinents = [Continents().americaSul];
                                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig1(mapGameSettings: mapGameSettings)));
                              }),
                              gameButton('América do Norte',Continents().americaNorte,(){
                                mapGameSettings.selectedContinents = [Continents().americaNorte];
                                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig1(mapGameSettings: mapGameSettings)));
                              }),
                              gameButton('África', Continents().africa,(){
                                mapGameSettings.selectedContinents = [Continents().africa];
                                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig1(mapGameSettings: mapGameSettings)));
                              }),
                              gameButton('Ásia',Continents().asia,(){
                                mapGameSettings.selectedContinents = [Continents().asia,Continents().oceania];
                                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig1(mapGameSettings: mapGameSettings)));
                              }),

                        ],
                      ),
                    ),
                  ),
                ) : Container(),


                Container(
                  margin: const EdgeInsets.only(left:8,right: 8,bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      gameButton2('Exploração Livre',Icons.map,(){Navigator.push(context,MaterialPageRoute(builder: (context) => const MapPage()));}),
                      gameButton2('Lista de Clubes',Icons.list_alt,(){Navigator.push(context,MaterialPageRoute(builder: (context) => MapListAllClubs(mapGameSettings: mapGameSettings)));}),
                      gameButton2('Configurações',Icons.settings,(){Navigator.push(context,MaterialPageRoute(builder: (context) => const Settings()));}),

                    ],
                  ),
                ),

              ],
            ),
          ],
        ),
    );
  }
////////////////////////////////////////////////////////////////////////////
//                               WIDGETS                                  //
////////////////////////////////////////////////////////////////////////////

Widget gameButton(String text, selectedNivel, Function function){
    int nStars = 0;
    int maxStars = 12;

    nStars = mapGameSettings.hasStars9(
      nivel: selectedNivel,
    );

    bool hasContinent = false;
    try{
      Images().getContinentLogo(selectedNivel);
      hasContinent = true;
    }catch(e){
      hasContinent = false;
    }

    return Container(
      width: Sized(context).width-50,
      margin: const EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async{
            await AudioPlayer().play(AssetSource("sounds/click.mp3"));
            mapGameSettings.selectedNivel = selectedNivel;
            function();
          },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: decorations(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              hasContinent ? Image.asset(Images().getContinentLogo(selectedNivel),height: 35,width: 35) : Container(width: 35),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(text,textAlign:TextAlign.center,style: EstiloTextoBranco.text20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star,color: nStars == maxStars ? Colors.yellow : Colors.white),
                        Text(nStars.toString()+'/'+maxStars.toString(),textAlign:TextAlign.center,style: EstiloTextoBranco.text14,),

                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
}


  BoxDecoration decorations(){
    return BoxDecoration(
        color: AppColors().greyTransparent,
  borderRadius: const BorderRadius.all(Radius.circular(5)),
  border: Border.all(
  width: 2.0,
  color: Colors.greenAccent,
  )
    );
}

  Widget gameButton2(String text, IconData icon, Function function){
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async{
          await AudioPlayer().play(AssetSource("sounds/click.mp3"));
          function();
        },
        child: Container(
          width: 120,
          height: 90,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors().greyTransparent,
              borderRadius: const BorderRadius.all(Radius.circular(5))
          ),
          child: Column(
            children: [
              Icon(icon,color: Colors.white,size: 35),
              Center(child: Text(text,textAlign:TextAlign.center,style: EstiloTextoBranco.text16,)),
            ],
          ),
        ),
      ),
    );
  }

}
