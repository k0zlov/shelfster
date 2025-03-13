import 'package:shelfster/src/api/handlers/api_handler.dart';
import 'package:shelfster/src/api/handlers/api_websocket.dart';
import 'package:shelfster/src/api/route/api_route.dart';
import 'package:shelfster/src/api/swagger/components.dart';

class OpenApiConfig {
  OpenApiConfig({
    required this.info,
    this.authMiddleware,
    this.servers,
    this.externalDocs,
  });

  final Object? authMiddleware;
  final OpenApiInfo info;
  final List<OpenApiServer>? servers;
  final OpenApiExternalDocs? externalDocs;
}

class OpenApiGenerator {
  const OpenApiGenerator._();

  static OpenApiSpec generate({
    required OpenApiConfig config,
    required List<ApiRoute> routes,
  }) {
    final paths = <OpenApiPathItem>[];

    for (final route in routes) {
      for (final handler in route.handlers) {
        if (handler is ApiWebsocket) continue;

        final formattedPath = _formatPath('/${route.name}/${handler.name}');

        final OpenApiPathItem pathItem = paths.firstWhere(
          (item) => item.path == formattedPath,
          orElse: () {
            final newItem = OpenApiPathItem(
              path: formattedPath,
              operations: [],
            );
            paths.add(newItem);
            return newItem;
          },
        );

        final operationItem = OpenApiOperationItem(
          method: handler.method.name.toLowerCase(),
          operation:
              _generateEndpointSpec(handler, route.name, formattedPath, config),
        );

        pathItem.operations!.add(operationItem);
      }
    }

    return OpenApiSpec(
      info: config.info,
      paths: paths,
      tags: routes
          .map(
            (route) => OpenApiTag(
              name: route.name,
              description: route.description,
            ),
          )
          .toList(),
      servers: config.servers,
      externalDocs: config.externalDocs,
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

  static String _formatPath(String path) =>
      path.replaceAllMapped(RegExp(r'<(\w+)>'), (m) => '{${m[1]}}');

  static OpenApiOperation _generateEndpointSpec(
    ApiHandler handler,
    String routeName,
    String path,
    OpenApiConfig config,
  ) {
    return OpenApiOperation(
      summary: handler.summary,
      description: handler.description,
      tags: [routeName],
      parameters: [
        ..._getPathParameters(path),
        ..._getQueryParameters(handler),
      ],
      requestBody: _getRequestBody(handler),
      responses: [
        OpenApiResponseItem(
          statusCode: '200',
          response: OpenApiResponse(description: 'Success'),
        ),
      ],
      security: config.authMiddleware != null &&
              handler.middlewares.contains(config.authMiddleware)
          ? [
              OpenApiSecurityRequirement({'bearerAuth': []}),
            ]
          : null,
    );
  }

  static List<OpenApiParameter> _getPathParameters(String path) {
    return RegExp(r'{(\w+)}')
        .allMatches(path)
        .map(
          (match) => OpenApiParameter(
            name: match.group(1)!,
            inLocation: 'path',
            required: true,
          ),
        )
        .toList();
  }

  static List<OpenApiParameter> _getQueryParameters(ApiHandler handler) {
    return handler.querySchema
        .map((param) => OpenApiParameter(
              name: param.name,
              inLocation: 'query',
              required: param.isRequired,
              schema: OpenApiSchema(type: _getSchemaType(param.type)),
            ))
        .toList();
  }

  static OpenApiRequestBody? _getRequestBody(ApiHandler handler) {
    if (handler.bodySchema.isEmpty) return null;

    return OpenApiRequestBody(
      required: true,
      content: {
        'application/json': OpenApiMedia(
          schema: OpenApiSchema(
            type: 'object',
            properties: {
              for (final field in handler.bodySchema)
                field.name: OpenApiSchema(type: _getSchemaType(field.type)),
            },
            required: handler.bodySchema
                .where((f) => f.isRequired)
                .map((f) => f.name)
                .toList(),
          ),
        ),
      },
    );
  }

  static String _getSchemaType(Type type) {
    switch (type.toString().toLowerCase()) {
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
