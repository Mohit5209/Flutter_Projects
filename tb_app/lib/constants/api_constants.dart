/// API Constants for the application
class ApiConstants {
  // Base URL for all API endpoints
  static const String baseUrl = '_YOUR_API_BASE_URL_HERE_';

  // Authentication endpoints
  static const String signIn = '$baseUrl/api/user/signin';
  static const String signUp = '$baseUrl/api/user/signup';
  static const String generateJwt = '$baseUrl/api/user/generate_jwt';
  static const String forgotPassword = '$baseUrl/api/user/forgot-password';
  static const String resetPassword = '$baseUrl/api/user/reset-password';
  static const String otpValidate = '$baseUrl/api/user/otp_validate';
  static const String registerDevice = '$baseUrl/api/user/register_device';
  static const String unregisterDevice = '$baseUrl/api/user/unregister_device';

  // User endpoints
  static const String profile = '$baseUrl/api/user/profile';
  static const String fetchProfile = '$baseUrl/api/user/fetch_profile';
  static const String listFavorites = '$baseUrl/api/user/list_favorites';
  static const String removeFavorite ='$baseUrl/api/user/remove_from_favorites';
  static const String addFavorite = '$baseUrl/api/user/add_to_favorites';
  static const String isFavorite = '$baseUrl/api/user/is_favorite';
  static const String addToPinned = "$baseUrl/api/user/add_to_pinned";
  static const String listPinned = '$baseUrl/api/user/list_pinned';
  static const String getGroupParticipants = '$baseUrl/api/user/get_group_participants';
  static const String removeFromPinned = "$baseUrl/api/user/remove_from_pinned";
  static const String getAllUsers = '$baseUrl/api/user/get_all_users';
  static const String getDirectUsers = '$baseUrl/api/user/get_direct_users';

  // Conversation endpoints
  static const String conversations = '$baseUrl/api/user/conversations';
  static const String conversationStart ='$baseUrl/api/user/conversation_start';
  static const String getMessages = '$baseUrl/api/user/get_messages';
  static const String messageRead = '$baseUrl/api/user/message_read';
  static const String clearChat = '$baseUrl/api/user/clear_chat';

  // WebSocket URL
  static String sendMessageWs(int conversationId, String email) =>
      'ws://${baseUrl.replaceAll('https://', '')}/api/user/send_message_ws/$conversationId/${Uri.encodeComponent(email)}';
}
