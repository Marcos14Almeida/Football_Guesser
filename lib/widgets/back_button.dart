import 'package:audioplayers/audioplayers.dart';
import 'package:map_game/class/size.dart';
import 'package:map_game/widgets/theme/textstyle.dart';
import 'package:flutter/material.dart';

Widget backButton(BuildContext context){
  return IconButton(
          onPressed: () async{
            await AudioPlayer().play(AssetSource("sounds/click.mp3"));
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios,color: Colors.white,size: 30),
  );
}

Widget backButtonText(BuildContext context, String text){
  return Container(
    margin: const EdgeInsets.only(top:30),
    child: Row(
      children: [
        const SizedBox(width: 8),
        backButton(context),
        SizedBox(
            width: Sized(context).width-100,
            child: Text(text,overflow:TextOverflow.ellipsis,style: EstiloTextoBranco.text20),
        ),
      ],
    ),
  );
}