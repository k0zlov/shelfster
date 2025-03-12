import 'package:shelfster/src/api/handlers/api_handler.dart';
import 'package:shelfster/src/api/handlers/api_websocket.dart';
import 'package:shelfster/src/api/route/api_route.dart';
import 'package:shelfster/src/api/swagger/components.dart';

class OpenApiConfig {
  const OpenApiConfig({
    required this.title,
    required this.authMiddleware,
  });

  final String title;
  final Object? authMiddleware;
}

class OpenApiGenerator {
  const OpenApiGenerator._();

  static OpenApiSpec generate({
    required String apiVersion,
    required OpenApiConfig config,
    required List<ApiRoute> routes,
  }) {
    final Map<String, OpenApiPath> paths = {};

    for (final route in routes) {
      for (final ApiHandler handler in route.handlers) {
        if (handler is ApiWebsocket) continue;

        final String path = _formatPath('/${route.name}/${handler.name}');

        if (!paths.containsKey(path)) {
          paths[path] = OpenApiPath(operations: {});
        }

        paths[path]!.operations[handler.method.name.toLowerCase()] =
            _generateEndpointSpec(handler, route.name, path, config);
      }
    }

    return OpenApiSpec(
      info: OpenApiInfo(title: config.title, version: apiVersion),
      paths: paths,
      components: OpenApiComponents(
        securitySchemes: {
          'bearerAuth': OpenApiSecurityScheme(
            type: 'http',
            scheme: 'bearer',
            bearerFormat: 'JWT',
          ),
        },
      ),
    );
  }

  static String _formatPath(String path) {
    return path.replaceAllMapped(
        RegExp(r'<(\w+)>'), (match) => '{${match[1]}}');
  }

  static OpenApiOperation _generateEndpointSpec(
    ApiHandler endpoint,
    String routeName,
    String path,
    OpenApiConfig config,
  ) {
    return OpenApiOperation(
      summary: endpoint.description,
      tags: [routeName],
      parameters: [
        ..._getPathParameters(path),
        ..._getQueryParameters(endpoint),
      ],
      requestBody: _getRequestBody(endpoint),
      responses: {'200': OpenApiResponse(description: 'Success')},
      security: [
        if (endpoint.middlewares.contains(config.authMiddleware)) ...{
          OpenApiSecurityRequirement({'bearer': []}),
        },
      ],
    );
  }

  static List<OpenApiParameter> _getQueryParameters(ApiHandler endpoint) {
    return endpoint.querySchema
        .map(
          (param) => OpenApiParameter(
            name: param.name,
            location: 'query',
            required: param.isRequired,
            type: _getSchemaType(param.type),
          ),
        )
        .toList();
  }

  static List<OpenApiParameter> _getPathParameters(String path) {
    final matches = RegExp(r'{(\w+)}').allMatches(path);

    return matches.map((match) {
      final paramName = match.group(1)!;
      return OpenApiParameter(
        name: paramName,
        location: 'path',
        required: true,
        type: 'string',
      );
    }).toList();
  }

  static OpenApiRequestBody? _getRequestBody(ApiHandler endpoint) {
    if (endpoint.bodySchema.isEmpty) return null;

    return OpenApiRequestBody(
      required: true,
      content: {
        'application/json': OpenApiMedia(
          schema: OpenApiSchema(
            type: 'object',
            properties: {
              for (final field in endpoint.bodySchema)
                field.name: OpenApiSchema(type: _getSchemaType(field.type)),
            },
            required: [
              for (final field in endpoint.bodySchema)
                if (field.isRequired) field.name,
            ],
          ),
        ),
      },
    );
  }

  static String _getSchemaType(Type type) {
    final typeName = type.toString().split('<').first.toLowerCase();
    switch (typeName) {
      case 'int':
        return 'integer';
      case 'double':
        return 'number';
      case 'bool':
        return 'boolean';
      case 'string':
        return 'string';
      default:
        return 'string';
    }
  }
}
