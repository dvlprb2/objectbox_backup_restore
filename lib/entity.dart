import 'package:objectbox/objectbox.dart';

@Entity()
class Task {
  int id;
  String title;

  Task({this.id = 0, required this.title});
}
