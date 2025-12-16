import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String password;

  UserProfile({
    required this.name,
    required this.age,
    required this.weight,
    required this.password,
    this.email,
  });

}