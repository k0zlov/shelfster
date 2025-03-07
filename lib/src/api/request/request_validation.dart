import 'dart:typed_data';

import 'package:shelfster/src/api/exceptions/api_exception.dart';
import 'package:shelfster/src/api/request/request_context.dart';
import 'package:shelfster/src/validation/validation_result.dart';
import 'package:shelfster/src/validation/validator.dart';

class Parameter<T> {
  Parameter(
    this.name, {
    this.validators = const [],
    this.isRequired = true,
  }) : type = T;

  final String name;
  final List<Validator<T>> validators;
  final bool isRequired;
  final Type type;

  T _fromJson(dynamic json) {
    if (json == null) {
      return null as T;
    }

    final typeList = <T>[];

    if (typeList is List<DateTime?>) {
      if (json is int) {
        return DateTime.fromMillisecondsSinceEpoch(json) as T;
      } else {
        return DateTime.parse(json.toString()) as T;
      }
    }

    if (typeList is List<double?> && json is int) {
      return json.toDouble() as T;
    }

    // blobs are encoded as a regular json array, so we manually convert that to
    // a Uint8List
    if (typeList is List<Uint8List?> && json is! Uint8List) {
      final asList = (json as List).cast<int>();
      return Uint8List.fromList(asList) as T;
    }

    return json as T;
  }

  ValidationResult validate(dynamic value) {
    if (value == null && !isRequired) return ValidationResult.valid();

    try {
      final T typedValue = _fromJson(value);

      final errors = validators
          .map((validator) => validator(typedValue))
          .where((result) => !result.isValid)
          .expand((result) => result.errors)
          .toList();

      if (errors.isEmpty) {
        return ValidationResult.valid();
      }

      return ValidationResult.invalid(errors);
    } catch (e) {
      return ValidationResult.invalid(['Invalid type provided for $name']);
    }
  }
}

Future<void> validateRequest({
  required RequestContext context,
  required Set<Parameter<Object>> body,
  required Set<Parameter<Object>> query,
}) async {
  final errors = <String>[];

  if (body.isNotEmpty) {
    final Map<String, dynamic> bodyParams = await context.params.body;

    for (final Parameter<Object> parameter in body) {
      final dynamic value = bodyParams[parameter.name];

      if (value == null && !parameter.isRequired) {
        errors.add('Body parameter "${parameter.name}" was not provided.');
        continue;
      }

      final result = parameter.validate(value);
      if (!result.isValid) {
        errors.addAll(
          result.errors.map((e) => 'Body parameter "${parameter.name}": $e'),
        );
      }
    }
  }

  if (query.isNotEmpty) {
    final Map<String, dynamic> queryParams = context.params.query;

    for (final Parameter<Object> parameter in query) {
      final dynamic value = queryParams[parameter.name];

      if (value == null && !parameter.isRequired) {
        errors.add('Query parameter "${parameter.name}" was not provided.');
        continue;
      }

      final result = parameter.validate(value);
      if (!result.isValid) {
        errors.addAll(
          result.errors.map((e) => 'Query parameter "${parameter.name}": $e'),
        );
      }
    }
  }

  if (errors.isNotEmpty) {
    throw ApiException.badRequest(
      'Request validation failed.',
      errors: errors,
    );
  }
}
