class RoutesName {
  static const String initial = "splash";
  static const String intro = "intro";
  static const String login = "login";
  static const String home = "home";
  static const String profile = "profile";
  static const String signup = "signup";
  static const String registerInfo = "register-info";
}

class ApiRoutes {
  static const String baseUrl = "https://zenzen.onrender.com/api";
  static const String signup = "/auth/signup";
  static const String login = "/auth/login";
  static const String logout = "/auth/logout";
  static const String registerUserInfo = "/auth/register-info";
  static const String sendOTP = "/auth/send-otp";
  static const String verifyUser = "/auth/verify-user";
  static const String updateProfile = "/auth/update-profile";
  static const String forgotPassword = "/auth/forgot-password";
  static const String resetPassword = "/auth/reset-password";
  static const String getAccessToken = "/auth/get-access-token";
  static const String user = "/auth/user";
}
