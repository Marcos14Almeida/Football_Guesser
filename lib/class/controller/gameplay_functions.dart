import 'package:flutter/material.dart';
import 'package:map_game/class/controller/map_game_settings.dart';
import 'package:map_game/pages/end_game.dart';
import 'package:map_game/values/club_details.dart';
import 'package:audioplayers/audioplayers.dart';

class Gameplay{

  Iterable keysIterable = ClubDetails().map.keys;
  int nCorrect=0;
  int nLifes = 3;
  int milis=0;
  String objectiveClubName = 'Palmeiras';
  String guessedClubName = '';
  List wrongAnswers = [];
  List<String> listClubOptions = ['Palmeiras','Palmeiras','Palmeiras','Palmeiras'];

  boxColor(String clubName){
    Color color = Colors.white38;
    if(wrongAnswers.contains(clubName)){
      color = Colors.red;
    }else if(guessedClubName.contains(clubName)){
      color = Colors.green;
    }
    return color;
  }

  start(MapGameSettings mapGameSettings){
    if(mapGameSettings.mode == MapGameModeNames().modeSemErrar){
      nLifes = 1;
    }
    if(mapGameSettings.mode == MapGameModeNames().mode1minute){
      milis = 60;
      nLifes = -1;
    }
  }

  updateTimer(MapGameSettings mapGameSettings, BuildContext context){
    if(mapGameSettings.mode == MapGameModeNames().mode1minute){
      milis--;
      if(milis <= 0){
        gameOver(mapGameSettings, context);
        milis = 0;
      }
    }else{
      milis++;
    }
  }

  String getTimeStr(){
    int timeMin = (milis / 60).floor();
    int timeSec = milis % 60;
    String timeSecStr = timeSec.toString();
    if(timeSec<10){
      timeSecStr = '0' + timeSec.toString();
    }
    return '${timeMin.toString()}:$timeSecStr\'';
  }

  gameOver(MapGameSettings mapGameSettings, BuildContext context){
    mapGameSettings.saveKeys(nCorrect);
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => EndGame(mapGameSettings: mapGameSettings,gameplay: this)));
  }

  correct(MapGameSettings mapGameSettings, String clubName) async{
    nCorrect++;
    wrongAnswers = [];
    guessedClubName = clubName;
    await AudioPlayer().play(AssetSource("sounds/correct.mp3"));
  }

  lostLife(MapGameSettings mapGameSettings,String clubName) async {
    nLifes--;
    wrongAnswers.add(clubName);

    if(mapGameSettings.mode == MapGameModeNames().mode1minute){
      milis -= 5;
    }

    await AudioPlayer().play(AssetSource("sounds/error.mp3"));
  }

  bool isTeamPermitted(String clubName, MapGameSettings mapGameSettings,ClubDetails clubDetails){

    String continent = clubDetails.getContinent(clubName);
    double ovr = clubDetails.getOverall(clubName);
    if(clubDetails.getCoordinate(clubName).latitude != 0 &&
        mapGameSettings.selectedContinents.contains(continent) &&
        mapGameSettings.ovrMin <= ovr &&
        mapGameSettings.ovrMax > ovr
    ){
      return true;
    }
    return false;
  }

}
