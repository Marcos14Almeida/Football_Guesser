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
  int points = 5;

////////////////////////////////////////////////////////////////////////////
//                               INIT                                     //
////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
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
                Text(widget.mapGameSettings.selectedNivel,style: EstiloTextoBranco.text16),
                Text(widget.mapGameSettings.gameplayName,style: EstiloTextoBranco.text16),
                Text(widget.mapGameSettings.mode,style: EstiloTextoBranco.text16),
                const SizedBox(height: 35),
                const Text('Pontuação final',style: EstiloTextoBranco.negrito18),
                Text(widget.gameplay.nCorrect.toString(),style: EstiloTextoBranco.text40),
                const Text('Tempo',style: EstiloTextoBranco.negrito18),
                Text(widget.gameplay.milis.toString()+'s',style: EstiloTextoBranco.text40),

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
