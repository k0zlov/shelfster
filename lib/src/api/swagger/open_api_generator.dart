import 'package:shelfster/src/api/controllers/app/api_handler.dart';
import 'package:shelfster/src/api/route/app_route.dart';

typedef OpenApiConfig = ({
  Object authMiddleware,
  String docsTitle,
});

class OpenApiGenerator {
  static Map<String, dynamic> generateSpec({
    required OpenApiConfig config,
    required List<AppRoute> routes,
  }) {
    final paths = <String, Map<String, dynamic>>{};

    for (final route in routes) {
      for (final controller in route.controllers) {
        for (final ApiHandler endpoint in controller.handlers) {
          final path = _formatPath('/${route.name}/${endpoint.name}');

          paths[path] ??= {};
          paths[path]?[endpoint.method.name.toLowerCase()] =
              _generateEndpointSpec(endpoint, route.name, path, config);
        }
      }
    }

    return {
      'openapi': '3.0.0',
      'info': {'title': config.docsTitle, 'version': '1.0.0'},
      'paths': paths,
      'components': {
        'securitySchemes': {
          'bearerAuth': {
            'type': 'http',
            'scheme': 'bearer',
            'bearerFormat': 'JWT',
          },
        },
      },
    };
  }

  static String _formatPath(String path) {
    return path
        .replaceAllMapped(RegExp(r'<(\w+)>'), (match) => '{${match[1]}}')
        .replaceAll('//', '/');
  }

  static Map<String, dynamic> _generateEndpointSpec(
    ApiHandler endpoint,
    String routeName,
    String path,
    OpenApiConfig config,
  ) {
    final parameters = [
      ..._getPathParameters(path),
      ..._getQueryParameters(endpoint),
    ];

    final requestBody = _getRequestBody(endpoint);

    return {
      'summary': endpoint.description,
      'tags': [routeName],
      if (parameters.isNotEmpty) 'parameters': parameters,
      if (requestBody != null) 'requestBody': requestBody,
      if (endpoint.middlewares.contains(config.authMiddleware))
        'security': [
          {'bearerAuth': []},
        ],
      'responses': {
        '200': {'description': 'Success'},
      },
    };
  }

  static List<Map<String, dynamic>> _getQueryParameters(ApiHandler endpoint) {
    return endpoint.querySchema
        .map(
          (param) => {
            'name': param.name,
            'in': 'query',
            'required': param.isRequired,
            'schema': {
              'type': param.type.toString().split('<').first.toLowerCase(),
            },
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> _getPathParameters(String path) {
    final matches = RegExp(r'{(\w+)}').allMatches(path);

    return matches.map((match) {
      final paramName = match.group(1)!;
      return {
        'name': paramName,
        'in': 'path',
        'required': true,
        'schema': {'type': 'string'},
      };
    }).toList();
  }

  static Map<String, dynamic>? _getRequestBody(ApiHandler endpoint) {
    if (endpoint.bodySchema.isEmpty) return null;

    return {
      'required': true,
      'content': {
        'application/json': {
          'schema': {
            'type': 'object',
            'required': endpoint.bodySchema
                .where((e) => e.isRequired)
                .map(
                  (e) => e.name,
                )
                .toList(),
            'properties': Map.fromEntries(
              endpoint.bodySchema.map(
                (param) => MapEntry(
                  param.name,
                  {
                    'type':
                        param.type.toString().split('<').first.toLowerCase(),
                  },
                ),
              ),
            ),
          },
        },
      },
    };
  }
}
