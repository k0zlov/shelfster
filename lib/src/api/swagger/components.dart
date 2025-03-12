class OpenApiSpec {
  OpenApiSpec({
    this.openapi = '3.0.0',
    required this.info,
    required this.paths,
    required this.components,
  });

  final String openapi;
  final OpenApiInfo info;
  final Map<String, OpenApiPath> paths;
  final OpenApiComponents components;

  Map<String, dynamic> toJson() => {
        'openapi': openapi,
        'info': info.toJson(),
        'paths': {
          for (var entry in paths.entries) entry.key: entry.value.toJson(),
        },
        'components': components.toJson(),
      };
}

class OpenApiInfo {
  OpenApiInfo({required this.title, required this.version});

  final String title;
  final String version;

  Map<String, dynamic> toJson() => {
        'title': title,
        'version': version,
      };
}

class OpenApiPath {
  OpenApiPath({required this.operations});

  final Map<String, OpenApiOperation> operations;

  Map<String, dynamic> toJson() => {
        for (var entry in operations.entries) entry.key: entry.value.toJson(),
      };
}

class OpenApiSecurityRequirement {
  OpenApiSecurityRequirement(this.requirements);

  final Map<String, List<String>> requirements;

  Map<String, dynamic> toJson() => requirements;
}

class OpenApiOperation {
  OpenApiOperation({
    required this.summary,
    required this.tags,
    required this.parameters,
    this.requestBody,
    required this.responses,
    this.security,
  });

  final String summary;
  final List<String> tags;
  final List<OpenApiParameter> parameters;
  final OpenApiRequestBody? requestBody;
  final Map<String, OpenApiResponse> responses;
  final List<OpenApiSecurityRequirement>? security;

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'tags': tags,
        if (parameters.isNotEmpty)
          'parameters': parameters.map((p) => p.toJson()).toList(),
        if (requestBody != null) 'requestBody': requestBody!.toJson(),
        'responses': {
          for (var entry in responses.entries) entry.key: entry.value.toJson(),
        },
        if (security != null && security!.isNotEmpty)
          'security': security!.map((s) => s.toJson()).toList(),
      };
}

class OpenApiParameter {
  OpenApiParameter({
    required this.name,
    required this.location,
    required this.required,
    required this.type,
  });

  final String name;
  final String location;
  final bool required;
  final String type;

  Map<String, dynamic> toJson() => {
        'name': name,
        'in': location,
        'required': required,
        'schema': {'type': type},
      };
}

class OpenApiRequestBody {
  OpenApiRequestBody({required this.required, required this.content});

  final bool required;
  final Map<String, OpenApiMedia> content;

  Map<String, dynamic> toJson() => {
        'required': required,
        'content': {
          for (var entry in content.entries) entry.key: entry.value.toJson()
        },
      };
}

class OpenApiMedia {
  OpenApiMedia({required this.schema});

  final OpenApiSchema schema;

  Map<String, dynamic> toJson() => {'schema': schema.toJson()};
}

class OpenApiSchema {
  final String? type;
  final Map<String, OpenApiSchema>? properties;
  final OpenApiSchema? items;
  final List<String>? enumValues;
  final String? ref;

  OpenApiSchema({
    this.type,
    this.properties,
    this.items,
    this.enumValues,
    this.ref,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (ref != null) {
      json['\$ref'] = ref;
    } else {
      if (type != null) json['type'] = type;
      if (properties != null) {
        json['properties'] = {
          for (var entry in properties!.entries) entry.key: entry.value.toJson()
        };
      }
      if (items != null) json['items'] = items!.toJson();
      if (enumValues != null) json['enum'] = enumValues;
    }

    return json;
  }
}

class OpenApiResponse {
  OpenApiResponse({required this.description});

  final String description;

  Map<String, dynamic> toJson() => {'description': description};
}

class OpenApiComponents {
  OpenApiComponents({required this.securitySchemes});

  final Map<String, OpenApiSecurityScheme> securitySchemes;

  Map<String, dynamic> toJson() => {
        'securitySchemes': {
          for (var entry in securitySchemes.entries)
            entry.key: entry.value.toJson()
        },
      };
}

class OpenApiSecurityScheme {
  OpenApiSecurityScheme({
    required this.type,
    required this.scheme,
    required this.bearerFormat,
  });

  final String type;
  final String scheme;
  final String bearerFormat;

  Map<String, dynamic> toJson() => {
        'type': type,
        'scheme': scheme,
        'bearerFormat': bearerFormat,
      };
}
