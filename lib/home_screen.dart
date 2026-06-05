import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guardian_x/services/auth_service.dart';
import 'package:guardian_x/shared/widgets/custom_elevated_button.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const String routeName = '/HomeScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(AuthService.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("No profile found"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            data['profile_image'].startsWith('assets')
                                ? AssetImage(data['profile_image'])
                                : NetworkImage(data['profile_image'])
                                    as ImageProvider,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Welcome, ${data['name']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  camera_button(),

                  const SizedBox(height: 30),

                  const Text(
                    "History",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(AuthService.currentUser!.uid)
                        .collection('mobile_app')
                        .orderBy('createdAt', descending: true)
                        .limit(20)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text("Error loading data");
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) return const Text("No history yet");

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final item =
                              docs[index].data() as Map<String, dynamic>;
                          final String videoUrl = item['videoUrl'] ?? "";
                          final dynamic rawTimestamp = item['createdAt'];
                          DateTime? dateTime;

                          if (rawTimestamp is Timestamp) {
                            dateTime = rawTimestamp.toDate();
                          } else if (rawTimestamp is String) {
                            dateTime = DateTime.tryParse(rawTimestamp);
                          }

                          String formattedTime = "00:00";
                          if (dateTime != null) {
                            formattedTime =
                                "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
                          }

                          return _HistoryTile(
                            videoUrl: videoUrl,
                            time: formattedTime,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String videoUrl;
  final String time;

  const _HistoryTile({required this.videoUrl, required this.time});

  String _getThumbnailUrl(String videoUrl) {
    if (videoUrl.contains('cloudinary.com')) {
      return videoUrl
          .replaceAll('/video/upload/', '/video/upload/so_0,f_jpg/')
          .replaceAll('.mp4', '.jpg');
    }
    return videoUrl;
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = _getThumbnailUrl(videoUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(videoUrl: videoUrl),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    thumbnailUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.play_circle_fill,
                    color: Colors.white70, size: 28),
              ],
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Video Detected",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            setState(() => _isInitialized = true);
            _videoController.play();
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Video", style: TextStyle(color: Colors.white)),
      ),
      body: _isInitialized
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Expanded عشان الفيديو ميتعداش الشاشة
                Expanded(
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  iconSize: 50,
                  icon: Icon(
                    _videoController.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _videoController.value.isPlaying
                          ? _videoController.pause()
                          : _videoController.play();
                    });
                  },
                ),
                VideoProgressIndicator(
                  _videoController,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                const SizedBox(height: 20),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }
}