import 'package:flutter/material.dart';
import 'package:shop_ease/Data/categories.dart';
import 'package:shop_ease/widgets/new_item.dart';
import '../models/grocery_item.dart';
import 'package:http/http.dart'as http;
import 'dart:convert';

class GroceryList extends StatefulWidget{
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();

  }
  class _GroceryListState extends State<GroceryList> {
   List<GroceryItem>_groceryitems = [];
   var _isloading= true;
   String ? _error;

  @override
  void initState() {
    super.initState();
    _loaditems();
  }
  void _loaditems() async{
    final url = Uri.https(
        'flutter-prep-31c6-default-rtdb.firebaseio.com', 'Shop_ease.json');
    final response = await http.get(url);
    if(response.statusCode>=400){
      setState(() {
        _error = 'Failed to fetch data.Please try again later.';
      });
    }
    final Map<String ,dynamic>listdata= json.decode(response.body);
    final List<GroceryItem>loadeditems=[];
    for(final item in listdata.entries) {
      final category = categories.entries.firstWhere((catitem) =>
      catitem.value.title == item.value['category']).value;
      loadeditems.add(
          GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category,
          ),
      );
    }
    setState(() {
      _groceryitems=loadeditems;
      _isloading=false;
    });
  }

    void _additem() async {
      final newItem=await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(
          builder: (ctx) => const NewItem(),
        ),
      );
      if(newItem==null){
        return;
      }
      setState(() {
        _groceryitems.add(newItem);
      });
    }
    void _removeitem(GroceryItem item){
      setState(() {
        _groceryitems.remove(item);
      });
    }
    
  @override
  Widget build(BuildContext context) {
      Widget content= const Center(child: Text('No Items added yet.'));

      if(_isloading){
        content=const Center(child: CircularProgressIndicator(),);
      }
      if(_groceryitems.isNotEmpty){
        content = ListView.builder(
          itemCount: _groceryitems.length,
          itemBuilder: (ctx , index)=> Dismissible(
            onDismissed: (direction){
              _removeitem(_groceryitems[index]);
            },
              key: ValueKey(_groceryitems[index].id), 
              child: ListTile(
                title:Text(_groceryitems[index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryitems[index].category.color,
                ),
                trailing: Text(_groceryitems[index].quantity.toString(),
                ),
              ),
          )
        );
      }
      if(_error!=null){
        content = Center(child: Text(_error!),);
      }
      return Scaffold(
          appBar: AppBar(
            title: const Text("Your Groceries"), 
            actions: [
              IconButton(
                onPressed: _additem, 
                icon: const Icon(Icons.add),
              ),
            ],
          ), 
          body:content,
      );
  }
}