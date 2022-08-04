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
    AudioPlayer player = AudioPlayer();
    String audioasset = "sounds/correct.mp3";
    await player.play(AssetSource(audioasset));
  }

  lostLife(MapGameSettings mapGameSettings,String clubName) async {
    nLifes--;
    wrongAnswers.add(clubName);

    if(mapGameSettings.mode == MapGameModeNames().mode1minute){
      milis -= 5;
    }

    AudioPlayer player = AudioPlayer();
    String audioasset = "sounds/error.mp3";
    await player.play(AssetSource(audioasset));
  }

  bool isTeamPermitted(String clubName, MapGameSettings mapGameSettings,ClubDetails clubDetails){

    String continent = clubDetails.getContinent(clubName);
    int capacity = clubDetails.getStadiumCapacity(clubName);
    if(clubDetails.getCoordinate(clubName).latitude != 0 &&
        mapGameSettings.selectedContinents.contains(continent) &&
        mapGameSettings.stadiumSizeMin < capacity &&
        mapGameSettings.stadiumSizeMax > capacity
    ){
      return true;
    }
    return false;
  }

}
