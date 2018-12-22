import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

typedef Widget AutoCompleteOverlayItemBuilder<T>(
    BuildContext context, T suggestion);

typedef bool Filter<T>(T suggestion, String query);

typedef InputEventCallback<T>(T data);

typedef StringCallback(String data);

class AutoCompleteTextField<T> extends StatefulWidget {
  List<T> suggestions;
  Filter<T> itemFilter;
  Comparator<T> itemSorter;
  StringCallback textChanged, textSubmitted;
  InputEventCallback<T> itemSubmitted;
  AutoCompleteOverlayItemBuilder<T> itemBuilder;
  int suggestionsAmount;
  GlobalKey<AutoCompleteTextFieldState<T>> key;
  bool submitOnSuggestionTap, clearOnSubmit;
  bool clearSuggestionsOnSelect; //added by david baron, whether or not to clear the suggestion list once tapped
  bool autoFocusText; //added by david baron, whether or not to autofocus the text field, thus displaying the keyboard
  bool includeEraseButton; //added by david baron, whether or not to include a 'clear' button next to the text field
  List<TextInputFormatter> inputFormatters;

  InputDecoration decoration;
  TextStyle style;
  TextInputType keyboardType;
  TextInputAction textInputAction;
  TextCapitalization textCapitalization;

  AutoCompleteTextField(
      {@required
          this.itemSubmitted, //Callback on item selected, this is the item selected of type <T>
      @required
          this.key, //GlobalKey used to enable addSuggestion etc
      @required
          this.suggestions, //Suggestions that will be displayed
      @required
          this.itemBuilder, //Callback to build each item, return a Widget
      @required
          this.itemSorter, //Callback to sort items in the form (a of type <T>, b of type <T>)
      @required
          this.itemFilter, //Callback to filter item: return true or false depending on input text
      this.inputFormatters,
      this.style,
      this.decoration: const InputDecoration(),
      this.textChanged, //Callback on input text changed, this is a string
      this.textSubmitted, //Callback on input text submitted, this is also a string
      this.keyboardType: TextInputType.text,
      this.suggestionsAmount: 15, //The amount of suggestions to show, larger values may result in them going off screen
      this.submitOnSuggestionTap: true, //Call textSubmitted on suggestion tap, itemSubmitted will be called no matter what
      this.clearOnSubmit: true, //Clear autoCompleteTextfield on submit
      this.clearSuggestionsOnSelect = true, //added by david baron, whether or not to clear the suggestion list once tapped
      this.autoFocusText = true, //added by david baron, whether or not to autofocus the text field, thus bringing up the keyboard without user effort
      this.includeEraseButton = true, //added by david baron, whether or not to include a 'clear' button next to the text field
      this.textInputAction: TextInputAction.done,
      this.textCapitalization: TextCapitalization.sentences})
      : super(key: key);

  void clear() {
    key.currentState.clear();
  }

  ///added by david baron
  void close() {
    key.currentState.clearOnSubmit = true;
    key.currentState.clear();
    key.currentState.close();
  }

  void addSuggestion(T suggestion) {
    key.currentState.addSuggestion(suggestion);
  }

  void removeSuggestion(T suggestion) {
    key.currentState.removeSuggestion(suggestion);
  }

  void updateSuggestions(List<T> suggestions) {
    key.currentState.updateSuggestions(suggestions);
  }

  TextField get textField => key.currentState.textField;

  @override
  State<StatefulWidget> createState() => new AutoCompleteTextFieldState<T>(
      suggestions,
      textChanged,
      textSubmitted,
      itemSubmitted,
      itemBuilder,
      itemSorter,
      itemFilter,
      suggestionsAmount,
      submitOnSuggestionTap,
      clearOnSubmit,
      clearSuggestionsOnSelect, //added by david baron, whether or not to clear the suggestion list once tapped
      autoFocusText, //added by david baron, whether or not to autofocus the text field, thus bringing up the keyboard without user effort
      includeEraseButton, //added by david baron, whether or not to include a 'clear' button next to the text field
      inputFormatters,
      textCapitalization,
      decoration,
      style,
      keyboardType,
      textInputAction);
}

class AutoCompleteTextFieldState<T> extends State<AutoCompleteTextField> {
  TextField textField;
  List<T> suggestions;
  StringCallback textChanged, textSubmitted;
  InputEventCallback<T> itemSubmitted;
  AutoCompleteOverlayItemBuilder<T> itemBuilder;
  Comparator<T> itemSorter;
  OverlayEntry listSuggestionsEntry;
  List<T> filteredSuggestions;
  Filter<T> itemFilter;
  int suggestionsAmount;
  bool submitOnSuggestionTap, clearOnSubmit;
  bool clearSuggestionsOnSelect; //last item added by david baron
  bool autoFocusText; //last item added by david baron
  bool includeEraseButton; //added by david baron, whether or not to include a 'clear' button next to the text field
      
  String currentText = "";
  InputDecoration finalDecor;
  VoidCallback eraseButtonCallback;

  AutoCompleteTextFieldState(
      this.suggestions,
      this.textChanged,
      this.textSubmitted,
      this.itemSubmitted,
      this.itemBuilder,
      this.itemSorter,
      this.itemFilter,
      this.suggestionsAmount,
      this.submitOnSuggestionTap,
      this.clearOnSubmit,
      this.clearSuggestionsOnSelect, //added by david baron
      this.autoFocusText, //added by david baron
      this.includeEraseButton, //added by david baron, whether or not to include a 'clear' button next to the text field
      List<TextInputFormatter> inputFormatters,
      TextCapitalization textCapitalization,
      InputDecoration decoration,
      TextStyle style,
      TextInputType keyboardType,
      TextInputAction textInputAction) {
    
    if (includeEraseButton) {
      finalDecor = decoration.copyWith(suffixIcon: Container(
        width: 48.0,
        height: 48.0,
        child: IconButton(
          icon: Icon(Platform.isIOS ? CupertinoIcons.clear_circled_solid : Icons.clear),
          onPressed: clear, //eraseButtonCallback
        ),
        ),
      );
    } else {
      finalDecor = decoration.copyWith();
    }
    
    textField = new TextField(
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: finalDecor, //decoration,
      style: style,
      keyboardType: keyboardType,
      focusNode: new FocusNode(),
      controller: new TextEditingController(),
      textInputAction: textInputAction,
      autofocus: autoFocusText, //david baron added
      onChanged: (newText) {
        currentText = newText;
        updateOverlay(newText);

        if (textChanged != null) {
          textChanged(newText);
        }

        //setState(() { 
        //eraseButtonCallback = clear; 
        //_eraseButtonCallback = (newText.isNotEmpty ? clear : null); 
        //});
      },
      onSubmitted: (submittedText) {
        if (clearOnSubmit) {
          clear();
        }

        if (textSubmitted != null) {
          textSubmitted(submittedText);
        }
      },
    );
    textField.focusNode.addListener(() {
      if (!textField.focusNode.hasFocus) {
        if (clearOnSubmit) { //david baron added so that list ONLY gets cleared when the user wants
          filteredSuggestions = [];
        } //david baron added
      }
    });
  }

  @override
  void initState() {
    super.initState();
    eraseButtonCallback = clear;
  }
  
  void clear() {
    textField.controller.clear();
    updateOverlay("");
    setState(() { eraseButtonCallback = null; });
  }

  void clearList() {
    updateOverlay("");
  }

  void close() {
    listSuggestionsEntry.remove();
  }

  void addSuggestion(T suggestion) {
    suggestions.add(suggestion);
    updateOverlay(currentText);
  }

  void removeSuggestion(T suggestion) {
    suggestions.contains(suggestion)
        ? suggestions.remove(suggestion)
        : throw "List does not contain suggestion and therefore cannot be removed";
    updateOverlay(currentText);
  }

  void updateSuggestions(List<T> suggestions) {
    this.suggestions = suggestions;
    updateOverlay(currentText);
  }

  void updateOverlay(String query) {
    if (listSuggestionsEntry == null) {
      final RenderBox textFieldRenderBox = context.findRenderObject();
      final RenderBox overlay = Overlay.of(context).context.findRenderObject();
      final width = textFieldRenderBox.size.width;

      final double deviceHeight = MediaQuery.of(context).size.height; //david baron
      
      final RelativeRect position = new RelativeRect.fromRect(
        new Rect.fromPoints(
          textFieldRenderBox.localToGlobal(
              textFieldRenderBox.size.bottomLeft(Offset.zero),
              ancestor: overlay),
          textFieldRenderBox.localToGlobal(
              textFieldRenderBox.size.bottomRight(Offset.zero),
              ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      //print("deviceHeight: $deviceHeight, position.top is: ${position.top}");
      //david baron, removed an extra 8px from height, just in case...
      double availHeight = (deviceHeight - position.top) - 8.0; 
      
      listSuggestionsEntry = new OverlayEntry(builder: (context) {
        return new Positioned(
          top: position.top,
          left: position.left,
          child: Material( //david baron added this since inkwells need Material ancestors
            child: new Container(
              width: width,
              height: availHeight, //added by david baron so that list has bounds
              child: ListView( //added by david baron, instead of the card and column
              //child: new Card(
                //child: new Column(
                  children: filteredSuggestions.map((suggestion) {
                    return new Row(children: [
                        new Expanded(
                          child: new InkWell(
                            child: itemBuilder(context, suggestion),
                            onTap: () {
                              setState(() {
                                if (submitOnSuggestionTap) {
                                  String newText = suggestion.toString(); //will ONLY work if object has a toString method, david baron
                                  textField.controller.text = newText;
                                  textField.focusNode.unfocus();
                                  itemSubmitted(suggestion);
                                  if (clearOnSubmit) {
                                    clear();
                                  }
                                  if (clearSuggestionsOnSelect) { //david baron
                                    clearList(); //david baron
                                  } //david baron
                                } else {
                                  String newText = suggestion.toString(); //will ONLY work if object has a toString method, david baron
                                  textField.controller.text = newText;
                                  textChanged(newText);
                                }
                              });
                            }
                          ),
                        ),
                      ]);
                    }).toList(),
                  //),
                //),
              ),
            ),
          ),
        );
      });
      Overlay.of(context).insert(listSuggestionsEntry);
    }

    filteredSuggestions = getSuggestions(suggestions, itemSorter, itemFilter, suggestionsAmount, query);

    listSuggestionsEntry.markNeedsBuild();
  }

  List<T> getSuggestions(List<T> suggestions, Comparator<T> sorter,
      Filter<T> filter, int maxAmount, String query) {
    if (query == "") {
      return [];
    }

    suggestions.sort(sorter);
    suggestions = suggestions.where((item) => filter(item, query)).toList();
    if (suggestions.length > maxAmount) {
      suggestions = suggestions.sublist(0, maxAmount);
    }
    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return textField;
  }
}

class SimpleAutoCompleteTextField extends AutoCompleteTextField<String> {
  final StringCallback textChanged, textSubmitted;

  SimpleAutoCompleteTextField(
      {TextStyle style,
      InputDecoration decoration, //: const InputDecoration(),
      this.textChanged,
      this.textSubmitted,
      TextInputType keyboardType: TextInputType.text,
      @required GlobalKey<AutoCompleteTextFieldState<String>> key,
      @required List<String> suggestions,
      int suggestionsAmount: 5,
      bool submitOnSuggestionTap: true,
      bool clearOnSubmit: true,
      bool clearSuggestionsOnSelect: true, //added by david baron
      bool autoFocusText: true, //added by david baron
      bool includeEraseButton: true, //added by david baron
      TextInputAction textInputAction: TextInputAction.done,
      TextCapitalization textCapitalization: TextCapitalization.sentences})
      : super(
            style: style,
            decoration: decoration,
            textChanged: textChanged,
            textSubmitted: textSubmitted,
            itemSubmitted: textSubmitted,
            keyboardType: keyboardType,
            key: key,
            suggestions: suggestions,
            itemBuilder: null,
            itemSorter: null,
            itemFilter: null,
            suggestionsAmount: suggestionsAmount,
            submitOnSuggestionTap: submitOnSuggestionTap,
            clearOnSubmit: clearOnSubmit,
            clearSuggestionsOnSelect: clearSuggestionsOnSelect, //added by david baron
            autoFocusText: autoFocusText, //added by david baron
            includeEraseButton: includeEraseButton, //added by david baron
            textInputAction: textInputAction,
            textCapitalization: textCapitalization);

  @override
  State<StatefulWidget> createState() => new AutoCompleteTextFieldState<String>(
          suggestions, textChanged, textSubmitted, itemSubmitted,
          (context, item) {
        return new Padding(padding: EdgeInsets.all(8.0), child: new Text(item));
      }, (a, b) {
        return a.compareTo(b);
      }, (item, query) {
        return item.toLowerCase().startsWith(query.toLowerCase());
      }, suggestionsAmount, submitOnSuggestionTap, clearOnSubmit, clearSuggestionsOnSelect, autoFocusText, includeEraseButton, [],
          textCapitalization, decoration, style, keyboardType, textInputAction);
}
