import 'package:flutter/material.dart';
import 'package:shop_ease/widgets/new_item.dart';
import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget{
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();

  }
  class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem>_groceryitems = [];

    void _additem() async{
      final newitem = await Navigator.of(context).push<GroceryItem>(
            MaterialPageRoute(
              builder: (ctx)=>const NewItem(),
            ),
      );
      if(newitem == null){
        return ;
      }
      setState(() {
        _groceryitems.add(newitem);
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