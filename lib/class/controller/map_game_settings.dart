
import 'package:flutter/material.dart';
import 'package:map_game/class/countries_continents.dart';
import 'package:map_game/database/shared_preferences.dart';
import 'package:map_game/pages/gameplay/map_gameplay_city_4clubs.dart';
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
  String location = 'Location';

  String modeSemErrar = 'Sem Errar';
  String mode1minute = 'ContraRelogio';
  String mode4options = 'Normal';

  String you1 = 'Leigo';
  String you2 = 'Amador';
  String you3 = 'Juvenil';
  String you4 = 'Profissional';
  String you5 = 'Titular';
  String you6 = 'Craque';
  String you7 = 'Seleção';
  String you8 = 'GOAT';

  mapStarsValue(String mode){
    Map map = {};
    map[modeSemErrar] = 10;
    map[mode1minute] = 15;
    map[mode4options] = 20;

    return map[mode];
  }

  mapStarsValueYou(int stars){

    String frase = '';
    if(stars <5){return you1;}
    else if(stars <12*1){return you2;}
    else if(stars <12*2){return you3;}
    else if(stars <12*3){return you4;}
    else if(stars <12*4){return you5;}
    else if(stars <12*5){return you6;}
    else if(stars <12*6){return you7;}
    else if(stars <=12*8){return you8;}

    return frase;
  }

}

class MapGameSettings{

  List selectedContinents = [Continents().europa,Continents().americaSul,Continents().americaNorte,Continents().asia,Continents().africa];
  int difficulty = 0;
  String selectedNivel = '';
  int starCorrectValue = 0;
  double ovrMin = 0;
  double ovrMax = 100;
  String mode = MapGameModeNames().mode1minute;
  String gameplayName = '';
  List<String> starNames = [];
  List<String> records = [];
  int maxStars = 12;

  setDifficulty(int i){
    difficulty = i;
    if(difficulty == 0 ){
      //Modo sem nível
      ovrMin = 0;
      ovrMax = 100;
    }
    if(difficulty == 1 ){
      //FÁCIL
      ovrMin = 77;
      ovrMax = 100;
    }
    if(difficulty == 2 ){
      ovrMin = 70;
      ovrMax = 77;
    }
    if(difficulty == 3 ){
      ovrMin = 0;
      ovrMax = 70;
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
    else if(gameplayName == MapGameModeNames().location){
      Navigator.push(context,MaterialPageRoute(builder: (context) => GameplayCity4Clubs(mapGameSettings: this)));
    }
  }
  ///////////////////////////////////////////////////////
  int getRecord({required String nivel, required String mode,required String gameplayName}){
    int record = 0;
    for (String saveName in records) {
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
      bool containRecord = false;
      if(records.isEmpty){
        saveScore(records, nameToSave, nCorrect);
      }else{

        for (String string in records) {
          //Verifica se contém um valor salvo
          if(string.contains(nameToSave)) {
            containRecord = true;
            int record = getRecord(nivel: selectedNivel, mode: mode, gameplayName: gameplayName);
            if(nCorrect > record){
              records.remove(string); //remove a melhor pontuação anterior
              saveScore(records, nameToSave, nCorrect);
            }
          }
        }

        //Se o nível ainda não tem uma pontuação
        if(!containRecord){
          saveScore(records, nameToSave, nCorrect);
        }
      }

  }
  saveScore(List<String> records, String nameToSave, int nCorrect){
    nameToSave += nCorrect.toString();
    records.add(nameToSave);
    SharedPreferenceHelper().saveMapBestScore(records);
  }


  getStarsNames(){
    //SALVA OS RECORDES QUE TEM ESTRELA
      int record = 0;
      starNames = [];
      for (var saveName in records) {

        //Separate Upper case letters -> [Europa, Sem Errar, Logos23] -> 23 = recorde
          List splitted = saveName.split(RegExp(r"(?<=[1-9a-z])(?=[A-Z])"));
          //Get final score
          String saveNameRecord = saveName.substring(saveName.length - 3);
          saveNameRecord = saveNameRecord.replaceAll(RegExp(r"\D"), "");
          record = int.parse(saveNameRecord);

        //SE GANHAR A estrela
        if((splitted[1] == MapGameModeNames().mode1minute ||
            splitted[1] == MapGameModeNames().modeSemErrar ||
            splitted[1] == MapGameModeNames().mode4options
        ) && record>=MapGameModeNames().mapStarsValue(splitted[1])
        ){
          starNames.add(saveName);
        }

      }
    }


  Future getRecords() async{
    records = await (SharedPreferenceHelper().getBestScore()) ?? [];
  }

  bool hasStar({required int bestRecord}){
    bool hasStar = false;
    if(bestRecord >= MapGameModeNames().mapStarsValue(mode)){
      hasStar = true;
    }
    return hasStar;
  }

  int hasStars3({required String nivel, required String mode}){
    int nStars = 0;
    for (String saveName in starNames) {
      if(saveName.contains(nivel) && saveName.contains(mode)){
        nStars++;
      }
    }
    return nStars;
  }

  int hasStars9({required String nivel}){
    int nStars = 0;
    for (String saveName in starNames) {
      if(saveName.contains(nivel)){
        nStars++;
      }
    }
    return nStars;
  }


}