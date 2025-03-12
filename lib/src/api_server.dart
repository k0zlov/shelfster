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
    String? apiVersion,
    this.middlewares = const [],
  }) {
    _apiVersion = apiVersion ??
        Pubspec.parse(
          File('pubspec.yaml').readAsStringSync(),
        ).version.toString();
  }

  late final String _apiVersion;
  final OpenApiConfig openApiConfig;
  final RouteTree routeTree;
  final List<Object> middlewares;

  HttpServer? _server;
  final Router _utilityRouter = Router();

  Future<void> start({
    List<String>? args,
    int port = 8080,
    Object? ip,
  }) async {
    if (_server != null) {
      throw Exception('Server has already started');
    }

    _generateUtilityRoute();

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

    final bool firstStart =
        args?.any((arg) => arg.startsWith('--first-start=')) ?? false;

    if (firstStart) {
      print('Server running at ${_server?.address}:${_server?.port}');
    }

    _server!.autoCompress = true;
  }

  /// Generates openapi.json and mounts Swagger UI on /docs
  void _generateUtilityRoute() {
    final spec = OpenApiGenerator.generate(
      apiVersion: _apiVersion,
      routes: routeTree.routes,
      config: openApiConfig,
    );
    File('openapi.json').writeAsStringSync(jsonEncode(spec));

    _utilityRouter
      ..get(
        '/docs',
        SwaggerUI.fromFile(File('openapi.json')).call,
      )
      ..get(
        '/info',
        (request) => Response.ok({'apiVersion': _apiVersion}),
      );
  }
}
