import 'package:hive/hive.dart';

part 'data_model.g.dart'; 

@HiveType(typeId: 0)
class DataModel extends HiveObject{
  @HiveField(0)
  final String? item;
  @HiveField(1)
  final int? quantity;

  DataModel({this.item, this.quantity});
}
