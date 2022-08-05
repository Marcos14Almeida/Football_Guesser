import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:map_game/class/controller/gameplay_functions.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/size.dart';
import 'package:map_game/pages/map_menu.dart';
import 'package:map_game/widgets/theme/textstyle.dart';

class EndGame extends StatefulWidget {
  final MapGameSettings mapGameSettings;final Gameplay gameplay;
  const EndGame({Key? key,required this.mapGameSettings, required this.gameplay}) : super(key: key);

  @override
  State<EndGame> createState() => _EndGameState();
}

class _EndGameState extends State<EndGame> {

////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    onInit();
    super.initState();
  }
  onInit() async{
    if(widget.mapGameSettings.hasStar(bestRecord: widget.gameplay.nCorrect)){
      await AudioPlayer().play(AssetSource("sounds/congrats.mp3"));
    }
    setState((){});
  }

////////////////////////////////////////////////////////////////////////////
//                               BUILD                                    //
////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    int record = widget.mapGameSettings.getRecord(nivel: widget.mapGameSettings.selectedNivel, mode: widget.mapGameSettings.mode, gameplayName: widget.mapGameSettings.gameplayName);

    return Scaffold(
      body: Stack(
        children: [
          Images().getWallpaper(),

          SizedBox(
            width: Sized(context).width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text('Fim da partida',style: EstiloTextoBranco.text30),
                const SizedBox(height: 35),
                const Text('Modo',style: EstiloTextoBranco.negrito18),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(widget.mapGameSettings.selectedNivel,textAlign:TextAlign.center,style: EstiloTextoBranco.text16),
                    Text(widget.mapGameSettings.gameplayName,textAlign:TextAlign.center,style: EstiloTextoBranco.text16),
                    Text(widget.mapGameSettings.mode,textAlign:TextAlign.center,style: EstiloTextoBranco.text16),
                  ],
                ),
                const SizedBox(height: 35),
                const Text('Pontuação final',style: EstiloTextoBranco.negrito18),
                Text(widget.gameplay.nCorrect.toString(),style: EstiloTextoBranco.text40),
                const Text('Tempo',style: EstiloTextoBranco.negrito18),
                Text(widget.gameplay.milis.toString()+'s',style: EstiloTextoBranco.text40),


                const SizedBox(height: 35),
                const Text('Seu recorde',style: EstiloTextoBranco.negrito18),
                Text(record.toString(),style: EstiloTextoBranco.text16),
                const Text('Para ganhar estrela',style: EstiloTextoBranco.negrito18),
                Text(widget.gameplay.nCorrect.toString()+'/'+MapGameModeNames().mapStarsValue(widget.mapGameSettings.mode).toString(),style: EstiloTextoBranco.text16),

                const SizedBox(height: 35),
                widget.mapGameSettings.hasStar(bestRecord: widget.gameplay.nCorrect)
                    ? Column(
                      children: const [
                        Icon(Icons.star,color: Colors.yellow, size:40),
                        Text('Nível conquistado',style: EstiloTextoBranco.negrito18),
                      ],
                    )
                    : Container(),



                const Spacer(),
                GestureDetector(
                  onTap: (){
                    widget.mapGameSettings.playAgain(context);
                  },
                  child: Container(
                    height: 60,width: Sized(context).width-40,
                    color: Colors.black38,
                    child: const Center(child: Text('REPETIR',style: EstiloTextoBranco.text22)),
                  ),
                ),

                const SizedBox(height: 10),
                GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const MapMenu()));
                  },
                  child: Container(
                      height: 60,width: Sized(context).width-40,
                      color: Colors.black38,
                      child: const Center(child: Text('MENU',style: EstiloTextoBranco.text22)),
                  ),
                ),
                const SizedBox(height: 35),

              ],
            ),
          ),

        ],
      ),
    );
  }
}
