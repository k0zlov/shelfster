import 'package:shelfster/src/api/controllers/app/api_handler.dart';
import 'package:shelfster/src/api/controllers/app/app_controller.dart';
import 'package:shelfster/src/api/controllers/rest/app_endpoint.dart';

abstract class RestController implements AppController {
  Set<AppEndpoint> get endpoints;

  @override
  Set<ApiHandler> get handlers => endpoints;
}
