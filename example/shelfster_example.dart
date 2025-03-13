import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelfster/shelfster.dart';

FutureOr<Response> handler(RequestContext context) => Response.ok('123');

class TestRoute extends ApiRoute {
  @override
  String? get description => 'some description';

  @override
  Set<ApiHandler> get handlers => {
        register,
        updateUser,
        getUser,
        login,
        deleteUser,
        checkToken,
      };

  ApiEndpoint get register {
    return ApiEndpoint(
      method: HttpMethod.POST,
      name: 'register',
      summary: 'Test summary',
      description: 'Test description.',
      bodySchema: {
        Field<String>('name'),
        Field<String>('surname'),
        Field<String>('email'),
        Field<String>('password'),
      },
      handler: handler,
    );
  }

  ApiEndpoint get updateUser {
    return ApiEndpoint(
      method: HttpMethod.PUT,
      name: '',
      bodySchema: {
        Field<String>('name'),
        Field<String>('surname'),
        Field<String>('email'),
        Field<String>('password'),
      },
      handler: handler,
    );
  }

  ApiEndpoint get getUser {
    return ApiEndpoint(
      method: HttpMethod.GET,
      name: '',
      handler: handler,
    );
  }

  ApiEndpoint get deleteUser {
    return ApiEndpoint(
      method: HttpMethod.DELETE,
      name: '',
      handler: handler,
    );
  }

  ApiEndpoint get login {
    return ApiEndpoint(
      method: HttpMethod.POST,
      name: 'login',
      bodySchema: {
        Field<String>('email'),
        Field<String>('password'),
      },
      handler: handler,
    );
  }

  /// Endpoint for microservice integration
  ApiEndpoint get checkToken {
    return ApiEndpoint(
      method: HttpMethod.GET,
      name: 'check/<token>',
      handler: handler,
    );
  }
}

void main(List<String> args) async {
  final ApiServer server = ApiServer(
    openApiConfig: OpenApiConfig(
      authMiddleware: String,
      info: OpenApiInfo(
        title: 'Users-Api',
        description: 'Some description',
        contact: OpenApiContact(
          name: 'Ivan Kozlov',
          email: 'ivankozlov0624@gmail.com',
        ),
      ),
    ),
    routeTree: RouteTree(
      middlewareMapping: {String: logRequests()},
      routes: [
        TestRoute(),
      ],
    ),
  );

  await server.start(
    port: 8080,
    ip: InternetAddress.anyIPv4,
    args: args,
  );
}
