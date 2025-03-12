import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelfster/shelfster.dart';

FutureOr<Response> handler(RequestContext context) => Response.ok('123');

class TestRoute extends ApiRoute {
  @override
  Set<ApiHandler> get handlers => {
        ApiEndpoint.get(
          middlewares: [String],
          description: '123',
          bodySchema: {
            Field<String>('id', isRequired: true),
          },
          name: 'register',
          handler: handler,
        ),
        ApiEndpoint.get(
          middlewares: [String],
          description: '123',
          bodySchema: {
            Field<String>('id', isRequired: true),
          },
          querySchema: {
            Field<int>('id', isRequired: true),
          },
          name: '<id>',
          handler: handler,
        ),
      };
}

void main() async {
  final ApiServer server = ApiServer(
    openApiConfig: const OpenApiConfig(title: 'Test', authMiddleware: String),
    routeTree: RouteTree(
      middlewareMapping: {String: logRequests()},
      routes: [
        TestRoute(),
      ],
    ),
  );

  await server.start(port: 8080, ip: InternetAddress.anyIPv4);
}
