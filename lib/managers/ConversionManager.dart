import 'package:converterpro/models/AppModel.dart';
import 'package:converterpro/models/Conversions.dart';
import 'package:converterpro/pages/ConversionPage.dart';
import 'package:converterpro/utils/Localization.dart';
import 'package:converterpro/utils/UnitsData.dart';
import 'package:converterpro/utils/Utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "dart:convert";
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map jsonSearch;

class ConversionManager extends StatelessWidget{

  final Function openDrawer;
  final List<String> titlesList;
  final bool showRateSnackBar;
  final String lastUpdateCurrency;

  ConversionManager({this.openDrawer, this.titlesList, this.showRateSnackBar, this.lastUpdateCurrency}) {
    /*if(!kIsWeb && showRateSnackBar){
          Future.delayed(const Duration(seconds: 5), () {
            _showReviewSnackBar();
          });
        }*/
  }
  
  final SearchDelegate _searchDelegate=CustomSearchDelegate();
  final GlobalKey<ScaffoldState> scaffoldKey =GlobalKey();

  _getJsonSearch(BuildContext context) async {
    jsonSearch ??= json.decode(await DefaultAssetBundle.of(context).loadString("resources/lang/${Localizations.localeOf(context).languageCode}.json"));
  }

  /*_showReviewSnackBar() async {

    final SnackBar positiveResponseSnackBar = SnackBar(
      duration: const Duration(milliseconds: 4000),
      behavior: SnackBarBehavior.floating,
      content: Text(MyLocalizations.of(context).trans('valuta_app3'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
      action: SnackBarAction(
        label: MyLocalizations.of(context).trans('valuta_app5'),
        textColor: Theme.of(context).accentColor,
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("stop_request_rating", true);
          launchURL("https://play.google.com/store/apps/details?id=com.ferrarid.converterpro");
        },
      ),
    );

    final SnackBar negativeResponseSnackBar = SnackBar(
      duration: const Duration(milliseconds: 3000),
      behavior: SnackBarBehavior.floating,
      content: Text(MyLocalizations.of(context).trans('valuta_app4'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0)),
      action: SnackBarAction(
        label: MyLocalizations.of(context).trans('valuta_app5'),
        textColor: Theme.of(context).accentColor,
        onPressed: ()async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("stop_request_rating", true);
          launchURL("https://play.google.com/store/apps/details?id=com.ferrarid.converterpro");
        },
      ),
    );

    final SnackBar reviewSnackBar = SnackBar(
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      content: SizedBox(
        height: 69.0,
        child: Center(
          child: Column(
            children: <Widget>[
              Text(MyLocalizations.of(context).trans('valuta_app2'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text(MyLocalizations.of(context).trans('valuta_app2NO'), style: TextStyle(color: Theme.of(context).accentColor),),
                    onPressed: (){
                      scaffoldKey.currentState.hideCurrentSnackBar();
                      scaffoldKey.currentState.showSnackBar(negativeResponseSnackBar);
                    },
                  ),
                  FlatButton(
                    child: Text(MyLocalizations.of(context).trans('valuta_app2SI'), style: TextStyle(color: Theme.of(context).accentColor),),
                    onPressed: (){
                      scaffoldKey.currentState.hideCurrentSnackBar();
                      scaffoldKey.currentState.showSnackBar(positiveResponseSnackBar);
                    },
                  ),
                ]
              )
            ],
          ),
        ),
      ),
    );
    scaffoldKey.currentState.showSnackBar(reviewSnackBar);
  }*/

  @override
  Widget build(BuildContext context) {
    _getJsonSearch(context);

    List<Choice> choices = <Choice>[
      Choice(title: MyLocalizations.of(context).trans('riordina'), icon: Icons.reorder),
    ];
    
    return Consumer2<AppModel,Conversions>(
        builder: (context, appModel, conversions, _) => Scaffold(
        key:scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: SafeArea(child:ConversionPage(conversions.conversionsList[appModel.currentPage], titlesList[appModel.currentPage], appModel.currentPage==11 ? lastUpdateCurrency : "", MediaQuery.of(context), conversions.isCurrenciesLoading)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Builder(builder: (context) {
                return IconButton(
                  tooltip: MyLocalizations.of(context).trans('menu'),
                  icon: Icon(Icons.menu,color: Colors.white,),
                  onPressed: () {
                    openDrawer();
                  });
              }),
              Row(children: <Widget>[
                IconButton(
                  tooltip: MyLocalizations.of(context).trans('elimina_tutto'),
                  icon: Icon(Icons.clear,color: Colors.white),
                  onPressed: () {
                    conversions.clearValues(appModel.currentPage);
                    //conversions.conversionsList[appModel.currentPage].clearAllValues();
                  },),
                IconButton(
                  tooltip: MyLocalizations.of(context).trans('cerca'),
                  icon: Icon(Icons.search,color: Colors.white,),
                  onPressed: () async {
                    final int newPage = await showSearch(context: context,delegate: _searchDelegate);
                    if(newPage!=null){
                      AppModel appModel = context.read<AppModel>();
                      if(appModel.currentPage != newPage) 
                        appModel.changeToPage(newPage);
                    }
                  },
                ),
                PopupMenuButton<Choice>(
                  icon: Icon(Icons.more_vert,color: Colors.white,),
                  onSelected: (Choice choice){
                    List<String> listTranslatedUnits = List();
                    for(String stringa in conversions.conversionsList[appModel.currentPage].getStringOrderedNodiFiglio())
                      listTranslatedUnits.add(MyLocalizations.of(context).trans(stringa));
                    conversions.changeOrderUnits(context, listTranslatedUnits, appModel.currentPage);
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
        
        floatingActionButton: FloatingActionButton(
          tooltip: MyLocalizations.of(context).trans('calcolatrice'),
          child: Image.asset("resources/images/calculator.png",width: 30.0,),
          onPressed: (){
            showModalBottomSheet<void>(context: context,
              builder: (BuildContext context) {
                double displayWidth=MediaQuery.of(context).size.width;
                return Calculator(Theme.of(context).accentColor, displayWidth); 
              }
            );
          },
          elevation: 5.0,
          backgroundColor: Theme.of(context).accentColor,//Color(0xff2196f3)//listaColori[currentPage],
        )
      ),
    );
  }
}


class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}


class CustomSearchDelegate extends SearchDelegate<int> {  

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
        final List<SearchUnit> _dataSearch=initializeSearchUnits((int pageNumber){close(context,pageNumber);}, jsonSearch);
        final List<SearchGridTile> allConversions=initializeGridSearch((int pageNumber) {close(context, pageNumber);}, jsonSearch, MediaQuery.of(context).platformBrightness==Brightness.dark);

        final Iterable<SearchUnit> suggestions = _dataSearch.where((searchUnit) => searchUnit.unitName.toLowerCase().contains(query.toLowerCase())); //.toLowercase per essere case insesitive
        
        return query.isNotEmpty ? SuggestionList(
          suggestions: suggestions.toList(),
          darkMode: MediaQuery.of(context).platformBrightness==Brightness.dark,
        )
        : GridView(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0),
          children: allConversions,
          
        );
      }
    
      @override
      Widget buildResults(BuildContext context) {
        return Container();
      }
    
      @override
      List<Widget> buildActions(BuildContext context) {
        return <Widget>[
          if(query.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            ),
        ];
      }
}
