import 'package:flutter/material.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/komentar.dart';
import 'package:plantify_app/models/postingan.dart';
import 'package:plantify_app/models/user.dart'; // To fetch user details for posts
import 'dart:io'; // Required for File image
import 'package:intl/intl.dart';
import 'package:plantify_app/providers/user_provider.dart';
import 'package:provider/provider.dart'; // For date formatting

class PostinganDetailScreen extends StatefulWidget {
  final int postId;

  const PostinganDetailScreen({super.key, required this.postId});

  @override
  State<PostinganDetailScreen> createState() => _PostinganDetailScreenState();
}

class _PostinganDetailScreenState extends State<PostinganDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _commentController = TextEditingController();
  Postingan? _post;
  User? _postUser; // The user who made the post
  List<Komentar> _comments = [];
  int _likeCount = 0;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadPostDetails();
    _loadComments();
    _loadLikes();
  }

  Future<void> _loadPostDetails() async {
    final fetchedPost = await _databaseHelper.getPostinganById(widget.postId);
    if (fetchedPost != null) {
      final fetchedUser = await _databaseHelper.getUserById(fetchedPost.userId);
      setState(() {
        _post = fetchedPost;
        _postUser = fetchedUser;
      });
    }
  }

  Future<void> _loadComments() async {
    final comments = await _databaseHelper.getKomentarByPostinganId(widget.postId);
    for (var comment in comments) {
      final user = await _databaseHelper.getUserById(comment.userId!);
      comment.username = user?.username ?? 'Unknown';
    }
    setState(() {
      _comments = comments;
    });
  }

  Future<void> _loadLikes() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    final likeCount = await _databaseHelper.getLikesCount(widget.postId);
    final isLiked = await _databaseHelper.isPostLikedByUser(currentUser.id!, widget.postId);

    setState(() {
      _likeCount = likeCount;
      _isLiked = isLiked;
    });
  }

  Future<void> _toggleLike() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    if (_isLiked) {
      await _databaseHelper.unlikePost(currentUser.id!, widget.postId);
    } else {
      await _databaseHelper.likePost(currentUser.id!, widget.postId);
    }
    _loadLikes();
  }

  Future<void> _addComment() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (_commentController.text.isNotEmpty && user != null) {
      final newComment = Komentar(
        postinganId: widget.postId,
        userId: user.id,
        isiKomentar: _commentController.text,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _databaseHelper.insertKomentar(newComment);
      _commentController.clear();
      _loadComments();
    }
  }

  String _formatTimeAgo(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_post == null || _postUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Postingan')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Postingan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPostCard(
                    context,
                    _post!,
                    _postUser!.username,
                  ),
                  const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Komentar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return _buildComment(context, comment.username!, comment.isiKomentar);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Comment input section
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Tambahkan komentar...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xFFE8F5E9), // Light green for input background
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    Postingan post,
    String userName,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFC8E6C9),
                  child: Icon(Icons.person, color: Color(0xFF4CAF50)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      _formatTimeAgo(post.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Static functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.caption,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(post.imageUrl!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text('$_likeCount'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // This is handled by the overall card tap in KomunitasScreen, but remains here for visual consistency
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text('${_comments.length}'), // Dynamic comments
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.share, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text('Bagikan'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComment(BuildContext context, String userName, String commentText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFC8E6C9),
            child: Icon(Icons.person, size: 18, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  commentText,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}