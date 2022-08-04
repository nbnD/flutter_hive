import 'package:flutter/material.dart';
import 'package:flutter_hive/data_model.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //textfield controllers
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  //form key
  final formGlobalKey = GlobalKey<FormState>();
  var box;

  var items = [];

  void getItems() async {
    box = await Hive.openBox('hive_box'); // open box

    setState(() {
      items = box.values.toList().reversed.toList();  //reversed so as to keep the new data to the top
    });
  }

  @override
  void initState() {
    super.initState();

    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grocessories Memo")),
      body: items.length == 0 //check if the data is present or not
          ? const Center(child: Text("No Data"))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, index) {
                return Card(
                  child: ListTile(
                    title: Text(items[index].item!),
                    subtitle: Text(items[index].quantity.toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //edit icon
                        IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showForm(context, items[index].key, index)),
                        // Delete button
                        IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              box = await Hive.openBox('hive_box');
                              box.delete(items[index].key);
                              getItems();
                            }),
                      ],
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(context, null, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showForm(BuildContext ctx, var itemKey, var index) {
    if (itemKey != null) {
      _itemController.text = items[index].item;
      _qtyController.text = items[index].quantity.toString();
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                top: 15,
                left: 15,
                right: 15),
            child: Form(
              key: formGlobalKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextFormField(
                    controller: _itemController,
                    validator: (value) {
                      if (value!.isEmpty) return "Required Field";
                    },
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _qtyController,
                    validator: (value) {
                      if (value!.isEmpty) return "Required Field";
                    },
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Quantity'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formGlobalKey.currentState!.validate()) {
                        box = await Hive.openBox('hive_box');
                        DataModel dataModel = DataModel(
                            item: _itemController.text,
                            quantity: int.parse(_qtyController.text));
                        if (itemKey == null) {  //if the itemKey is null it means we are creating new data
                          box.add(dataModel);
                        } else { //if itemKey is present we update the data
                          box.put(itemKey, dataModel);
                        }

                        setState(() {
                          _itemController.clear();
                          _qtyController.clear();
                        });
                        //to get refreshedData
                        getItems();
                        
                      }
                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(itemKey == null ? 'Create New' : 'Update'),
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            )));
  }
}
