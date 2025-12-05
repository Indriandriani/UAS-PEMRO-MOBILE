import 'package:flutter/material.dart';
import 'package:plantify_app/database/database_helper.dart';
import 'package:plantify_app/models/postingan.dart';
import 'package:plantify_app/models/user.dart';
import 'package:plantify_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Postingan> _posts = [];
  Map<int, String> _usernames = {};
  Map<int, int> _commentCounts = {};
  Map<int, int> _likeCounts = {};
  Map<int, bool> _isLikedByCurrentUser = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    final fetchedPosts = await _databaseHelper.getAllPostingan();
    Map<int, String> tempUsernames = {};
    Map<int, int> tempCommentCounts = {};
    Map<int, int> tempLikeCounts = {};
    Map<int, bool> tempIsLikedByCurrentUser = {};

    for (var post in fetchedPosts) {
      if (!_usernames.containsKey(post.userId)) {
        final user = await _databaseHelper.getUserById(post.userId);
        if (user != null) {
          tempUsernames[user.id!] = user.username;
        }
      }
      final comments = await _databaseHelper.getKomentarByPostinganId(post.id!);
      tempCommentCounts[post.id!] = comments.length;

      final likes = await _databaseHelper.getLikesCount(post.id!);
      tempLikeCounts[post.id!] = likes;

      final isLiked = await _databaseHelper.isPostLikedByUser(currentUser.id!, post.id!);
      tempIsLikedByCurrentUser[post.id!] = isLiked;
    }

    setState(() {
      _posts = fetchedPosts;
      _usernames.addAll(tempUsernames);
      _commentCounts = tempCommentCounts;
      _likeCounts = tempLikeCounts;
      _isLikedByCurrentUser = tempIsLikedByCurrentUser;
    });
  }

  Future<void> _toggleLike(int postId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    final isLiked = _isLikedByCurrentUser[postId] ?? false;
    if (isLiked) {
      await _databaseHelper.unlikePost(currentUser.id!, postId);
    } else {
      await _databaseHelper.likePost(currentUser.id!, postId);
    }
    _loadPosts();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunitas', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: const Color(0xFF4CAF50),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Terhubung dengan pecinta tanaman 🌱',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/create_post').then((_) => _loadPosts()); // Reload posts after creation
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Bagikan Tanamanmu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green button
                  foregroundColor: Colors.white, // Set text color to white
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: _posts.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada postingan di komunitas. Jadilah yang pertama!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      final userName = _usernames[post.userId] ?? 'Anonim'; // Fallback for username
                      return _buildPostCard(
                        context,
                        post,
                        userName,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50), // Primary green
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Komunitas is the third item (index 2)
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/gallery');
              break;
            case 2:
            // Already on Komunitas
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/challenges');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeri',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Komunitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Tantangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
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
    final commentCount = _commentCounts[post.id!] ?? 0;
    final likeCount = _likeCounts[post.id!] ?? 0;
    final isLiked = _isLikedByCurrentUser[post.id!] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/post_detail', arguments: post.id).then((_) => _loadPosts());
      },
      child: Card(
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
                    onTap: () => _toggleLike(post.id!),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text('$likeCount'),
                      ],
                    ),
                  ),
                  GestureDetector( 
                    onTap: () {
                      Navigator.pushNamed(context, '/post_detail', arguments: post.id).then((_) => _loadPosts());
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.comment, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text('$commentCount'),
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
      ),
    );
  }
}