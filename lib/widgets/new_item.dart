import 'package:flutter/material.dart';
import 'package:shop_ease/Data/categories.dart';
import 'package:shop_ease/models/category.dart';
import 'package:shop_ease/models/grocery_item.dart';
import 'package:http/http.dart'as http;


class NewItem extends StatefulWidget{
  const NewItem ({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem>{
  final _formkey = GlobalKey<FormState>();
  var _enteredname = '';
  var _enteredquantity = 1;
  var _selectedcategory = categories[Categories.vegetables]!;

  void _saveItem(){
    if(_formkey.currentState!.validate()){
      _formkey.currentState!.save();
      Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredname,
          quantity: _enteredquantity,
          category: _selectedcategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Items'),
      ),
      body: Padding(
        padding: const  EdgeInsets.all(12),
        child: Form(
          key:_formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration:InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value){
                  if(value==null ||
                      value.isEmpty ||
                      value.trim().length <=1 ||
                      value.trim().length>50){
                    return 'Must be between 1 and 50 characters ';
                  }
                  return null;
                },
                onSaved: (value){
                  // if(value== null){
                  //   return;
                  // }
                  _enteredname = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                      label: Text('Quality'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredquantity.toString(),
                      validator: (value){
                        if(value==null ||
                            value.isEmpty ||
                            int.tryParse(value)==null ||
                            int.parse(value)! <=0){
                          return ' Must be a valid, positive number ';
                        }
                        return null;
                      },//it works as string
                      onSaved: (value){
                        _enteredquantity  = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value : _selectedcategory,
                      items: [
                        for(final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value){
                        setState(() {
                          _selectedcategory = value!;
                        });
                        },
                    ), // more specific than the dropdownbuttonfield
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: (){
                      _formkey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const  Text('Add Item'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}