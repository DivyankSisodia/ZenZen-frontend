class RoutesName {
  static const String initial = "splash";
  static const String intro = "intro";
  static const String login = "login";
  static const String home = "home";
  static const String profile = "profile";
  static const String signup = "signup";
  static const String registerInfo = "register-info";
  static const String forgotPassword = "forgot-password";
  static const String resetPassword = "reset-password";
  static const String verifyUser = "verify-user";
  static const String doc = "document";
  static const String project = "project";
  static const String allDocs = "all-documents";
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
  static const String getUsers = "/auth/all-users";
  static const String createDocument = "/docs/create-doc";
  static const String createProject = "/docs/create-project";
  static const String addUserToProject = "docs//add-users-to-project";
  static const String addUserToDoc = "/docs/add-users-to-doc";
  static const String getAllDocuments = "/docs/get-all-docs";
  static const String getAllProjects = "/docs/get-all-projects";
  static const String getDocumentInfo = "/docs/get-doc-info";
}
