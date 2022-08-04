import 'package:flutter/material.dart';
import 'package:map_game/class/controller/gameplay_functions.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/widgets/theme/textstyle.dart';

Widget hearts(int nLifes){
  return Row(
    children: [
      nLifes >= 1 ? const Icon(Icons.heart_broken_rounded,color: Colors.red) : const Icon(Icons.heart_broken_outlined,color: Colors.white),
      nLifes >= 2 ? const Icon(Icons.heart_broken_rounded,color: Colors.red) : const Icon(Icons.heart_broken_outlined,color: Colors.white),
      nLifes == 3 ? const Icon(Icons.heart_broken_rounded,color: Colors.red) : const Icon(Icons.heart_broken_outlined,color: Colors.white),
    ],
  );
}

Widget gameInfosBar(Gameplay gameplay,MapGameSettings mapGameSettings, Widget objective){
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

        objective,

        Column(
          children: [
            Text('${gameplay.nCorrect}/${MapGameModeNames().mapStarsValue(mapGameSettings.mode)}',style: EstiloTextoBranco.text16),
            hearts(gameplay.nLifes),
          ],
        ),
      ],
    ),
  );
}