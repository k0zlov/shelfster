import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelfster/src/api/handlers/api_handler.dart';
import 'package:shelfster/src/api/route/middlewares/default_middleware.dart';
import 'package:shelfster/src/api/route/api_route.dart';

/// This class builds the main Router by mounting all routes and handlers.
/// It also contains the default middleware mapping.
class RouteTree {
  RouteTree({
    required this.routes,
    Map<Object, Middleware> middlewareMapping = const {},
  }) : middlewareMapping = {
          ...defaultMiddlewareMapping,
          ...middlewareMapping,
        };

  /// Default middleware mapping is placed here
  static final Map<Object, Middleware> defaultMiddlewareMapping = {
    DefaultMiddleware.logging: logRequests(),
    DefaultMiddleware.corsHeaders: corsHeaders(),
  };

  final List<ApiRoute> routes;
  final Map<Object, Middleware> middlewareMapping;

  Router build() {
    final mainRouter = Router();

    for (final route in routes) {
      final localRouter = Router();

      for (final ApiHandler handler in route.handlers) {
        final pipeline = handler.middlewares.fold(
          const Pipeline(),
          (Pipeline acc, Object middleware) {
            final mw = middlewareMapping[middleware];
            if (mw == null) {
              throw Exception(
                'Middleware $middleware was not found in mapping',
              );
            }
            return acc.addMiddleware(mw);
          },
        );

        localRouter.add(
          handler.method.name,
          '/${handler.name}',
          pipeline.addHandler(handler()),
        );
      }
      mainRouter.mount('/${route.name}', localRouter.call);
    }

    return mainRouter;
  }
}
