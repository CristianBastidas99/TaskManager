import 'package:email_validator/email_validator.dart';

class Validators {
  static bool validateEmail(String email) => EmailValidator.validate(email);

  static bool validatePassword(String password) => password.length >= 6;

  static bool validateUsername(String username) => username.isNotEmpty && username.length >= 3;
}
