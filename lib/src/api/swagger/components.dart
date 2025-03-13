class OpenApiSpec {
  OpenApiSpec({
    this.openapi = '3.0.0',
    required this.info,
    required this.paths,
    this.components,
    this.tags,
    this.servers,
    this.externalDocs,
  });

  final String openapi;
  final OpenApiInfo info;
  final List<OpenApiPathItem> paths;
  final OpenApiComponents? components;
  final List<OpenApiTag>? tags;
  final List<OpenApiServer>? servers;
  final OpenApiExternalDocs? externalDocs;

  Map<String, dynamic> toJson() => {
        'openapi': openapi,
        'info': info.toJson(),
        if (tags != null) 'tags': tags!.map((tag) => tag.toJson()).toList(),
        'paths': {for (var path in paths) path.path: path.toJson()},
        if (components != null) 'components': components!.toJson(),
        if (servers != null)
          'servers': servers!.map((server) => server.toJson()).toList(),
        if (externalDocs != null) 'externalDocs': externalDocs!.toJson(),
      };
}

class OpenApiPathItem {
  OpenApiPathItem(
      {required this.path, this.operations, this.summary, this.description});

  final String path;
  final List<OpenApiOperationItem>? operations;
  final String? summary;
  final String? description;

  Map<String, dynamic> toJson() => {
        if (summary != null) 'summary': summary,
        if (description != null) 'description': description,
        if (operations != null)
          for (var operation in operations!)
            operation.method: operation.operation.toJson(),
      };
}

class OpenApiOperationItem {
  OpenApiOperationItem({required this.method, required this.operation});

  final String method;
  final OpenApiOperation operation;
}

class OpenApiOperation {
  OpenApiOperation({
    this.tags,
    this.summary,
    this.description,
    this.parameters,
    this.requestBody,
    required this.responses,
    this.security,
    this.operationId,
  });

  final List<String>? tags;
  final String? summary;
  final String? description;
  final String? operationId;
  final List<OpenApiParameter>? parameters;
  final OpenApiRequestBody? requestBody;
  final List<OpenApiResponseItem> responses;
  final List<OpenApiSecurityRequirement>? security;

  Map<String, dynamic> toJson() => {
        if (tags != null) 'tags': tags,
        if (summary != null) 'summary': summary,
        if (description != null) 'description': description,
        if (operationId != null) 'operationId': operationId,
        if (parameters != null)
          'parameters': parameters!.map((p) => p.toJson()).toList(),
        if (requestBody != null) 'requestBody': requestBody!.toJson(),
        'responses': {
          for (var response in responses)
            response.statusCode: response.response.toJson()
        },
        if (security != null)
          'security': security!.map((s) => s.toJson()).toList(),
      };
}

class OpenApiResponseItem {
  OpenApiResponseItem({required this.statusCode, required this.response});

  final String statusCode;
  final OpenApiResponse response;
}

class OpenApiServer {
  OpenApiServer({required this.url, this.description});

  final String url;
  final String? description;

  Map<String, dynamic> toJson() => {
        'url': url,
        if (description != null) 'description': description,
      };
}

class OpenApiExternalDocs {
  OpenApiExternalDocs({required this.url, this.description});

  final String url;
  final String? description;

  Map<String, dynamic> toJson() => {
        'url': url,
        if (description != null) 'description': description,
      };
}

class OpenApiPath {
  OpenApiPath({this.operations, this.summary, this.description});

  final Map<String, OpenApiOperation>? operations;
  final String? summary;
  final String? description;

  Map<String, dynamic> toJson() => {
        if (summary != null) 'summary': summary,
        if (description != null) 'description': description,
        if (operations != null)
          for (var entry in operations!.entries)
            entry.key: entry.value.toJson(),
      };
}

class OpenApiParameter {
  OpenApiParameter(
      {required this.name,
      required this.inLocation,
      this.description,
      this.required,
      this.schema});

  final String name;
  final String inLocation;
  final String? description;
  final bool? required;
  final OpenApiSchema? schema;

  Map<String, dynamic> toJson() => {
        'name': name,
        'in': inLocation,
        if (description != null) 'description': description,
        if (required != null) 'required': required,
        if (schema != null) 'schema': schema!.toJson(),
      };
}

class OpenApiSchema {
  OpenApiSchema({
    this.type,
    this.format,
    this.enumValues,
    this.items,
    this.ref,
    this.properties,
    this.required,
  });

  final String? type;
  final String? format;
  final List<String>? enumValues;
  final OpenApiSchema? items;
  final String? ref;
  final Map<String, OpenApiSchema>? properties;
  final List<String>? required;

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (format != null) 'format': format,
        if (enumValues != null) 'enum': enumValues,
        if (items != null) 'items': items!.toJson(),
        if (ref != null) r'$ref': ref,
        if (properties != null)
          'properties': {
            for (var entry in properties!.entries)
              entry.key: entry.value.toJson(),
          },
        if (required != null && required!.isNotEmpty) 'required': required,
      };
}

class OpenApiRequestBody {
  OpenApiRequestBody({this.description, required this.content, this.required});

  final String? description;
  final Map<String, OpenApiMedia> content;
  final bool? required;

  Map<String, dynamic> toJson() => {
        if (description != null) 'description': description,
        'content': content.map((k, v) => MapEntry(k, v.toJson())),
        if (required != null) 'required': required,
      };
}

class OpenApiTag {
  OpenApiTag({required this.name, this.description});

  final String name;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}

class OpenApiInfo {
  OpenApiInfo({
    required this.title,
    required this.description,
    required this.contact,
    this.version = '1.0.0',
  });

  final String title;
  String version;
  final String description;
  final OpenApiContact contact;

  Map<String, dynamic> toJson() => {
        'title': title,
        'version': version,
        'description': description,
        'contact': contact.toJson(),
      };
}

class OpenApiContact {
  OpenApiContact({
    required this.name,
    this.email,
    this.url,
  });

  final String name;
  final String? email;
  final String? url;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (url != null) ...{
          'url': url,
        },
        if (email != null) ...{
          'email': email,
        },
      };
}

class OpenApiMedia {
  OpenApiMedia({required this.schema});

  final OpenApiSchema schema;

  Map<String, dynamic> toJson() => {'schema': schema.toJson()};
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
            entry.key: entry.value.toJson(),
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

class OpenApiSecurityRequirement {
  OpenApiSecurityRequirement(this.requirements);

  final Map<String, List<String>> requirements;

  Map<String, dynamic> toJson() => requirements;
}

class OpenApiEndpointDescription {
  OpenApiEndpointDescription({
    this.summary,
    this.description,
    this.schemas,
    this.responses,
    this.errors,
  });

  final String? summary;
  final String? description;
  final List<OpenApiNamedSchema>? schemas;
  final List<OpenApiResponseItem>? responses;
  final List<OpenApiResponseItem>? errors;

  Map<String, dynamic> toJson() => {
        if (summary != null) 'summary': summary,
        if (description != null) 'description': description,
        if (schemas != null)
          'schemas': {
            for (var schema in schemas!) schema.name: schema.schema.toJson()
          },
        if (responses != null)
          'responses': {
            for (var response in responses!)
              response.statusCode: response.response.toJson()
          },
        if (errors != null)
          'errors': {
            for (var error in errors!) error.statusCode: error.response.toJson()
          },
      };
}

class OpenApiNamedSchema {
  OpenApiNamedSchema({required this.name, required this.schema});

  final String name;
  final OpenApiSchema schema;
}
