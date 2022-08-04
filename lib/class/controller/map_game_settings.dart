
import 'package:flutter/material.dart';
import 'package:map_game/class/countries_continents.dart';
import 'package:map_game/database/shared_preferences.dart';
import 'package:map_game/pages/gameplay/map_gameplay_stadium_4clubs.dart';
import 'package:map_game/pages/gameplay/map_gameplay_logo.dart';
import 'package:map_game/pages/gameplay/map_gameplay_20markers.dart';

import '../../pages/gameplay/map_gameplay_club_4stadium.dart';

class MapGameModeNames{

  String nivel1 = 'Nivel 1';
  String nivel2 = 'Nivel 2';
  String nivel3 = 'Nivel 3';

  String estadioTime = 'EstadioTime';
  String timeEstadio = 'TimeEstadio';
  String markers = 'Markers';
  String logos = 'Logos';

  String modeSemErrar = 'Sem Errar';
  String mode1minute = '1 minuto';
  String mode4options = 'Normal';

  mapStarsValue(String mode){
    Map map = {};
    map[modeSemErrar] = 10;
    map[mode1minute] = 20;
    map[mode4options] = 30;

    return map[mode];
  }

}

class MapGameSettings{
  List selectedContinents = [Continents().europa,Continents().americaSul,Continents().americaNorte,Continents().asia,Continents().africa];
  int difficulty = 0;
  String selectedNivel = '';
  int starCorrectValue = 0;
  int stadiumSizeMin = 0;
  int stadiumSizeMax = 200000;
  String mode = MapGameModeNames().mode1minute;
  String gameplayName = '';
  List<String> saveNames = [];
  List<String> records = [];

  setDifficulty(int i){
    difficulty = i;
    if(difficulty == 0 ){
      stadiumSizeMin = 0;
      stadiumSizeMax = 200000;
    }
    if(difficulty == 1 ){
      stadiumSizeMin = 45000;
      stadiumSizeMax = 100000;
    }
    if(difficulty == 2 ){
      stadiumSizeMin = 30000;
      stadiumSizeMax = 45000;
    }
    if(difficulty == 3 ){
      stadiumSizeMin = 0;
      stadiumSizeMax = 30000;
    }
  }

  playAgain(BuildContext context){
    if(gameplayName == MapGameModeNames().estadioTime){
      Navigator.push(context,MaterialPageRoute(builder: (context) => MapGameplayStadium4Club(mapGameSettings: this)));
    }
    else if(gameplayName == MapGameModeNames().timeEstadio){
      Navigator.push(context,MaterialPageRoute(builder: (context) => MapGameplayClubStadium(mapGameSettings: this)));
    }
    else if(gameplayName == MapGameModeNames().markers){
      Navigator.push(context,MaterialPageRoute(builder: (context) => MapGameplayMarkers(mapGameSettings: this)));
    }
    else if(gameplayName == MapGameModeNames().logos){
      Navigator.push(context,MaterialPageRoute(builder: (context) => MapGameplayLogo(mapGameSettings: this)));
    }
  }
  ///////////////////////////////////////////////////////
  int getRecord({required String nivel, required String mode,required String gameplayName}){
    int record = 0;
    for (var saveName in records) {
      if(saveName.contains(nivel) && saveName.contains(mode) && saveName.contains(gameplayName)){
        saveName = saveName.substring(saveName.length - 3);
        saveName = saveName.replaceAll(RegExp(r"\D"), "");
        record = int.parse(saveName);
      }
    }
    return record;
  }

  ///////////////////////////////////////////////////////
  saveKeys(int nCorrect) async {
    String nameToSave = selectedNivel+mode+gameplayName;

      //SALVA MELHOR PONTUAÇÃO
      records = await (SharedPreferenceHelper().getBestScore()) ?? [];
      for (var string in records) {
        //Verifica se contém um valor salvo
        if(!string.contains(nameToSave)) {
          //Se o nível ainda não tem uma pontuação
          saveScore(records, nameToSave, nCorrect);
        }else{
          int record = getRecord(nivel: selectedNivel, mode: mode, gameplayName: gameplayName);
          if(nCorrect > record){
            saveScore(records, nameToSave, nCorrect);
          }
        }
      }

  }

  getStarsNames(){
      int record = 0;
      saveNames = [];
      for (var saveName in records) {

        //Separate Upper case letters -> [Europa, Sem Errar, Logos23] -> 23 = recorde
          List splitted = saveName.split(RegExp(r"(?<=[a-z])(?=[A-Z])"));
          //Get final score
          String saveNameRecord = saveName.substring(saveName.length - 3);
          saveNameRecord = saveNameRecord.replaceAll(RegExp(r"\D"), "");
          record = int.parse(saveNameRecord);

        //SE GANHAR A estrela
        if((splitted[1] == MapGameModeNames().mode1minute ||
            splitted[1] == MapGameModeNames().modeSemErrar ||
            splitted[1] == MapGameModeNames().mode4options) && record>=MapGameModeNames().mapStarsValue(splitted[1])
        ){
            saveNames.add(saveName);
        }

      }
    }


  saveScore(List<String> bestScore, String nameToSave, int nCorrect){
    nameToSave += nCorrect.toString();
    bestScore.add(nameToSave);
    SharedPreferenceHelper().saveMapBestScore(bestScore);
  }

  Future getRecords() async{
    records = await (SharedPreferenceHelper().getBestScore()) ?? [];
  }

  int hasStar({required String nivel, required String mode,required String gameplayName}){
    int nStars = 0;
    for (var saveName in saveNames) {
      if(saveName.contains(nivel) && saveName.contains(mode) && saveName.contains(gameplayName)){
        nStars++;
      }
    }
    return nStars;
  }

  int hasStars3({required String nivel, required String mode}){
    int nStars = 0;
    for (var saveName in saveNames) {
      if(saveName.contains(nivel) && saveName.contains(mode)){
        nStars++;
      }
    }
    return nStars;
  }

  int hasStars9({required String nivel}){
    int nStars = 0;
    for (var saveName in saveNames) {
      if(saveName.contains(nivel)){
        nStars++;
      }
    }
    return nStars;
  }


}