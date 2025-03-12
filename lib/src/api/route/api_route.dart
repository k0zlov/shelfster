import 'package:shelfster/shelfster.dart';

abstract class ApiRoute {
  const ApiRoute();

  String get name {
    final className = runtimeType.toString();
    final firstWord = className.split(RegExp('(?=[A-Z])')).first.toLowerCase();
    return firstWord;
  }

  Set<ApiHandler> get handlers;
}
