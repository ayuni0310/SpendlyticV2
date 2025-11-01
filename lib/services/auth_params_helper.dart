import 'package:huawei_account/huawei_account.dart';

class AuthParamsHelper {
  final AccountAuthParamsHelper _helper = AccountAuthParamsHelper();

  void setEmail() => _helper.setEmail();

  void setMobileNumber() => _helper.setMobileNumber();

  void setIdToken() => _helper.setIdToken();

  void setAccessToken() => _helper.setAccessToken();

  /// Returns whatever type AccountAuthParamsHelper.createParams() produces.
  dynamic createParams() => _helper.createParams();
}
