import 'package:converter_pro/ConversionPage.dart';
import 'package:converter_pro/Localization.dart';
import 'package:converter_pro/ReorderPage.dart';
import 'package:converter_pro/SettingsPage.dart';
import 'package:converter_pro/Utils.dart';
import 'package:converter_pro/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import "dart:convert";

bool isCurrencyLoading=true;

class ConversionManager extends StatefulWidget{
  @override
  _ConversionManager createState() => new _ConversionManager();

}

class _ConversionManager extends State<ConversionManager>{

  static final MAX_CONVERSION_UNITS=19;
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  var currencyValues={"CAD":1.4642,"HKD":8.7482,"RUB":71.5025,"PHP":57.58,"DKK":7.4631,"NZD":1.6888,"CNY":7.7173,"AUD":1.6058,"RON":4.72,"SEK":10.5973,"IDR":15824.37,"INR":76.8955,"BRL":4.2752,"USD":1.1215,"ILS":4.0095,"JPY":121.8,"THB":34.514,"CHF":1.1127,"CZK":25.509,"MYR":4.6436,"TRY":6.4304,"MXN":21.2581,"NOK":9.684,"HUF":324.66,"ZAR":15.8813,"SGD":1.5247,"GBP":0.89625,"KRW":1322.07,"PLN":4.253}; //base euro (aggiornato a 08/07/2019)

  static String lastUpdateCurrency="Last update: 2019-07-08";
  static List listaConversioni;
  static List listaColori=[Colors.red,Colors.deepOrange,Colors.amber,Colors.cyan, Colors.indigo,
  Colors.purple,Colors.blueGrey,Colors.green,Colors.pinkAccent,Colors.teal,
  Colors.blue, Colors.yellow.shade700, Colors.brown, Colors.lightGreenAccent, Colors.deepPurple,
  Colors.lightBlue, Colors.lime,Colors.yellow, Colors.orange];
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static List listaTitoli;
  static int _currentPage=0;
  static List orderLunghezza=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15];
  static List orderSuperficie=[0,1,2,3,4,5,6,7,8,9,10];
  static List orderVolume=[0,1,2,3,4,5,6,7,8,9,10,11,12,13];
  static List orderTempo=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14];
  static List orderTemperatura=[0,1,2,3,4,5,6];
  static List orderVelocita=[0,1,2,3,4];
  static List orderPrefissi=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20];
  static List orderMassa=[0,1,2,3,4,5,6,7,8,9];
  static List orderPressione=[0,1,2,3,4,5];
  static List orderEnergia=[0,1,2,3];
  static List orderAngoli=[0,1,2,3];
  static List orderValute=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29];
  static List orderScarpe=[0,1,2,3,4,5,6,7,8,9];
  static List orderDati=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26];
  static List orderPotenza=[0,1,2,3,4,5,6];
  static List orderForza=[0,1,2,3,4];
  static List orderTorque=[0,1,2,3,4];
  static List orderConsumo=[0,1,2,3];
  static List orderBasi=[0,1,2,3];
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static List listaOrder=[orderLunghezza,orderSuperficie, orderVolume,orderTempo,orderTemperatura,orderVelocita,orderPrefissi,orderMassa,orderPressione,orderEnergia,
  orderAngoli, orderValute, orderScarpe, orderDati, orderPotenza, orderForza, orderTorque, orderConsumo, orderBasi];
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  static List<Widget> listaDrawer=new List(MAX_CONVERSION_UNITS+1);//+1 perchè c'è l'intestazione
  static List<int> listaOrderDrawer=[0,1,2,4,5,6,17,7,11,12,14,3,15,16,13,8,18,9,10]; //fino a maxconversionunits-1
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  @override
  void initState() {
    super.initState();
    _getOrders();
    _getCurrency();
    bool stopRequestRating = prefs.getBool("stop_request_rating") ?? false;
    if(numero_volte_accesso>=5 && !stopRequestRating && getBoolWithProbability(30))
      _showRateDialog();
  }


  _leggiCurrenciesSalvate(){
    String currencyRead=prefs.getString("currencyRates");
    if(currencyRead!=null){
      CurrencyJSONObject currencyObject = new CurrencyJSONObject.fromJson(json.decode(currencyRead));
      currencyValues=currencyObject.rates;

      String lastUpdateRead=currencyObject.date;
      if(lastUpdateRead!=null)
        lastUpdateCurrency=MyLocalizations.of(context).trans('ultimo_update_valute')+lastUpdateRead;
    }
  }

  _getCurrency() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    String now = DateFormat("yyyy-MM-dd").format(DateTime.now());
   
    String dataFetched=prefs.getString("currencyRates");
    if(dataFetched==null || CurrencyJSONObject.fromJson(json.decode(dataFetched)).date!=now){//se non ho mai aggiornato oppure se non aggiorno la lista da piú di un giorno allora aggiorno
        try{
          final response =await http.get('https://api.exchangeratesapi.io/latest?symbols=USD,GBP,INR,CNY,JPY,CHF,SEK,RUB,CAD,KRW,BRL,HKD,AUD,NZD,MXN,SGD,NOK,TRY,ZAR,DKK,PLN,THB,MYR,HUF,CZK,ILS,IDR,PHP,RON');
          if (response.statusCode == 200) { //if successful

            CurrencyJSONObject currencyObject = new CurrencyJSONObject.fromJson(json.decode(response.body));
            currencyValues=currencyObject.rates;  

            //se tutte le richieste vanno a buon fine aggiorna la data di ultimo aggiornamento
            lastUpdateCurrency=MyLocalizations.of(context).trans('ultimo_update_valute')+MyLocalizations.of(context).trans('oggi');

            //salva in memoria
            prefs.setString("currencyRates", response.body);
          }
          else    //se ho un'errore nella lettura dati dal web (per es non sono connesso)
            _leggiCurrenciesSalvate();//leggi ultimi dati salvati

        }catch(e){//se ho un'errore di comunicazione
          print(e);
          _leggiCurrenciesSalvate(); //leggi ultimi dati salvati
      }
    }
    else{         //se ho già i dati alavati di oggi perchè sono già entrato la prima volta nell'app
      _leggiCurrenciesSalvate();
      lastUpdateCurrency=MyLocalizations.of(context).trans('ultimo_update_valute')+MyLocalizations.of(context).trans('oggi');
    }
    setState(() {
      isCurrencyLoading=false;
    });
  }

  void initializeTiles(){
    listaDrawer[0]=
        isLogoVisible ? 
          Container(
            decoration: BoxDecoration(color: Colors.red /*listaColori[_currentPage],*/),
            child:SafeArea(
              child: Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child:Image.asset("resources/images/logo.png"),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(color:Colors.red /*listaColori[_currentPage],*/),),
                  Container(
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.reorder,color: Colors.white,),
                          onPressed:(){
                            _changeOrderDrawer(context, MyLocalizations.of(context).trans('mio_ordinamento'), Colors.red/*listaColori[_currentPage]*/);
                          }
                        ),
                        IconButton(
                          icon:Icon(Icons.settings,color: Colors.white,),
                          onPressed: (){
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsPage()),
                            );
                          },
                        ),
                      ],
                    ),
                    height: 160.0,
                    alignment: FractionalOffset.bottomRight,
                  )  
                ]
            )
          ))
          :
          Container(
            decoration: BoxDecoration(color: listaColori[_currentPage],),
            child:SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.reorder,color: Colors.white,),
                    onPressed:(){
                      _changeOrderDrawer(context, MyLocalizations.of(context).trans('mio_ordinamento'), listaColori[_currentPage]);
                    }
                  ),
                  IconButton(
                    icon:Icon(Icons.settings,color: Colors.white,),
                    onPressed: (){
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
          ));

    listaDrawer[listaOrderDrawer[0]+1]=ListTileConversion(listaTitoli[0],"resources/images/lunghezza.png",listaColori[0],_currentPage==0,(){_onSelectItem(0);});
    listaDrawer[listaOrderDrawer[1]+1]=ListTileConversion(listaTitoli[1],"resources/images/area.png",listaColori[1],_currentPage==1,(){_onSelectItem(1);});
    listaDrawer[listaOrderDrawer[2]+1]=ListTileConversion(listaTitoli[2],"resources/images/volume.png",listaColori[2],_currentPage==2,(){_onSelectItem(2);});
    listaDrawer[listaOrderDrawer[3]+1]=ListTileConversion(listaTitoli[3],"resources/images/tempo.png",listaColori[3],_currentPage==3,(){_onSelectItem(3);});
    listaDrawer[listaOrderDrawer[4]+1]=ListTileConversion(listaTitoli[4],"resources/images/temperatura.png",listaColori[4],_currentPage==4,(){_onSelectItem(4);});
    listaDrawer[listaOrderDrawer[5]+1]=ListTileConversion(listaTitoli[5],"resources/images/velocita.png",listaColori[5],_currentPage==5,(){_onSelectItem(5);});
    listaDrawer[listaOrderDrawer[6]+1]=ListTileConversion(listaTitoli[6],"resources/images/prefissi.png",listaColori[6],_currentPage==6,(){_onSelectItem(6);});
    listaDrawer[listaOrderDrawer[7]+1]=ListTileConversion(listaTitoli[7],"resources/images/massa.png",listaColori[7],_currentPage==7,(){_onSelectItem(7);});
    listaDrawer[listaOrderDrawer[8]+1]=ListTileConversion(listaTitoli[8],"resources/images/pressione.png",listaColori[8],_currentPage==8,(){_onSelectItem(8);});
    listaDrawer[listaOrderDrawer[9]+1]=ListTileConversion(listaTitoli[9],"resources/images/energia.png",listaColori[9],_currentPage==9,(){_onSelectItem(9);});
    listaDrawer[listaOrderDrawer[10]+1]=ListTileConversion(listaTitoli[10],"resources/images/angoli.png",listaColori[10],_currentPage==10,(){_onSelectItem(10);});
    listaDrawer[listaOrderDrawer[11]+1]=ListTileConversion(listaTitoli[11],"resources/images/valuta.png",listaColori[11],_currentPage==11,(){_onSelectItem(11);});
    listaDrawer[listaOrderDrawer[12]+1]=ListTileConversion(listaTitoli[12],"resources/images/scarpe.png",listaColori[12],_currentPage==12,(){_onSelectItem(12);});
    listaDrawer[listaOrderDrawer[13]+1]=ListTileConversion(listaTitoli[13],"resources/images/dati.png",listaColori[13],_currentPage==13,(){_onSelectItem(13);});
    listaDrawer[listaOrderDrawer[14]+1]=ListTileConversion(listaTitoli[14],"resources/images/potenza.png",listaColori[14],_currentPage==14,(){_onSelectItem(14);});
    listaDrawer[listaOrderDrawer[15]+1]=ListTileConversion(listaTitoli[15],"resources/images/forza.png",listaColori[15],_currentPage==15,(){_onSelectItem(15);});
    listaDrawer[listaOrderDrawer[16]+1]=ListTileConversion(listaTitoli[16],"resources/images/torque.png",listaColori[16],_currentPage==16,(){_onSelectItem(16);});
    listaDrawer[listaOrderDrawer[17]+1]=ListTileConversion(listaTitoli[17],"resources/images/consumo.png",listaColori[17],_currentPage==17,(){_onSelectItem(17);});
    listaDrawer[listaOrderDrawer[18]+1]=ListTileConversion(listaTitoli[18],"resources/images/conversione_base.png",listaColori[18],_currentPage==18,(){_onSelectItem(18);});
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  }

  _onSelectItem(int index) {
    if(_currentPage!=index) {
      setState(() {
        _currentPage = index;
        Navigator.of(context).pop();
      });
    }
  }


  _saveOrders() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> toConvertList=new List();
    for(int item in listaOrder[_currentPage])
      toConvertList.add(item.toString());
    prefs.setStringList("conversion_$_currentPage", toConvertList);
  }
  _getOrders() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();

    //aggiorno lista del drawer
    List <String> stringList=prefs.getStringList("orderDrawer");
    setState((){
      if(stringList!=null){
        final int len=stringList.length;
        for(int i=0;i<len;i++){
          listaOrderDrawer[i]=int.parse(stringList[i]);
          if(listaOrderDrawer[i]==0)
             _currentPage=i;
        }
        //risolve il problema di aggiunta di unità dopo un aggiornamento
        for(int i=len;i<MAX_CONVERSION_UNITS;i++){
          listaOrderDrawer[i]=i;
        }
      }
    });


    //aggiorno ordine unità di ogni grandezza fisica
    for(int i=0;i<MAX_CONVERSION_UNITS;i++){
      stringList=prefs.getStringList("conversion_$i");

      if(stringList!=null){
        final int len=stringList.length;
        List intList=new List();
        for(int j=0;j<len;j++){
          intList.add(int.parse(stringList[j]));
        }
        //risolve il problema di aggiunta di unità dopo un aggiornamento
        for(int j=len; j<listaOrder[i].length;j++)     
          intList.add(j);
        
        if(i==_currentPage){
          setState(() {
            listaOrder[i]=intList;
          });
        }
        else
          listaOrder[i]=intList;

      }
    }
  }

  _changeOrderDrawer(BuildContext context,String title, Color color) async{

    //SharedPreferences prefs = await SharedPreferences.getInstance();
    Navigator.of(context).pop();

    List orderedList=new List(MAX_CONVERSION_UNITS);
    for(int i=0;i<MAX_CONVERSION_UNITS;i++){
      orderedList[listaOrderDrawer[i]]=listaTitoli[i];
    }


    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReorderPage(
            title: title,
            listaElementi: orderedList,
            color:color
        ),));

    List arrayCopia=new List(listaOrderDrawer.length);
    for(int i=0;i<listaOrderDrawer.length;i++)
      arrayCopia[i]=listaOrderDrawer[i];
    setState(() {
      for(int i=0;i<listaOrderDrawer.length;i++)
        listaOrderDrawer[i]=result.indexOf(arrayCopia[i]);
    });

    List<String> toConvertList=new List();
    for(int item in listaOrderDrawer)
      toConvertList.add(item.toString());
    prefs.setStringList("orderDrawer", toConvertList);

  }

  _changeOrderUnita(BuildContext context,String title, List listaStringhe, Color color) async{
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReorderPage(
            title: title,
            listaElementi: listaStringhe,
            color:color
        ),));
    List arrayCopia=new List(listaOrder[_currentPage].length);
    for(int i=0;i<listaOrder[_currentPage].length;i++)
      arrayCopia[i]=listaOrder[_currentPage][i];
    setState(() {
      for(int i=0;i<listaOrder[_currentPage].length;i++)
        listaOrder[_currentPage][i]=result.indexOf(arrayCopia[i]);
    });
    _saveOrders();
  }


  @override
  Widget build(BuildContext context) {

    Node metro=Node(name: MyLocalizations.of(context).trans('metro',),symbol:"[m]",order: listaOrder[0][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('centimetro'),symbol:"[cm]",order: listaOrder[0][1], leafNodes: [
            Node(isMultiplication: true, coefficientPer: 2.54, name: MyLocalizations.of(context).trans('pollice'),symbol:"[in]",order: listaOrder[0][2], leafNodes: [
              Node(isMultiplication: true, coefficientPer: 12.0, name: MyLocalizations.of(context).trans('piede'),symbol:"[ft]",order: listaOrder[0][3]),
            ]),
          ]),
          Node(isMultiplication: true, coefficientPer: 1852.0, name: MyLocalizations.of(context).trans('miglio_marino'),symbol:"[M]",order: listaOrder[0][4],),
          Node(isMultiplication: true, coefficientPer: 0.9144, name: MyLocalizations.of(context).trans('yard'),symbol:"[yd]",order: listaOrder[0][5], leafNodes: [
            Node(isMultiplication: true, coefficientPer: 1760.0, name: MyLocalizations.of(context).trans('miglio_terrestre'),symbol:"[mi]",order: listaOrder[0][6],),
          ]),
          Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millimetro'),symbol:"[mm]",order: listaOrder[0][7],),
          Node(isMultiplication: false, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('micrometro'),symbol:"[µm]", order: listaOrder[0][8],),
          Node(isMultiplication: false, coefficientPer: 1000000000.0, name: MyLocalizations.of(context).trans('nanometro'),symbol:"[nm]",order: listaOrder[0][9],),
          Node(isMultiplication: false, coefficientPer: 10000000000.0, name: MyLocalizations.of(context).trans('angstrom'),symbol:"[Å]",order: listaOrder[0][10],),
          Node(isMultiplication: false, coefficientPer: 1000000000000.0, name: MyLocalizations.of(context).trans('picometro'),symbol:"[pm]",order: listaOrder[0][11],),
          Node(isMultiplication: true, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('chilometro'),symbol:"[km]",order: listaOrder[0][12],leafNodes: [
            Node(isMultiplication: true, coefficientPer: 149597870.7, name: MyLocalizations.of(context).trans('unita_astronomica'),symbol:"[au]",order: listaOrder[0][13],leafNodes: [
              Node(isMultiplication: true, coefficientPer: 63241.1, name: MyLocalizations.of(context).trans('anno_luce'),symbol:"[ly]",order: listaOrder[0][14],leafNodes: [
                Node(isMultiplication: true, coefficientPer: 3.26, name: MyLocalizations.of(context).trans('parsec'),symbol:"[pc]",order: listaOrder[0][15],),
              ]),
            ]),
          ]),
        ]);

    Node metroq=Node(name: MyLocalizations.of(context).trans('metro_quadrato'),symbol:"[m²]",order: listaOrder[1][0],leafNodes: [
      Node(isMultiplication: false, coefficientPer: 10000.0, name: MyLocalizations.of(context).trans('centimetro_quadrato'),symbol:"[cm²]",order: listaOrder[1][1], leafNodes: [
        Node(isMultiplication: true, coefficientPer: 6.4516, name: MyLocalizations.of(context).trans('pollice_quadrato'),symbol:"[in²]",order: listaOrder[1][2], leafNodes: [
          Node(isMultiplication: true, coefficientPer: 144.0, name: MyLocalizations.of(context).trans('piede_quadrato'),symbol:"[ft²]",order: listaOrder[1][3]),
        ]),
      ]),
      Node(isMultiplication: false, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('millimetro_quadrato'),symbol:"[mm²]",order: listaOrder[1][4],),
      Node(isMultiplication: true, coefficientPer: 10000.0, name: MyLocalizations.of(context).trans('ettaro'),symbol:"[he]",order: listaOrder[1][5],),
      Node(isMultiplication: true, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('chilometro_quadrato'),symbol:"[km²]",order: listaOrder[1][6],),
      Node(isMultiplication: true, coefficientPer: 0.83612736, name: MyLocalizations.of(context).trans('yard_quadrato'),symbol:"[yd²]",order: listaOrder[1][7], leafNodes: [
        Node(isMultiplication: true, coefficientPer: 3097600.0, name: MyLocalizations.of(context).trans('miglio_quadrato'),symbol:"[mi²]",order: listaOrder[1][8]),
        Node(isMultiplication: true, coefficientPer: 4840.0, name: MyLocalizations.of(context).trans('acri'),symbol:"[ac]",order: listaOrder[1][9],),
      ]),
      Node(isMultiplication: true, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('ara'),symbol:"[a]",order: listaOrder[1][10],),
    ]);

    Node metroc=Node(name: MyLocalizations.of(context).trans('metro_cubo'),symbol:"[m³]",order: listaOrder[2][0],leafNodes: [
      Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('litro'),symbol:"[l]",order: listaOrder[2][1],leafNodes: [
        Node(isMultiplication: true, coefficientPer: 4.54609, name: MyLocalizations.of(context).trans('gallone_imperiale'),symbol:"[imp gal]",order: listaOrder[2][2],),
        Node(isMultiplication: true, coefficientPer: 3.785411784, name: MyLocalizations.of(context).trans('gallone_us'),symbol:"[US gal]",order: listaOrder[2][3],),
        Node(isMultiplication: true, coefficientPer: 0.56826125, name: MyLocalizations.of(context).trans('pinta_imperiale'),symbol:"[imp pt]",order: listaOrder[2][4],),
        Node(isMultiplication: true, coefficientPer: 0.473176473, name: MyLocalizations.of(context).trans('pinta_us'),symbol:"[US pt]",order: listaOrder[2][5],),
        Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millilitro'),symbol:"[ml]",order: listaOrder[2][6], leafNodes: [
          Node(isMultiplication: true, coefficientPer: 14.8, name: MyLocalizations.of(context).trans('tablespoon_us'),symbol:"[tbsp.]",order: listaOrder[2][7],),
          Node(isMultiplication: true, coefficientPer: 20.0, name: MyLocalizations.of(context).trans('tablespoon_australian'),symbol:"[tbsp.]",order:listaOrder[2][8],),
          Node(isMultiplication: true, coefficientPer: 240.0, name: MyLocalizations.of(context).trans('cup_us'),symbol:"[cup]",order: listaOrder[2][9],),
        ]),
      ]),
      Node(isMultiplication: false, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('centimetro_cubo'),symbol:"[cm³]",order: listaOrder[2][10], leafNodes: [
        Node(isMultiplication: true, coefficientPer: 16.387064, name: MyLocalizations.of(context).trans('pollice_cubo'),symbol:"[in³]",order: listaOrder[2][11], leafNodes: [
          Node(isMultiplication: true, coefficientPer: 1728.0, name: MyLocalizations.of(context).trans('piede_cubo'),symbol:"[ft³]",order: listaOrder[2][12],),
        ]),
      ]),
      Node(isMultiplication: false, coefficientPer: 1000000000.0, name: MyLocalizations.of(context).trans('millimetro_cubo'),symbol:"[mm³]",order: listaOrder[2][13],),
    ]);

    Node secondo=Node(name: MyLocalizations.of(context).trans('secondo'),symbol:"[s]",order: listaOrder[3][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 10.0, name: MyLocalizations.of(context).trans('decimo_secondo'),symbol:"[ds]",order: listaOrder[3][1],),
          Node(isMultiplication: false, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('centesimo_secondo'),symbol:"[cs]", order: listaOrder[3][2],),
          Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millisecondo'),symbol:"[ms]",order: listaOrder[3][3],),
          Node(isMultiplication: false, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('microsecondo'),symbol:"[µs]",order: listaOrder[3][4],),
          Node(isMultiplication: false, coefficientPer: 1000000000.0, name: MyLocalizations.of(context).trans('nanosecondo'),symbol:"[ns]",order: listaOrder[3][5],),
          Node(isMultiplication: true, coefficientPer: 60.0, name: MyLocalizations.of(context).trans('minuti'),symbol:"[min]",order: listaOrder[3][6],leafNodes: [
            Node(isMultiplication: true, coefficientPer: 60.0, name: MyLocalizations.of(context).trans('ore'),symbol:"[h]",order: listaOrder[3][7],leafNodes: [
              Node(isMultiplication: true, coefficientPer: 24.0, name: MyLocalizations.of(context).trans('giorni'),symbol:"[d]",order: listaOrder[3][8],leafNodes: [
                Node(isMultiplication: true, coefficientPer: 7.0, name: MyLocalizations.of(context).trans('settimane'),order: listaOrder[3][9],),
                Node(isMultiplication: true, coefficientPer: 365.0, name: MyLocalizations.of(context).trans('anno'),symbol:"[a]",order: listaOrder[3][10],leafNodes: [
                  Node(isMultiplication: true, coefficientPer: 5.0, name: MyLocalizations.of(context).trans('lustro'),order: listaOrder[3][11],),
                  Node(isMultiplication: true, coefficientPer: 10.0, name: MyLocalizations.of(context).trans('decade'),order: listaOrder[3][12],),
                  Node(isMultiplication: true, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('secolo'),symbol:"[c.]",order: listaOrder[3][13],),
                  Node(isMultiplication: true, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millennio'),order: listaOrder[3][14],),
                ]),
              ]),
            ]),
          ]),
        ]);

    Node celsius=Node(name: MyLocalizations.of(context).trans('fahrenheit'),symbol:"[°F]",order: listaOrder[4][0],leafNodes:[
      Node(isMultiplication: true, coefficientPer: 1.8, isSum: true, coefficientPlus: 32.0, name: MyLocalizations.of(context).trans('celsius'),symbol:"[°C]",order: listaOrder[4][1],leafNodes: [
        Node(isSum: false, coefficientPlus: 273.15, name: MyLocalizations.of(context).trans('kelvin'),symbol:"[K]",order: listaOrder[4][2],),
        Node(isMultiplication: true, coefficientPer: 5/4, name: "Reamur",symbol:"[°Re]",order: listaOrder[4][3],),
        Node(isMultiplication: true, coefficientPer: 40/21, isSum: true, coefficientPlus: -100/7,  name: "Rømer",symbol:"[°Rø]",order: listaOrder[4][4],),
        Node(isMultiplication: true, coefficientPer: -2/3, isSum: true, coefficientPlus: 100,  name: "Delisle",symbol:"[°De]",order: listaOrder[4][5],),
      ]),
      Node(isSum: false, coefficientPlus: 459.67, name: "Rankine",symbol:"[°R]",order: listaOrder[4][6],),
    ]);

    Node metri_secondo=Node(name: MyLocalizations.of(context).trans('metri_secondo'),symbol:"[m/s]", order: listaOrder[5][0], leafNodes: [
      Node(isMultiplication: false, coefficientPer: 3.6, name: MyLocalizations.of(context).trans('chilometri_ora'),symbol:"[km/h]",order: listaOrder[5][1], leafNodes:[
        Node(isMultiplication: true, coefficientPer: 1.609344, name: MyLocalizations.of(context).trans('miglia_ora'),symbol:"[mph]",order: listaOrder[5][2],),
        Node(isMultiplication: true, coefficientPer: 1.852, name: MyLocalizations.of(context).trans('nodi'),symbol:"[kts]",order: listaOrder[5][3],),
      ]),
      Node(isMultiplication: true, coefficientPer: 0.3048, name: MyLocalizations.of(context).trans('piedi_secondo'),symbol:"[ft/s]",order: listaOrder[5][4],),
    ]);

    Node SI=Node(name: "Base",symbol:"[10º]",order: listaOrder[6][0],
        leafNodes: [
          Node(isMultiplication: true, coefficientPer: 10.0, name: "Deca-",symbol:"[da][10¹]",order: listaOrder[6][1],),
          Node(isMultiplication: true, coefficientPer: 100.0, name: "Hecto-",symbol:"[h][10²]",order: listaOrder[6][2],),
          Node(isMultiplication: true, coefficientPer: 1000.0, name: "Kilo-",symbol:"[k][10³]",order: listaOrder[6][3],),
          Node(isMultiplication: true, coefficientPer: 1000000.0, name: "Mega-",symbol:"[M][10⁶]",order: listaOrder[6][4],),
          Node(isMultiplication: true, coefficientPer: 1000000000.0, name: "Giga-",symbol:"[G][10⁹]",order: listaOrder[6][5],),
          Node(isMultiplication: true, coefficientPer: 1000000000000.0, name: "Tera-",symbol:"[T][10¹²]",order: listaOrder[6][6],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000.0, name: "Peta-",symbol:"[P][10¹⁵]",order: listaOrder[6][7],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000000.0, name: "Exa-",symbol:"[E][10¹⁸]",order: listaOrder[6][8],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000000000.0, name: "Zetta-",symbol:"[Z][10²¹]",order: listaOrder[6][9],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000000000000.0, name: "Yotta-",symbol:"[Y][10²⁴]",order: listaOrder[6][10],),
          Node(isMultiplication: false, coefficientPer: 10.0, name: "Deci-",symbol:"[d][10⁻¹]",order: listaOrder[6][11],),
          Node(isMultiplication: false, coefficientPer: 100.0, name: "Centi-",symbol:"[c][10⁻²]",order: listaOrder[6][12],),
          Node(isMultiplication: false, coefficientPer: 1000.0, name: "Milli-",symbol:"[m][10⁻³]",order: listaOrder[6][13],),
          Node(isMultiplication: false, coefficientPer: 1000000.0, name: "Micro-",symbol:"[µ][10⁻⁶]",order: listaOrder[6][14],),
          Node(isMultiplication: false, coefficientPer: 1000000000.0, name: "Nano-",symbol:"[n][10⁻⁹]",order: listaOrder[6][15],),
          Node(isMultiplication: false, coefficientPer: 1000000000000.0, name: "Pico-",symbol:"[p][10⁻¹²]",order: listaOrder[6][16],),
          Node(isMultiplication: false, coefficientPer: 1000000000000000.0, name: "Femto-",symbol:"[f][10⁻¹⁵]",order: listaOrder[6][17],),
          Node(isMultiplication: false, coefficientPer: 1000000000000000000.0, name: "Atto-",symbol:"[a][10⁻¹⁸]",order: listaOrder[6][18],),
          Node(isMultiplication: false, coefficientPer: 1000000000000000000000.0, name: "Zepto-",symbol:"[z][10⁻²¹]",order: listaOrder[6][19],),
          Node(isMultiplication: false, coefficientPer: 1000000000000000000000000.0, name: "Yocto-",symbol:"[y][10⁻²⁴]",order: listaOrder[6][20],),
        ]
    );

    Node grammo=Node(name: MyLocalizations.of(context).trans('grammo'),symbol:"[g]",order: listaOrder[7][0],
      leafNodes: [
      Node(isMultiplication: true, coefficientPer: 100.0, name: MyLocalizations.of(context).trans('ettogrammo'),symbol:"[hg]",order: listaOrder[7][1],),
      Node(isMultiplication: true, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('chilogrammo'),symbol:"[kg]",order: listaOrder[7][2],leafNodes:[
        Node(isMultiplication: true, coefficientPer: 0.45359237, name: MyLocalizations.of(context).trans('libbra'),symbol:"[lb]",order: listaOrder[7][3],leafNodes: [
          Node(isMultiplication: false, coefficientPer: 16.0, name: MyLocalizations.of(context).trans('oncia'),symbol:"[oz]",order: listaOrder[7][4],)
        ]),
      ]),
      Node(isMultiplication: true, coefficientPer: 100000.0, name: MyLocalizations.of(context).trans('quintale'),order: listaOrder[7][5],),
      Node(isMultiplication: true, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('tonnellata'),symbol:"[t]",order: listaOrder[7][6],),
      Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('milligrammo'),symbol:"[mg]",order: listaOrder[7][7],),
      Node(isMultiplication: true, coefficientPer: 1.660539e-24, name: MyLocalizations.of(context).trans('uma'),symbol:"[u]",order: listaOrder[7][8],),
      Node(isMultiplication: true, coefficientPer: 0.2, name: MyLocalizations.of(context).trans('carato'),symbol:"[ct]",order: listaOrder[7][9],),
    ]);

    Node pascal=Node(name: MyLocalizations.of(context).trans('pascal'),symbol:"[Pa]",order: listaOrder[8][0],
        leafNodes: [
          Node(isMultiplication: true, coefficientPer: 101325.0, name: MyLocalizations.of(context).trans('atmosfere'),symbol:"[atm]",order: listaOrder[8][1],leafNodes:[
            Node(isMultiplication: true, coefficientPer: 0.987, name: MyLocalizations.of(context).trans('bar'),symbol:"[bar]",order: listaOrder[8][2],leafNodes:[
              Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('millibar'),symbol:"[mbar]",order: listaOrder[8][3],),
            ]),
          ]),
          Node(isMultiplication: true, coefficientPer: 6894.757293168, name: MyLocalizations.of(context).trans('psi'),symbol:"[psi]",order: listaOrder[8][4],),
          Node(isMultiplication: true, coefficientPer: 133.322368421, name: MyLocalizations.of(context).trans('torr'),symbol:"(mmHg) [torr]",order: listaOrder[8][5],),
    ]);

    Node joule=Node(name: MyLocalizations.of(context).trans('joule'),symbol:"[J]",order: listaOrder[9][0],
        leafNodes: [
          Node(isMultiplication: true, coefficientPer: 4.1867999409, name: MyLocalizations.of(context).trans('calorie'),symbol:"[cal]",order: listaOrder[9][1]),
          Node(isMultiplication: true, coefficientPer: 3600000.0, name: MyLocalizations.of(context).trans('kilowattora'),symbol:"[kwh]",order: listaOrder[9][2],),
          Node(isMultiplication: true, coefficientPer: 1.60217646e-19, name: MyLocalizations.of(context).trans('elettronvolt'),symbol:"[eV]",order: listaOrder[9][3],),
        ]);
    Node gradi=Node(name:MyLocalizations.of(context).trans('gradi'),symbol:"[°]",order: listaOrder[10][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 60.0, name: MyLocalizations.of(context).trans('primi'),symbol:"[']",order: listaOrder[10][1]),
          Node(isMultiplication: false, coefficientPer: 3600.0, name: MyLocalizations.of(context).trans('secondi'),symbol:"['']",order: listaOrder[10][2]),
          Node(isMultiplication: true, coefficientPer: 57.295779513, name: MyLocalizations.of(context).trans('radianti'),symbol:"[rad]",order: listaOrder[10][3]),
    ]);

    Node EUR=Node(name:MyLocalizations.of(context).trans('EUR',),symbol:MyLocalizations.of(context).trans('eu'),order: listaOrder[11][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: currencyValues['USD'], name: MyLocalizations.of(context).trans('USD'),symbol:MyLocalizations.of(context).trans('us'),order: listaOrder[11][1]),
          Node(isMultiplication: false, coefficientPer: currencyValues['GBP'], name: MyLocalizations.of(context).trans('GBP'),symbol:MyLocalizations.of(context).trans('gb'),order: listaOrder[11][2]),
          Node(isMultiplication: false, coefficientPer: currencyValues['INR'], name: MyLocalizations.of(context).trans('INR'),symbol:MyLocalizations.of(context).trans('in'),order: listaOrder[11][3]),
          Node(isMultiplication: false, coefficientPer: currencyValues['CNY'], name: MyLocalizations.of(context).trans('CNY'),symbol:MyLocalizations.of(context).trans('cn'),order: listaOrder[11][4]),
          Node(isMultiplication: false, coefficientPer: currencyValues['JPY'], name: MyLocalizations.of(context).trans('JPY'),symbol:MyLocalizations.of(context).trans('jp'),order: listaOrder[11][5]),
          Node(isMultiplication: false, coefficientPer: currencyValues['CHF'], name: MyLocalizations.of(context).trans('CHF'),symbol:MyLocalizations.of(context).trans('ch'),order: listaOrder[11][6]),
          Node(isMultiplication: false, coefficientPer: currencyValues['SEK'], name: MyLocalizations.of(context).trans('SEK'),symbol:MyLocalizations.of(context).trans('se'),order: listaOrder[11][7]),
          Node(isMultiplication: false, coefficientPer: currencyValues['RUB'], name: MyLocalizations.of(context).trans('RUB'),symbol:MyLocalizations.of(context).trans('ru'),order: listaOrder[11][8]),
          Node(isMultiplication: false, coefficientPer: currencyValues['CAD'], name: MyLocalizations.of(context).trans('CAD'),symbol:MyLocalizations.of(context).trans('ca'),order: listaOrder[11][9]),
          Node(isMultiplication: false, coefficientPer: currencyValues['KRW'], name: MyLocalizations.of(context).trans('KRW'),symbol:MyLocalizations.of(context).trans('kr'),order: listaOrder[11][10]),
          Node(isMultiplication: false, coefficientPer: currencyValues['BRL'], name: MyLocalizations.of(context).trans('BRL'),symbol:MyLocalizations.of(context).trans('br'),order: listaOrder[11][11]),
          Node(isMultiplication: false, coefficientPer: currencyValues['HKD'], name: MyLocalizations.of(context).trans('HKD'),symbol:MyLocalizations.of(context).trans('hk'),order: listaOrder[11][12]),
          Node(isMultiplication: false, coefficientPer: currencyValues['AUD'], name: MyLocalizations.of(context).trans('AUD'),symbol:MyLocalizations.of(context).trans('au'),order: listaOrder[11][13]),
          Node(isMultiplication: false, coefficientPer: currencyValues['NZD'], name: MyLocalizations.of(context).trans('NZD'),symbol:MyLocalizations.of(context).trans('nz'),order: listaOrder[11][14]),
          Node(isMultiplication: false, coefficientPer: currencyValues['MXN'], name: MyLocalizations.of(context).trans('MXN'),symbol:MyLocalizations.of(context).trans('mx'),order: listaOrder[11][15]),
          Node(isMultiplication: false, coefficientPer: currencyValues['SGD'], name: MyLocalizations.of(context).trans('SGD'),symbol:MyLocalizations.of(context).trans('sg'),order: listaOrder[11][16]),
          Node(isMultiplication: false, coefficientPer: currencyValues['NOK'], name: MyLocalizations.of(context).trans('NOK'),symbol:MyLocalizations.of(context).trans('no'),order: listaOrder[11][17]),
          Node(isMultiplication: false, coefficientPer: currencyValues['TRY'], name: MyLocalizations.of(context).trans('TRY'),symbol:MyLocalizations.of(context).trans('tr'),order: listaOrder[11][18]),
          Node(isMultiplication: false, coefficientPer: currencyValues['ZAR'], name: MyLocalizations.of(context).trans('ZAR'),symbol:MyLocalizations.of(context).trans('za'),order: listaOrder[11][19]),
          Node(isMultiplication: false, coefficientPer: currencyValues['DKK'], name: MyLocalizations.of(context).trans('DKK'),symbol:MyLocalizations.of(context).trans('dk'),order: listaOrder[11][20]),
          Node(isMultiplication: false, coefficientPer: currencyValues['PLN'], name: MyLocalizations.of(context).trans('PLN'),symbol:MyLocalizations.of(context).trans('pl'),order: listaOrder[11][21]),
          Node(isMultiplication: false, coefficientPer: currencyValues['THB'], name: MyLocalizations.of(context).trans('THB'),symbol:MyLocalizations.of(context).trans('th'),order: listaOrder[11][22]),
          Node(isMultiplication: false, coefficientPer: currencyValues['MYR'], name: MyLocalizations.of(context).trans('MYR'),symbol:MyLocalizations.of(context).trans('my'),order: listaOrder[11][23]),
          Node(isMultiplication: false, coefficientPer: currencyValues['HUF'], name: MyLocalizations.of(context).trans('HUF'),symbol:MyLocalizations.of(context).trans('hu'),order: listaOrder[11][24]),
          Node(isMultiplication: false, coefficientPer: currencyValues['CZK'], name: MyLocalizations.of(context).trans('CZK'),symbol:MyLocalizations.of(context).trans('cz'),order: listaOrder[11][25]),
          Node(isMultiplication: false, coefficientPer: currencyValues['ILS'], name: MyLocalizations.of(context).trans('ILS'),symbol:MyLocalizations.of(context).trans('il'),order: listaOrder[11][26]),
          Node(isMultiplication: false, coefficientPer: currencyValues['IDR'], name: MyLocalizations.of(context).trans('IDR'),symbol:MyLocalizations.of(context).trans('id'),order: listaOrder[11][27]),
          Node(isMultiplication: false, coefficientPer: currencyValues['PHP'], name: MyLocalizations.of(context).trans('PHP'),symbol:MyLocalizations.of(context).trans('ph'),order: listaOrder[11][28]),
          Node(isMultiplication: false, coefficientPer: currencyValues['RON'], name: MyLocalizations.of(context).trans('RON'),symbol:MyLocalizations.of(context).trans('ro'),order: listaOrder[11][29]),
    ]);

    Node centimetri_scarpe=Node(name:MyLocalizations.of(context).trans('centimetro',), symbol: "[cm]",order: listaOrder[12][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 1.5, coefficientPlus: 1.5, isSum: false, name: MyLocalizations.of(context).trans('eu_cina'),order: listaOrder[12][1]),
          Node(isMultiplication: true, coefficientPer: 2.54, name: MyLocalizations.of(context).trans('pollice'),symbol: '[in]',order: listaOrder[12][2], 
          leafNodes: [
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 4, isSum: true, name: MyLocalizations.of(context).trans('uk_india_bambino'),order: listaOrder[12][3]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 8.3333333, name: MyLocalizations.of(context).trans('uk_india_uomo'),order: listaOrder[12][4]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 8.5, name: MyLocalizations.of(context).trans('uk_india_donna'),order: listaOrder[12][5]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 3.89, isSum: true, name: MyLocalizations.of(context).trans('usa_canada_bambino'),order: listaOrder[12][6]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 8.0, name: MyLocalizations.of(context).trans('usa_canada_uomo'),order: listaOrder[12][7]),
            Node(isMultiplication: false, coefficientPer: 3.0, coefficientPlus: 7.5, name: MyLocalizations.of(context).trans('usa_canada_donna'),order: listaOrder[12][8]),
          ]),
          Node(coefficientPlus: 1.5, isSum: false, name: MyLocalizations.of(context).trans('giappone'),order: listaOrder[12][9]),
          
    ]);

    Node bit=Node(name: "Bit",symbol: "[b]",order: listaOrder[13][0],
        leafNodes: [
          Node(isMultiplication: true, coefficientPer: 4.0, name: "Nibble",order: listaOrder[13][2],),
          Node(isMultiplication: true, coefficientPer: 1000.0, name: "Kilobit",symbol: "[kb]",order: listaOrder[13][3],),
          Node(isMultiplication: true, coefficientPer: 1000000.0, name: "Megabit",symbol: "[Mb]",order: listaOrder[13][7],),
          Node(isMultiplication: true, coefficientPer: 1000000000.0, name: "Gigabit",symbol: "[Gb]",order: listaOrder[13][11],),
          Node(isMultiplication: true, coefficientPer: 1000000000000.0, name: "Terabit",symbol: "[Tb]",order: listaOrder[13][15],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000.0, name: "Petabit",symbol: "[Pb]",order: listaOrder[13][19],),
          Node(isMultiplication: true, coefficientPer: 1000000000000000000.0, name: "Exabit",symbol: "[Eb]",order: listaOrder[13][23],),
          Node(isMultiplication: true, coefficientPer: 1024.0, name: "Kibibit",symbol: "[Kibit]",order: listaOrder[13][5],leafNodes: [
            Node(isMultiplication: true, coefficientPer: 1024.0, name: "Mebibit",symbol: "[Mibit]",order: listaOrder[13][9],leafNodes: [
              Node(isMultiplication: true, coefficientPer: 1024.0, name: "Gibibit",symbol: "[Gibit]",order: listaOrder[13][13],leafNodes: [
                Node(isMultiplication: true, coefficientPer: 1024.0, name: "Tebibit",symbol: "[Tibit]",order: listaOrder[13][17],leafNodes: [
                  Node(isMultiplication: true, coefficientPer: 1024.0, name: "Pebibit",symbol: "[Pibit]",order: listaOrder[13][21],leafNodes: [
                    Node(isMultiplication: true, coefficientPer: 1024.0, name: "Exbibit",symbol: "[Eibit]",order: listaOrder[13][25])
                  ])
                ])
              ])
            ])
          ]),
          Node(isMultiplication: true, coefficientPer: 8.0, name: "Byte",symbol: "[B]",order: listaOrder[13][1],leafNodes: [
            Node(isMultiplication: true, coefficientPer: 1000.0, name: "Kilobyte",symbol: "[kB]",order: listaOrder[13][4],),
            Node(isMultiplication: true, coefficientPer: 1000000.0, name: "Megabyte",symbol: "[MB]",order: listaOrder[13][8],),
            Node(isMultiplication: true, coefficientPer: 1000000000.0, name: "Gigabyte",symbol: "[GB]",order: listaOrder[13][12],),
            Node(isMultiplication: true, coefficientPer: 1000000000000.0, name: "Terabyte",symbol: "[TB]",order: listaOrder[13][16],),
            Node(isMultiplication: true, coefficientPer: 1000000000000000.0, name: "Petabyte",symbol: "[PB]",order: listaOrder[13][20],),
            Node(isMultiplication: true, coefficientPer: 1000000000000000000.0, name: "Exabyte",symbol: "[EB]",order: listaOrder[13][24],),
            Node(isMultiplication: true, coefficientPer: 1024.0, name: "Kibibyte",symbol: "[KiB]",order: listaOrder[13][6],leafNodes: [
              Node(isMultiplication: true, coefficientPer: 1024.0, name: "Mebibyte",symbol: "[MiB]",order: listaOrder[13][10],leafNodes: [
                Node(isMultiplication: true, coefficientPer: 1024.0, name: "Gibibyte",symbol: "[GiB]",order: listaOrder[13][14],leafNodes: [
                  Node(isMultiplication: true, coefficientPer: 1024.0, name: "Tebibyte",symbol: "[TiB]",order: listaOrder[13][18],leafNodes: [
                    Node(isMultiplication: true, coefficientPer: 1024.0, name: "Pebibyte",symbol: "[PiB]",order: listaOrder[13][22],leafNodes: [
                      Node(isMultiplication: true, coefficientPer: 1024.0, name: "Exbibyte",symbol: "[EiB]",order: listaOrder[13][26])
                    ])
                  ])
                ])
              ])
            ]),
          ]),
        ]
    );

    Node watt=Node(name: MyLocalizations.of(context).trans('watt'), symbol: "[W]",order: listaOrder[14][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('milliwatt'), symbol: "[W]",order: listaOrder[14][1],),
          Node(isMultiplication: true, coefficientPer: 1000.0, name: MyLocalizations.of(context).trans('kilowatt'), symbol: "[kW]",order: listaOrder[14][2],),
          Node(isMultiplication: true, coefficientPer: 1000000.0, name: MyLocalizations.of(context).trans('megawatt'), symbol: "[MW]",order: listaOrder[14][3],),
          Node(isMultiplication: true, coefficientPer: 1000000000.0, name: MyLocalizations.of(context).trans('gigawatt'), symbol: "[GW]",order: listaOrder[14][4],),
          Node(isMultiplication: true, coefficientPer: 735.49875, name: MyLocalizations.of(context).trans('cavallo_vapore_eurpeo'), symbol: "[hp(M)]",order: listaOrder[14][5],),
          Node(isMultiplication: true, coefficientPer: 745.69987158, name: MyLocalizations.of(context).trans('cavallo_vapore_imperiale'), symbol: "[hp(I)]",order: listaOrder[14][6],),
    ]);

    Node newton=Node(name: MyLocalizations.of(context).trans('newton'),symbol: "[N]",order: listaOrder[15][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 100000.0, name: MyLocalizations.of(context).trans('dyne'),symbol: "[dyn]",order: listaOrder[15][1],),
          Node(isMultiplication: true, coefficientPer: 4.4482216152605 , name: MyLocalizations.of(context).trans('libbra_forza'),symbol: "[lbf]",order: listaOrder[15][2],),
          Node(isMultiplication: true, coefficientPer: 9.80665, name: MyLocalizations.of(context).trans('kilogrammo_forza'),symbol: "[kgf]",order: listaOrder[15][3],),
          Node(isMultiplication: true, coefficientPer: 0.138254954376, name: MyLocalizations.of(context).trans('poundal'),symbol: "[pdl]",order: listaOrder[15][4],),
    ]);

    Node newton_metro=Node(name: MyLocalizations.of(context).trans('newton_metro'),symbol: "[N·m]",order: listaOrder[16][0],
        leafNodes: [
          Node(isMultiplication: false, coefficientPer: 100000.0, name: MyLocalizations.of(context).trans('dyne_metro'),symbol:"[dyn·m]",order: listaOrder[16][1],),
          Node(isMultiplication: false, coefficientPer: 0.7375621489 , name: MyLocalizations.of(context).trans('libbra_forza_piede'),symbol: "[lbf·ft]",order: listaOrder[16][2],),
          Node(isMultiplication: false, coefficientPer: 0.10196798205363515, name: MyLocalizations.of(context).trans('kilogrammo_forza_metro'),symbol: "[kgf·m]",order: listaOrder[16][3],),
          Node(isMultiplication: true, coefficientPer: 0.138254954376, name: MyLocalizations.of(context).trans('poundal_metro'),symbol: "[pdl·m]",order: listaOrder[16][4],),
    ]);

    Node chilometri_litro=Node(name: MyLocalizations.of(context).trans('chilometri_litro'),symbol: "[km/l]",order: listaOrder[17][0],
        leafNodes: [
          Node(conversionType: RECIPROCO_CONVERSION,coefficientPer: 100.0, name: MyLocalizations.of(context).trans('litri_100km'),symbol: "[l/100km]",order: listaOrder[17][1],),
          Node(coefficientPer: 0.4251437074 , name: MyLocalizations.of(context).trans('miglia_gallone_us'),symbol: "[mpg]",order: listaOrder[17][2],),
          Node(coefficientPer: 0.3540061899, name: MyLocalizations.of(context).trans('miglia_gallone_uk'),symbol: "[mpg]",order: listaOrder[17][3],),
    ]);

    Node base_decimale=Node(name: MyLocalizations.of(context).trans('decimale'),base: 10,keyboardType: KEYBOARD_NUMBER_INTEGER,symbol: "[₁₀]",order: listaOrder[18][0],
        leafNodes: [
          Node(conversionType: BASE_CONVERSION,base: 16,keyboardType: KEYBOARD_COMPLETE,name: MyLocalizations.of(context).trans('esadecimale'),symbol: "[₁₆]",order: listaOrder[18][1],),
          Node(conversionType: BASE_CONVERSION,base: 8,keyboardType: KEYBOARD_NUMBER_INTEGER, name: MyLocalizations.of(context).trans('ottale'),symbol: "[₈]",order: listaOrder[18][2],),
          Node(conversionType: BASE_CONVERSION,base: 2,keyboardType: KEYBOARD_NUMBER_INTEGER, name: MyLocalizations.of(context).trans('binario'),symbol: "[₂]",order: listaOrder[18][3],),
    ]);


    listaConversioni=[metro,metroq, metroc,secondo, celsius, metri_secondo,SI,grammo,pascal,joule,gradi,EUR, centimetri_scarpe,bit,watt,newton, newton_metro, chilometri_litro, base_decimale];
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    listaTitoli=[MyLocalizations.of(context).trans('lunghezza'),MyLocalizations.of(context).trans('superficie'),MyLocalizations.of(context).trans('volume'),
    MyLocalizations.of(context).trans('tempo'),MyLocalizations.of(context).trans('temperatura'),MyLocalizations.of(context).trans('velocita'),
    MyLocalizations.of(context).trans('prefissi_si'),MyLocalizations.of(context).trans('massa'),MyLocalizations.of(context).trans('pressione'),
    MyLocalizations.of(context).trans('energia'), MyLocalizations.of(context).trans('angoli'),MyLocalizations.of(context).trans('valuta'),
    MyLocalizations.of(context).trans('taglia_scarpe'),MyLocalizations.of(context).trans('dati_digitali'),MyLocalizations.of(context).trans('potenza'),
    MyLocalizations.of(context).trans('forza'), MyLocalizations.of(context).trans('momento'),MyLocalizations.of(context).trans('consumo_carburante'),
    MyLocalizations.of(context).trans('basi_numeriche')];
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    initializeTiles();

    List<Choice> choices = <Choice>[
      Choice(title: MyLocalizations.of(context).trans('riordina'), icon: Icons.reorder),
    ];

    return Scaffold(
      resizeToAvoidBottomPadding: false,  //per evitare che il fab salga quando clicco
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 5)]),
        child: BottomAppBar(
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Builder(builder: (context) {
                return IconButton(icon: Icon(Icons.menu,), onPressed: () {
                  Scaffold.of(context).openDrawer();
                });
              }),
              Row(children: <Widget>[
                IconButton(icon: Icon(Icons.clear,semanticLabel: 'Clear all',),
                  onPressed: () {
                    setState(() {
                      listaConversioni[_currentPage].ClearAllValues();
                    });
                  },),
                PopupMenuButton<Choice>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (Choice choice){
                    _changeOrderUnita(context, MyLocalizations.of(context).trans('mio_ordinamento'), listaConversioni[_currentPage].getStringOrderedNodiFiglio(), Colors.red/*listaColori[_currentPage]*/);
                  },
                  itemBuilder: (BuildContext context) {
                    return choices.map((Choice choice) {
                      return PopupMenuItem<Choice>(
                        value: choice,
                        child: Text(choice.title),
                      );
                    }).toList();
                  },
                ),
              ],)
            ],
        ),
    ),
      ),
      drawer: new Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: listaDrawer,
      ),
      ),
      body: SafeArea(child:ConversionPage(listaConversioni[_currentPage],listaTitoli[_currentPage], _currentPage==11 ? lastUpdateCurrency : "")),
      
      floatingActionButton: FloatingActionButton(
        child: Image.asset("resources/images/calculator.png",width: 30.0,),
        onPressed: (){
          _fabPressed();
        },
        
        elevation: 6.0,
        backgroundColor: Colors.red//listaColori[_currentPage],
      ),

    );
  }

  _fabPressed(){
    showModalBottomSheet<void>(context: context,
      builder: (BuildContext context) {
        double displayWidth=MediaQuery.of(context).size.width;
        return Calculator(listaColori[_currentPage], displayWidth); 
      }
    );
  }

  void _showRateDialog() async {
    new Future.delayed(Duration.zero,() {
      showDialog(
        context: context,
        builder: (BuildContext dialogcontext) {
          return AlertDialog(
            title: new Text(MyLocalizations.of(context).trans('valuta_app')),
            content: new Text(MyLocalizations.of(context).trans('valuta_app2')),
            actions: <Widget>[
              new FlatButton(
                child: new Text(MyLocalizations.of(context).trans('gia_fatto')),
                onPressed: () {
                  prefs.setBool("stop_request_rating",true);
                  Navigator.of(dialogcontext).pop();
                },
              ),
              new FlatButton(
                child: new Text(MyLocalizations.of(context).trans('piu_tardi')),
                onPressed: () {
                  Navigator.of(dialogcontext).pop();
                },
              ),
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  launchURL("https://play.google.com/store/apps/details?id=com.ferrarid.converterpro");
                  Navigator.of(dialogcontext).pop();
                },
              ),
            ],
          );
        },
      );
      }
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class ListTileConversion extends StatefulWidget{
  String text;
  String imagePath;
  Color color;
  bool selected;
  Function onTapFunction;
  ListTileConversion(this.text, this.imagePath, this.color, this.selected,this.onTapFunction);

  @override
  _ListTileConversion createState() => new _ListTileConversion();
} 

class _ListTileConversion extends State<ListTileConversion>{



  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      child:ListTile(
        title: Row(children: <Widget>[
          Image.asset(widget.imagePath,width: 30.0,height: 30.0, color:  widget.selected ? Colors.red/*widget.color*/ : (MediaQuery.of(context).platformBrightness==Brightness.dark ? Color(0xFFCCCCCC) : Colors.black54),),
          SizedBox(width: 20.0,),
          Text(widget.text)
        ],),
        selected: widget.selected,
        onTap: widget.onTapFunction
      ),
      selectedColor: Colors.red//widget.color,
    );
  }
}