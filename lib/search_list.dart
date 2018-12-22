import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'autocomplete_textfield.dart';

class SearchListPage extends StatefulWidget{

  final String pageTitle;
  final String searchHint;
  final List<dynamic> searchOptions;
  final Filter<dynamic> filterExpression;
  final Comparator<dynamic> sortExpression;
  final AutoCompleteOverlayItemBuilder<dynamic> itemBuilder;
  
  const SearchListPage({
    Key key, 
    this.pageTitle, 
    this.searchHint, 
    this.searchOptions, 
    this.filterExpression, 
    this.sortExpression, 
    this.itemBuilder
  }): super(key: key);

  @override
  State<StatefulWidget> createState() {

    return _SearchListPage();
  }


}

class _SearchListPage extends State<SearchListPage> {
  GlobalKey<AutoCompleteTextFieldState<dynamic>> key = new GlobalKey(); 
  AutoCompleteTextField searchTextField; 
  TextEditingController controller = new TextEditingController(); 

  dynamic selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: 90.0,
          child: FlatButton(
            onPressed: (){
              searchTextField.close();
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white)),
          ),
        ),
        title: Text(widget.pageTitle),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              searchTextField.close();
              Navigator.of(context).pop(selectedItem);
            },
            //child: Text(model.saveTitle(),
            child: Text('OK',
              style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.white)),
          ),
        ],
      ),
      body: new Center(
        child: new Column(
          children: <Widget>[
            new Column(
              children: <Widget>[       //AutoCompleteTextField code here
                searchTextField = AutoCompleteTextField<dynamic>(
                  style: new TextStyle(color: Colors.black, fontSize: 16.0),
                  decoration: new InputDecoration(
                    //suffixIcon: Container(
                    //  width: 48.0,
                    //  height: 48.0,
                    //  child: Icon(Platform.isIOS ? CupertinoIcons.clear_circled_solid : Icons.clear)  ,                    
                    //),
                    contentPadding: EdgeInsets.fromLTRB(10.0, 14.0, 10.0, 6.0),
                    filled: true,
                    hintText: widget.searchHint,
                    //hintStyle: TextStyle(color: Colors.black),
                  ),
                  clearOnSubmit: false,
                  clearSuggestionsOnSelect: false, //one of david baron's new properties
                  autoFocusText: true, //one of david baron's new properties
                  includeEraseButton: true,
                  suggestions: widget.searchOptions,
                  itemBuilder: widget.itemBuilder,
                  itemFilter: widget.filterExpression,
                  itemSorter: widget.sortExpression,
                  key: key,
                  itemSubmitted: (item) {
                    setState(() { 
                      selectedItem = item;
                    });
                  },
                ),                
              ]
            ),
          ]
        ),
      ),
    );
  }
}