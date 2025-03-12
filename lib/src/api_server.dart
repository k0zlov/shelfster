import 'dart:convert';
import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';
import 'package:shelfster/src/api/route/route_tree.dart';
import 'package:shelfster/src/api/swagger/open_api_generator.dart';

class ApiServer {
  ApiServer({
    required this.openApiConfig,
    required this.routeTree,
    this.apiVersion,
    this.middlewares = const [],
  });

  final String? apiVersion;
  final OpenApiConfig openApiConfig;
  final RouteTree routeTree;
  final List<Object> middlewares;

  HttpServer? _server;
  final Router _utilityRouter = Router();

  Future<void> start({
    int port = 8080,
    Object? ip,
  }) async {
    if (_server != null) {
      throw Exception('Server has already started');
    }

    _generateSwaggerSpec();

    final mainRouter = routeTree.build();

    final pipelineWithGlobal = middlewares.fold(
      const Pipeline(),
      (Pipeline acc, Object middlewareKey) {
        final mw = routeTree.middlewareMapping[middlewareKey];
        if (mw == null) {
          throw Exception('Middleware $middlewareKey was not found in mapping');
        }
        return acc.addMiddleware(mw);
      },
    );

    final combinedHandler = Cascade()
        .add(_utilityRouter.call)
        .add(pipelineWithGlobal.addHandler(mainRouter.call))
        .handler;

    _server = await serve(combinedHandler, ip ?? InternetAddress.anyIPv4, port);
    _server!.autoCompress = true;
  }

  final Pubspec pubspec = Pubspec.parse(
    File('pubspec.yaml').readAsStringSync(),
  );

  /// Generates openapi.json and mounts Swagger UI on /docs
  void _generateSwaggerSpec() {
    final spec = OpenApiGenerator.generate(
      apiVersion: apiVersion ?? pubspec.version.toString(),
      routes: routeTree.routes,
      config: openApiConfig,
    );
    File('openapi.json').writeAsStringSync(jsonEncode(spec));

    _utilityRouter.get(
      '/docs',
      SwaggerUI.fromFile(File('openapi.json')).call,
    );
  }
}
