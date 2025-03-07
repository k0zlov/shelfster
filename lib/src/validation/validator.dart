import 'package:shelfster/src/validation/validation_result.dart';

typedef Validator<T> = ValidationResult Function(T value);
