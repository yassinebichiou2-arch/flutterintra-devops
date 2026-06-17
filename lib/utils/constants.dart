/// App-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'FlutterIntra';
  static const String appVersion = '1.0.0';

  // Firestore collection names
  static const String colUsers = 'users';
  static const String colPosts = 'posts';
  static const String colComments = 'comments';
  static const String colGroups = 'groups';
  static const String colConversations = 'conversations';
  static const String colMessages = 'messages';
  static const String colNotifications = 'notifications';
  static const String colGroupChats = 'group_chats';

  // Storage paths
  static const String storageProfiles = 'profile_photos';
  static const String storagePostImages = 'post_images';
  static const String storagePostFiles = 'post_files';
  static const String storageChatFiles = 'chat_files';

  // Pagination
  static const int feedPageSize = 20;
  static const int notifPageSize = 30;

  // File limits
  static const int maxFileSizeMb = 10;
  static const int maxImageSizeMb = 5;
}
