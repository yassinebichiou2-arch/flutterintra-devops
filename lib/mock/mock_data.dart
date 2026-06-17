import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/group_model.dart';
import '../models/message_model.dart';
import '../models/notification_model.dart';

final mockUsers = [
  UserModel(
    id: 'u1',
    name: 'Alice Martin',
    email: 'alice@FlutterIntra.com',
    position: 'Flutter Developer',
    bio: 'Passionate about mobile development.',
    role: 'admin',
    photoUrl: null,
    joinedGroups: ['g1', 'g2'],
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
  UserModel(
    id: 'u2',
    name: 'Bob Dupont',
    email: 'bob@FlutterIntra.com',
    position: 'UI/UX Designer',
    bio: 'Design is my passion.',
    role: 'employee',
    photoUrl: null,
    joinedGroups: ['g1'],
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
  UserModel(
    id: 'u3',
    name: 'Clara Petit',
    email: 'clara@FlutterIntra.com',
    position: 'Backend Engineer',
    bio: 'I love clean APIs.',
    role: 'employee',
    photoUrl: null,
    joinedGroups: ['g2'],
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  // Nouveaux comptes
  UserModel(
    id: 'u4',
    name: 'Yassine Admin',
    email: 'admin@flutterintra.com',
    position: 'System Administrator',
    bio: 'Managing the platform.',
    role: 'admin',
    photoUrl: null,
    joinedGroups: ['g1', 'g2', 'g3'],
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  UserModel(
    id: 'u5',
    name: 'Yassine Bichiou',
    email: 'yassine@flutterintra.com',
    position: 'Mobile Developer',
    bio: 'Flutter enthusiast.',
    role: 'employee',
    photoUrl: null,
    joinedGroups: ['g1'],
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  UserModel(
    id: 'u6',
    name: 'Sara Mansouri',
    email: 'sara@flutterintra.com',
    position: 'Project Manager',
    bio: 'Keeping the team on track.',
    role: 'employee',
    photoUrl: null,
    joinedGroups: ['g1', 'g3'],
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  UserModel(
    id: 'u7',
    name: 'Karim Benali',
    email: 'karim@flutterintra.com',
    position: 'DevOps Engineer',
    bio: 'CI/CD and infrastructure.',
    role: 'employee',
    photoUrl: null,
    joinedGroups: ['g2'],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

final mockPosts = [
  PostModel(
    id: 'p1',
    authorId: 'u1',
    authorName: 'Alice Martin',
    content: 'Welcome to FlutterIntra! Our new enterprise social network is live. Share your ideas and collaborate with your team.',
    likes: ['u2', 'u3'],
    commentCount: 2,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  PostModel(
    id: 'p2',
    authorId: 'u2',
    authorName: 'Bob Dupont',
    content: 'Just finished the new dashboard design. Check it out and let me know what you think!',
    likes: ['u1'],
    commentCount: 1,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  PostModel(
    id: 'p3',
    authorId: 'u3',
    authorName: 'Clara Petit',
    content: 'The new API endpoints are ready for testing. Documentation has been updated on Confluence.',
    likes: [],
    commentCount: 0,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

final mockComments = [
  CommentModel(
    id: 'c1',
    postId: 'p1',
    authorId: 'u2',
    authorName: 'Bob Dupont',
    content: 'Great initiative! Looking forward to using it.',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  CommentModel(
    id: 'c2',
    postId: 'p1',
    authorId: 'u3',
    authorName: 'Clara Petit',
    content: 'Finally! This is exactly what we needed.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  CommentModel(
    id: 'c3',
    postId: 'p2',
    authorId: 'u1',
    authorName: 'Alice Martin',
    content: 'Looks amazing Bob! Clean and modern.',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
];

final mockGroups = [
  GroupModel(
    id: 'g1',
    name: 'Flutter Team',
    description: 'All things Flutter — tips, updates, and code reviews.',
    adminId: 'u1',
    members: ['u1', 'u2'],
    isPrivate: false,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
  GroupModel(
    id: 'g2',
    name: 'Backend Guild',
    description: 'Private group for backend engineers.',
    adminId: 'u3',
    members: ['u1', 'u3'],
    isPrivate: true,
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
  GroupModel(
    id: 'g3',
    name: 'Design System',
    description: 'UI/UX standards and component library discussions.',
    adminId: 'u2',
    members: ['u2'],
    isPrivate: false,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];

final mockMessages = [
  MessageModel(
    id: 'm1',
    senderId: 'u2',
    senderName: 'Bob Dupont',
    content: 'Hey Alice, can you review my PR?',
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
  ),
  MessageModel(
    id: 'm2',
    senderId: 'u1',
    senderName: 'Alice Martin',
    content: 'Sure! I will check it this afternoon.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
  ),
  MessageModel(
    id: 'm3',
    senderId: 'u2',
    senderName: 'Bob Dupont',
    content: 'Thanks a lot!',
    createdAt: DateTime.now().subtract(const Duration(minutes: 38)),
  ),
];

final mockConversations = [
  ConversationModel(
    id: 'u1_u2',
    participants: ['u1', 'u2'],
    participantNames: ['Alice Martin', 'Bob Dupont'],
    lastMessage: 'Thanks a lot!',
    lastMessageAt: DateTime.now().subtract(const Duration(minutes: 38)),
  ),
  ConversationModel(
    id: 'u1_u3',
    participants: ['u1', 'u3'],
    participantNames: ['Alice Martin', 'Clara Petit'],
    lastMessage: 'API docs are ready.',
    lastMessageAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
];

final mockNotifications = [
  NotificationModel(
    id: 'n1',
    userId: 'u1',
    type: 'like',
    title: 'New Like',
    body: 'Bob Dupont liked your post.',
    referenceId: 'p1',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  NotificationModel(
    id: 'n2',
    userId: 'u1',
    type: 'comment',
    title: 'New Comment',
    body: 'Clara Petit commented on your post.',
    referenceId: 'p1',
    isRead: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  NotificationModel(
    id: 'n3',
    userId: 'u1',
    type: 'message',
    title: 'New Message',
    body: 'Bob Dupont sent you a message.',
    isRead: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
];

