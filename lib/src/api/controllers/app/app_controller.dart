
import 'package:shelfster/src/api/controllers/app/api_handler.dart';

abstract interface class AppController {
  Set<ApiHandler> get handlers;
}
