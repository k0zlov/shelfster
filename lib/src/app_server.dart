import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'package:shelfster/src/api/controllers/app/api_handler.dart';
import 'package:shelfster/src/api/controllers/app/app_controller.dart';
import 'package:shelfster/src/api/controllers/rest/middlewares/default_middleware.dart';
import 'package:shelfster/src/api/route/app_route.dart';
import 'package:shelfster/src/api/swagger/open_api_generator.dart';

typedef AppServerConfig = ({int port, Object ip});

class AppServer {
  AppServer({
    required this.openApiConfig,
    required this.config,
    required this.routes,
    Map<Object, Middleware> middlewareMapping = const {},
    this.middlewares = const [],
  }) : middlewareMapping = {
          ...middlewareMapping,
          ...defaultMiddlewareMapping,
        };

  final OpenApiConfig openApiConfig;

  final List<Object> middlewares;
  final Map<Object, Middleware> middlewareMapping;
  final AppServerConfig config;
  final List<AppRoute> routes;

  HttpServer? _server;

  final Router _router = Router();
  final Router _swaggerRouter = Router();

  static final Map<Object, Middleware> defaultMiddlewareMapping = {
    DefaultMiddleware.logging: logRequests(),
    DefaultMiddleware.corsHeaders: corsHeaders(),
  };

  void _generateSwaggerSpec() {
    final spec = OpenApiGenerator.generateSpec(
      routes: routes,
      config: openApiConfig,
    );
    final specJson = jsonEncode(spec);
    File('openapi.json').writeAsStringSync(specJson);

    _swaggerRouter.get('/docs', SwaggerUI.fromFile(File('openapi.json')).call);
  }

  void _buildRoutes() {
    _generateSwaggerSpec();

    for (final AppRoute route in routes) {
      final localRouter = Router();

      for (final AppController controller in route.controllers) {
        for (final ApiHandler handler in controller.handlers) {
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
      }

      _router.mount('/${route.name}', localRouter.call);
    }
  }

  Future<void> start(List<String> args) async {
    final bool printMessage = args
            .firstWhere(
              (arg) => arg.startsWith('--first-start='),
              orElse: () => '--first-start=false',
            )
            .split('=')
            .last ==
        'true';

    if (_server != null) throw Exception('Server has already started');

    _buildRoutes();

    final mainPipeline = middlewares.fold(
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

    final combinedHandler = Cascade()
        .add(_swaggerRouter.call)
        .add(mainPipeline.addHandler(_router.call))
        .handler;

    _server = await serve(
      combinedHandler,
      config.ip,
      config.port,
    );

    _server!.autoCompress = true;
    if (printMessage) {
      print('Server listening on ${_server!.address.host}:${_server!.port}');
    }
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
  }
}
