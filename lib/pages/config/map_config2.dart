import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/pages/gameplay/map_gameplay_city_4clubs.dart';
import 'package:map_game/pages/gameplay/map_gameplay_stadium_4clubs.dart';
import 'package:map_game/pages/gameplay/map_gameplay_club_4stadium.dart';
import 'package:map_game/pages/gameplay/map_gameplay_logo.dart';
import 'package:map_game/pages/gameplay/map_gameplay_20markers.dart';
import 'package:map_game/widgets/theme/colors.dart';
import 'package:map_game/widgets/theme/textstyle.dart';
import 'package:map_game/widgets/back_button.dart';

class MapConfig2 extends StatefulWidget {
  final MapGameSettings mapGameSettings;
  const MapConfig2({Key? key, required this.mapGameSettings}) : super(key: key);

  @override
  State<MapConfig2> createState() => _MapConfig2State();
}

class _MapConfig2State extends State<MapConfig2> {
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
              Text(
                  'Modo: ' +
                      widget.mapGameSettings.selectedNivel +
                      " " +
                      widget.mapGameSettings.mode,
                  style: EstiloTextoBranco.negrito22),
              optionsRow(
                  'Estádio-time',
                  const Icon(Icons.stadium, color: Colors.white),
                  MapGameModeNames().estadioTime, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapGameplayStadium4Club(
                            mapGameSettings: widget.mapGameSettings)));
              }),
              optionsRow(
                  'Time-estádio',
                  const Icon(Icons.account_box, color: Colors.white),
                  MapGameModeNames().timeEstadio, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapGameplayClubStadium(
                            mapGameSettings: widget.mapGameSettings)));
              }),
              optionsRow(
                  'Markers',
                  const Icon(Icons.gps_fixed, color: Colors.white),
                  MapGameModeNames().markers, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapGameplayMarkers(
                            mapGameSettings: widget.mapGameSettings)));
              }),
              optionsRow('Logos', const Icon(Icons.adb, color: Colors.white),
                  MapGameModeNames().logos, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapGameplayLogo(
                            mapGameSettings: widget.mapGameSettings)));
              }),
              optionsRow(
                  'Location',
                  const Icon(Icons.location_on_rounded, color: Colors.white),
                  MapGameModeNames().logos, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameplayCity4Clubs(
                            mapGameSettings: widget.mapGameSettings)));
              }),
            ],
          ),
        ],
      ),
    );
  }
////////////////////////////////////////////////////////////////////////////
//                               WIDGETS                                  //
////////////////////////////////////////////////////////////////////////////

  Widget optionsRow(
      String text, Widget image, String gameplayName, Function function) {
    int nStars = 0;
    int maxStars = 1;

    nStars = widget.mapGameSettings.hasStar(
      nivel: widget.mapGameSettings.selectedNivel,
      mode: widget.mapGameSettings.mode,
      gameplayName: gameplayName,
    );

    int record = widget.mapGameSettings.getRecord(
        nivel: widget.mapGameSettings.selectedNivel,
        mode: widget.mapGameSettings.mode,
        gameplayName: gameplayName);

    String recordText = '${record.toString()}/' + MapGameModeNames().mapStarsValue(widget.mapGameSettings.mode).toString();

    return Container(
        margin: const EdgeInsets.all(8),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async{
                await AudioPlayer().play(AssetSource("sounds/click.mp3"));
                widget.mapGameSettings.gameplayName = gameplayName;
                function();
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: decorations(),
                  child: Row(
                    children: [
                      image,
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(text,style: EstiloTextoBranco.text20),
                          Text('Recorde: ' + recordText,style: EstiloTextoBranco.text12,),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.star,
                          color: nStars == maxStars ? Colors.yellow : Colors.white,
                      ),
                    ],
                  )),
            )));
  }

  BoxDecoration decorations() {
    return BoxDecoration(
        color: AppColors().greyTransparent,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          width: 2.0,
          color: Colors.greenAccent,
        ));
  }
}
