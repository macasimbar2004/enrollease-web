import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../model/chat_model.dart';
import '../services/chat_service.dart';
import '../utils/theme_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appwrite/appwrite.dart';
import '../appwrite.dart';

class ChatPanel extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatPanel({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Storage _storage = Storage(client);

  String? _selectedConversationId;
  List<Map<String, dynamic>> _searchResults = [];
  final bool _isSearching = false;
  String? _selectedImagePath;
  String? _selectedImageBase64;

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _getProfilePictureData(String userId) async {
    try {
      // Get profile picture from Appwrite storage
      final result = await _storage.getFileDownload(
        bucketId: bucketIDProfilePics,
        fileId: userId,
      );

      if (result.isNotEmpty) {
        return result;
      }

      debugPrint('No profile picture found for user: $userId');
      return null;
    } catch (e) {
      debugPrint('Error getting profile picture for $userId: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        if (kIsWeb) {
          // Handle web platform
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            setState(() {
              _selectedImageBase64 = base64Encode(bytes);
            });
          }
        } else {
          // Handle mobile platform
          setState(() {
            _selectedImagePath = result.files.single.path;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.comments,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Messages',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withValues(alpha: 0.05),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              if (_selectedConversationId == null) ...[
                if (_isSearching)
                  const Center(child: CircularProgressIndicator())
                else if (_searchResults.isNotEmpty)
                  _buildSearchResults()
                else
                  Expanded(child: _buildConversationsList()),
              ] else
                Expanded(child: _buildChatMessages()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          final isExistingConversation = user['isExistingConversation'] as bool;

          return FutureBuilder<Uint8List?>(
            future: _getProfilePictureData(user['uid']),
            builder: (context, snapshot) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: snapshot.data != null
                      ? MemoryImage(snapshot.data!)
                      : null,
                  backgroundColor: ThemeColors.content(context),
                  onBackgroundImageError: snapshot.data != null
                      ? (exception, stackTrace) {
                          debugPrint('Error loading profile image: $exception');
                        }
                      : null,
                  child: snapshot.data == null
                      ? Text((user['name'] as String)[0].toUpperCase())
                      : null,
                ),
                title: Text(user['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['email']),
                    if (isExistingConversation)
                      Text(
                        user['lastMessage'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                trailing: isExistingConversation && user['hasUnread']
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
                onTap: () async {
                  if (isExistingConversation) {
                    setState(() {
                      _selectedConversationId = user['conversationId'];
                    });
                    _chatService.markMessagesAsRead(
                        user['conversationId'], widget.userId);
                  } else {
                    final conversationId =
                        await _chatService.createConversation([
                      widget.userId,
                      user['uid'],
                    ]);
                    setState(() {
                      _selectedConversationId = conversationId;
                    });
                  }
                  _searchController.clear();
                  _searchResults = [];
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationsList() {
    return StreamBuilder<List<Conversation>>(
      stream: _chatService.getConversations(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final conversations = snapshot.data ?? [];

        if (conversations.isEmpty) {
          return const Center(
            child: Text('No conversations yet'),
          );
        }

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final otherParticipantId = conversation.participants
                .firstWhere((id) => id != widget.userId);

            return FutureBuilder<Map<String, dynamic>>(
              future: _getUserData(otherParticipantId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ThemeColors.content(context),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                final userData = userSnapshot.data ?? {};
                final userName = userData['userName'] ?? 'Unknown User';

                return FutureBuilder<Uint8List?>(
                  future: _getProfilePictureData(otherParticipantId),
                  builder: (context, imageSnapshot) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: imageSnapshot.data != null
                            ? MemoryImage(imageSnapshot.data!)
                            : null,
                        backgroundColor: ThemeColors.content(context),
                        onBackgroundImageError: imageSnapshot.data != null
                            ? (exception, stackTrace) {
                                debugPrint(
                                    'Error loading profile image: $exception');
                              }
                            : null,
                        child: imageSnapshot.data == null
                            ? Text(userName[0].toUpperCase())
                            : null,
                      ),
                      title: Text(userName),
                      subtitle: Text(
                        conversation.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: conversation.hasUnread
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedConversationId = conversation.id;
                        });
                        _chatService.markMessagesAsRead(
                            conversation.id, widget.userId);
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data() ?? {};
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return {};
    }
  }

  Widget _buildMessageContent(ChatMessage message) {
    if (message.type == 'image' && message.content.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.senderId != widget.userId)
            Text(
              message.senderName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              base64Decode(message.content),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: message.senderId == widget.userId
                  ? Colors.white70
                  : Colors.grey[600],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.senderId != widget.userId)
            Text(
              message.senderName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          Text(
            message.content,
            style: TextStyle(
              color: message.senderId == widget.userId
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: message.senderId == widget.userId
                  ? Colors.white70
                  : Colors.grey[600],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildChatMessages() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _chatService.getMessages(_selectedConversationId!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data ?? [];

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message.senderId == widget.userId;

                  return FutureBuilder<Uint8List?>(
                    future: _getProfilePictureData(message.senderId),
                    builder: (context, snapshot) {
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: CircleAvatar(
                                    backgroundImage: snapshot.data != null
                                        ? MemoryImage(snapshot.data!)
                                        : null,
                                    backgroundColor: ThemeColors.content(context),
                                    onBackgroundImageError:
                                        snapshot.data != null
                                            ? (exception, stackTrace) {
                                                debugPrint(
                                                    'Error loading profile image: $exception');
                                              }
                                            : null,
                                    child: snapshot.data == null
                                        ? Text(
                                            message.senderName[0].toUpperCase())
                                        : null,
                                  ),
                                ),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? ThemeColors.content(context)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: _buildMessageContent(message),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        _buildImagePreview(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                color: ThemeColors.content(context),
                onPressed: _pickImage,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                color: ThemeColors.content(context),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImagePath != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_selectedImagePath!),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedImagePath = null;
                  });
                },
              ),
            ),
          ],
        ),
      );
    } else if (_selectedImageBase64 != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                base64Decode(_selectedImageBase64!),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedImageBase64 = null;
                  });
                },
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty ||
        _selectedImagePath != null ||
        _selectedImageBase64 != null) {
      await _chatService.sendMessage(
        conversationId: _selectedConversationId!,
        senderId: widget.userId,
        senderName: widget.userName,
        content: _messageController.text,
        imageData: kIsWeb ? _selectedImageBase64 : _selectedImagePath,
        type: (_selectedImagePath != null || _selectedImageBase64 != null)
            ? 'image'
            : 'text',
      );
      _messageController.clear();
      setState(() {
        _selectedImagePath = null;
        _selectedImageBase64 = null;
      });
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
