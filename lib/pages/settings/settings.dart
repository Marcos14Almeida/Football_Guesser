import 'package:flutter/material.dart';
import 'package:map_game/class/image_class.dart';
import 'package:map_game/class/size.dart';
import 'package:map_game/database/shared_preferences.dart';
import 'package:map_game/widgets/back_button.dart';
import 'package:map_game/widgets/theme/colors.dart';
import 'package:map_game/widgets/theme/textstyle.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {



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

              button('Sobre', Icons.info_outline, (){
                bottomSheet('Seja o craque do futebol!!!\n\nAcerte onde fica cada estádio, descubra a qual clube pertence cada estádio, acerte o local de cada clube. Jogue diferentes níveis, com diferentes continentes e em diferentes modos para vencer o jogo e ser o GOAT de Football Guesser. \n\nGame feito com muito amor por Marcos P. Almeida em 08/2022. 😍💕!!!');
              }),
              button('Resetar o progresso', Icons.delete, (){
                resetProgressBottomSheet();
              }),
              button('Termos de Uso', Icons.note, (){

              }),
              button('Entre em contato', Icons.contact_mail, (){
                bottomSheet('Email: marcos.10palmeida@gmail.com');
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
  Widget button(String text, IconData icon, Function function){
    return Container(
      width: Sized(context).width-20,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (){
            function();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: decorations(),
            child: Row (
                    children: [
                      Icon(icon,color: Colors.grey,size: 35),
                      const SizedBox(width: 20),
                      Text(text,textAlign:TextAlign.center,style: EstiloTextoBranco.negrito18,),
                    ],
                  ),
                ),
            ),
          ),
        );
  }

  BoxDecoration decorations(){
    return BoxDecoration(
        color: AppColors().greyTransparent,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        border: Border.all(
          width: 2.0,
          color: Colors.greenAccent,
        )
    );
  }

  bottomSheet(String text){
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            color: Colors.greenAccent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text(text,textAlign: TextAlign.center)),
                  ),
                ],
              ),
            ),
          );
        });
  }

  resetProgressBottomSheet(){
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext c) {
          return Container(
            height: 200,
            color: Colors.greenAccent,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Deseja realmente apagar o seu progresso?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          child: const Text('Deletar'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                          onPressed: () {
                            SharedPreferenceHelper().saveMapBestScore([]);
                            Navigator.pop(c);
                            Navigator.pop(context);
                          }
                      ),
                    ],
                  ),

                ],
              ),
            ),
          );
        });
  }
}
