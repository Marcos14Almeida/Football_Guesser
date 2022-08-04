import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/pages/config/map_config2.dart';
import 'package:map_game/pages/map_list_all_clubs.dart';
import 'package:map_game/widgets/theme/colors.dart';
import 'package:map_game/widgets/theme/textstyle.dart';
import 'package:map_game/widgets/back_button.dart';

class MapConfig1 extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const MapConfig1({Key? key, required this.mapGameSettings}) : super(key: key);

  @override
  State<MapConfig1> createState() => _MapConfig1State();
}

class _MapConfig1State extends State<MapConfig1> {

////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
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
              backButtonText(context, 'Configurações'),

              Text('Modo: '+widget.mapGameSettings.selectedNivel,style: EstiloTextoBranco.negrito22),

              optionsRow('Normal',Icons.now_widgets_rounded,MapGameModeNames().mode4options,(){
                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig2(mapGameSettings: widget.mapGameSettings)));
              }),
              optionsRow('1 minuto',Icons.timelapse,MapGameModeNames().mode1minute,(){
                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig2(mapGameSettings: widget.mapGameSettings)));
              }),
              optionsRow('Sem errar',Icons.error,MapGameModeNames().modeSemErrar,(){
                Navigator.push(context,MaterialPageRoute(builder: (context) => MapConfig2(mapGameSettings: widget.mapGameSettings)));
              }),

              const Spacer(),
              optionsRow('Lista de Clubes',Icons.list_alt,MapGameModeNames().modeSemErrar,(){
                Navigator.push(context,MaterialPageRoute(builder: (context) => MapListAllClubs(mapGameSettings: widget.mapGameSettings)));
              },
              hasStar: false,
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

  Widget optionsRow(String text, IconData icon, String mode, Function function, {bool hasStar = true}){
    int nStars = 0;
    int maxStars = 4;

    nStars = widget.mapGameSettings.hasStars3(
      nivel: widget.mapGameSettings.selectedNivel,
      mode: mode,
    );

    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
           onTap: () async{
             await AudioPlayer().play(AssetSource("sounds/click.mp3"));
             widget.mapGameSettings.mode = mode;
            function();
          },
          child: Container(
              padding: const EdgeInsets.all(8),
            decoration: decorations(),
              child: Row(
            children: [
              Icon(icon,color: Colors.white,size: 35),
              const SizedBox(width: 8),
              Text(text,style: EstiloTextoBranco.text20,),
              const Spacer(),
              hasStar ? Icon(Icons.star,color: nStars == maxStars ? Colors.yellow : Colors.white) : Container(),
              hasStar ? Text(nStars.toString()+'/'+maxStars.toString(),textAlign:TextAlign.center,style: EstiloTextoBranco.text14) : Container(),

            ],
          )
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

}
