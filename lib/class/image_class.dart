import 'package:flutter/material.dart';
import 'package:map_game/class/countries_continents.dart';
import 'package:map_game/widgets/crest.dart';
import 'package:map_game/widgets/uniforme.dart';

class Images{

  String imageLogo(String timeFoto) {

    Map map = {};
    if(map.containsKey(timeFoto)){
      return map[timeFoto];
    }else{
      //Se o time não tiver uma imagem
      return 'generic';
    }
  }

  String getEscudo(String clubName){
    return 'assets/clubs/${imageLogo(clubName)}.png';
  }
  Widget getEscudoWidget(String clubName,[double _height=50.0, double _width=50.0]){
    String crest = imageLogo(clubName);
    if(crest != 'generic'){
      return Image.asset('assets/clubs/$crest.png',height: _height,width: _width);
    }else{
      return Padding(
        padding: EdgeInsets.only(left: _height*0.12,top: _height*0.13,bottom: _height*0.12),
        child: CrestWidgets(size: _height*0.7).getCrest(clubName),
      );
    }
  }


  String getUniform(String clubName){
    return 'assets/clubs/${imageLogo(clubName)}1.png';
  }
  Widget getUniformWidget(String clubName,[double _height=50.0, double _width=50.0]){
    String name = imageLogo(clubName);
    if(name != 'generic'){
      return Image.asset('assets/clubs/${name}1.png',height: _height,width: _width,
      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
        //Se o clube tem logo, mas não tiver a imagem do uniforme
        return UniformCustom(clubName,(_height/50)*0.45).kit();
      });
    }else{
      //Se o clube não tiver logo
      return UniformCustom(clubName,(_height/50)*0.45).kit();
    }
  }


  Widget getWallpaper(){
    return Image.asset('assets/icons/wallpaper.png',height: double.infinity,width: double.infinity,fit: BoxFit.fill);
  }

  String getMenuImages(String continent) {
    Map map = {};
    map[Continents().europa] = 'assets/continents/europe.png';
    map[Continents().americaSul] = 'assets/continents/south america.png';
    map[Continents().americaNorte] = 'assets/continents/north america.png';
    map[Continents().asia] = 'assets/continents/asia.png';
    map[Continents().africa] = 'assets/continents/africa.png';
    map[Continents().oceania] = 'assets/continents/asia.png';


      return map[continent];

  }

}
