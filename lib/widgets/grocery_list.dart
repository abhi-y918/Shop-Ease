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
   late Future<List<GroceryItem>>_loadeditems;
   String ? _error;

  @override
  void initState() {
    super.initState();
    _loadeditems=_loaditems();
  }
  Future<List<GroceryItem>> _loaditems() async{
    final url = Uri.https(
        'flutter-prep-314c6-default-rtdb.firebaseio.com', 'Shop_ease.json');
      final response = await http.get(url);
      if(response.statusCode>=400){
        throw Exception('Failed to fetch grocery item.Please try again later. ');
      }
      if(response.body == 'null'){
        return [];
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
     return loadeditems;

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
    void _removeitem(GroceryItem item)async{
      final index = _groceryitems.indexOf(item);
      setState(() {
        _groceryitems.remove(item);
      });

      final url = Uri.https(
          'flutter-prep-314c6-default-rtdb.firebaseio.com', 'Shop_ease/${item.id}.json');

      final response= await http.delete(url);

      if(response.statusCode>=400){
        setState(() {
          _groceryitems.insert(index, item);
        });
      }
    }
    
  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(future: _loadeditems, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No Items added yet.'));
        };
        return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (ctx, index) => Dismissible(
              onDismissed: (direction) {
                _removeitem(snapshot.data![index]);
                },
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(snapshot.data![index].quantity.toString(),
                ),
              ),
            )
        );
      }),
    );
  }
}