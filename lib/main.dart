import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'search_list.dart';
import 'package:intl/intl.dart';
import 'utilities.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autocomplete + Enhancements Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Autocomplete + Enhancements Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ArbitrarySuggestionType selectedItem;
  final TextEditingController _dateController = new TextEditingController();
  
  List<ArbitrarySuggestionType> searchSuggestions = [ 
    new ArbitrarySuggestionType(4.7, "Minamishima", "https://media-cdn.tripadvisor.com/media/photo-p/0f/25/de/0c/photo1jpg.jpg"), 
    new ArbitrarySuggestionType(1.5, "The Meat & Wine Co Hawthorn East", "https://media-cdn.tripadvisor.com/media/photo-s/12/ba/7d/4c/confit-cod-chorizo-red.jpg"), 
    new ArbitrarySuggestionType(3.4, "Florentino", "https://media-cdn.tripadvisor.com/media/photo-s/12/fc/bb/11/from-the-street.jpg"), 
    new ArbitrarySuggestionType(4.3, "Syracuse Restaurant & Winebar Melbourne CBD", "https://media-cdn.tripadvisor.com/media/photo-p/07/ad/76/b0/the-gyoza-had-a-nice.jpg"), 
    new ArbitrarySuggestionType(1.1, "Geppetto Trattoria", "https://media-cdn.tripadvisor.com/media/photo-s/0c/85/3d/cb/photo1jpg.jpg"), 
    new ArbitrarySuggestionType(3.4, "Cumulus Inc.", "https://media-cdn.tripadvisor.com/media/photo-s/0e/21/a0/be/photo0jpg.jpg"), 
    new ArbitrarySuggestionType(2.2, "Chin Chin", "https://media-cdn.tripadvisor.com/media/photo-s/0e/83/ec/07/triple-beef-triple-bacon.jpg"), 
    new ArbitrarySuggestionType(5.0, "Anchovy", "https://media-cdn.tripadvisor.com/media/photo-s/07/e7/f6/8e/daneli-s-kosher-deli.jpg"), 
    new ArbitrarySuggestionType(4.7, "Sezar Restaurant", "https://media-cdn.tripadvisor.com/media/photo-s/04/b8/23/d1/nevsky-russian-restaurant.jpg"), 
    new ArbitrarySuggestionType(2.6, "Tipo 00", "https://media-cdn.tripadvisor.com/media/photo-s/11/17/67/8c/front-seats.jpg"), 
    new ArbitrarySuggestionType(3.4, "Coda", "https://media-cdn.tripadvisor.com/media/photo-s/0d/b1/6a/84/photo0jpg.jpg"), 
    new ArbitrarySuggestionType(1.1, "Pastuso", "https://media-cdn.tripadvisor.com/media/photo-w/0a/d9/cf/52/photo4jpg.jpg"), 
    new ArbitrarySuggestionType(0.2, "San Telmo", "https://media-cdn.tripadvisor.com/media/photo-s/0e/51/35/35/tempura-sashimi-combo.jpg"), 
    new ArbitrarySuggestionType(3.6, "Supernormal", "https://media-cdn.tripadvisor.com/media/photo-s/0e/bc/63/69/mr-miyagi.jpg"), 
    new ArbitrarySuggestionType(4.4, "EZARD", "https://media-cdn.tripadvisor.com/media/photo-p/09/f2/83/15/photo0jpg.jpg"), 
    new ArbitrarySuggestionType(2.1, "Maha", "https://media-cdn.tripadvisor.com/media/photo-s/10/f8/9e/af/20171013-205729-largejpg.jpg"), 
    new ArbitrarySuggestionType(4.2, "MoVida", "https://media-cdn.tripadvisor.com/media/photo-s/0e/1f/55/79/and-here-we-go.jpg") 
  ]; 

  Future<Null> _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now) ? initialDate : now);

    var result = await Utilities.getDatePicker(
      context: context, 
      initialDate: initialDate,
      firstDate: new DateTime(1950),
      lastDate: new DateTime(2020),
      partsNeeded: CupertinoDatePickerMode.date);

    if (result == null) return;

    setState(() {
      _dateController.text = new DateFormat.yMd().add_Hm().format(result);
    });
  }

  bool isValidDob(String dob) {
    if (dob.isEmpty) return true;
    var d = convertToDate(dob);
    return d != null && d.isBefore(new DateTime.now());
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().add_Hm().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date Demo',
                suffixIcon: IconButton(
                  icon: new Icon(Icons.more_horiz),
                  tooltip: 'Choose date',
                  onPressed: (() {
                    _chooseDate(context, _dateController.text);
                  }),
                ),
              ),
            ),
            RaisedButton(
              child: Text('SearchList Demo'),
              onPressed: () async {
                //create all of the necessary params for the searchList widget...
                String pageTitle = 'Search for Stuff';
                String searchHint = 'Enter your search term here';
                Function searchFilter = (dynamic item, String query) {
                  if (item.name.toLowerCase().startsWith(query.toLowerCase()) || item.name.toLowerCase().contains(query.toLowerCase()))
                    return true;
                  else
                    return false;
                };
                Function sortExpression = (dynamic a, dynamic b) { 
                  return a.name.toString().compareTo(b.name.toString());
                };
                dynamic builder = (context, suggestion) => new Padding( 
                  child: new ListTile( 
                      title: new Text(suggestion.name), 
                      trailing: new Text("Stars: ${suggestion.stars}")), 
                  padding: EdgeInsets.only(left: 8.0,right: 8.0),
                ); 

                final resVal = await Navigator.push(context, new MaterialPageRoute(builder: (context)=> 
                  new SearchListPage(pageTitle: pageTitle,
                                      searchHint: searchHint,
                                      searchOptions: searchSuggestions,
                                      filterExpression: searchFilter,
                                      sortExpression: sortExpression,
                                      itemBuilder: builder,
                                    )));
                if (resVal == null)
                  print("nothing selected");
                else
                  print('selected: ${resVal.name}');
                setState(() { selectedItem = resVal;});
              },
            ),
            Text('Selected: ${selectedItem.toString()}'),
          ],
        ),
      ),
    );
  }
}

class ArbitrarySuggestionType { 
  //For the mock data type we will use review (perhaps this could represent a restaurant); 
  num stars; 
  String name, imgURL; 

  ArbitrarySuggestionType(this.stars, this.name, this.imgURL); 

  String toString()=>name; //needed so that autocomplete can render the 'name' when necessary
} 