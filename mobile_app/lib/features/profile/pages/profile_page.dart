import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // ------------------------------------------------
            // PROFILE PHOTO
            // ------------------------------------------------
            const CircleAvatar(
              radius: 55,
              backgroundColor: Colors.deepPurple,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 18),

            // ------------------------------------------------
            // NAME
            // ------------------------------------------------
            const Text(
              'Nandhakumar',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // ------------------------------------------------
            // USERNAME
            // ------------------------------------------------
            const Text(
              '@nandhakumar',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // ------------------------------------------------
            // STATS
            // ------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stat('Videos', '6'),
                _stat('Followers', '10'),
                _stat('Following', '8'),
              ],
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // BIO
            // ------------------------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Filmmaker 🎬 | Creator\n'
                'Turning ideas into stories.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ------------------------------------------------
            // EDIT PROFILE
            // ------------------------------------------------
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // POSTS HEADER
            // ------------------------------------------------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ------------------------------------------------
            // INSTAGRAM STYLE POST GRID
            // ------------------------------------------------
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: 6,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return _postTile(index);
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // PROFILE STAT
  // ========================================================

  Widget _stat(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // DUMMY POST TILE
  // ========================================================

  Widget _postTile(int index) {
    final List<IconData> icons = [
      Icons.movie_creation_outlined,
      Icons.camera_alt_outlined,
      Icons.landscape_outlined,
      Icons.movie_filter_outlined,
      Icons.theater_comedy_outlined,
      Icons.videocam_outlined,
    ];

    final List<String> titles = [
      'My Short Film',
      'Behind the Scenes',
      'Cinematic Shot',
      'New Project',
      'Film Making',
      'Coming Soon',
    ];

    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dummy cinematic background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade900,
                    Colors.black,
                  ],
                ),
              ),
            ),

            // Center icon
            Center(
              child: Icon(
                icons[index],
                size: 42,
                color: Colors.white70,
              ),
            ),

            // Small video indicator
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.play_circle_outline,
                size: 20,
                color: Colors.white,
              ),
            ),

            // Post title
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Text(
                titles[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

