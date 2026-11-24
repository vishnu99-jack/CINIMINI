import 'package:flutter/material.dart';
import 'hls_scratch_test_page.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/core/theme/app_text_styles.dart';
import 'package:mobile_app/models/video_model.dart';
import 'package:mobile_app/repositories/video_repository.dart';
import '../widgets/hero_banner.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/horizontal_video_list.dart';
import '../widgets/section_header.dart';
import 'test_video_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ==============================================================
  // Repository
  // ==============================================================

  final VideoRepository _repository = VideoRepository();

  // ==============================================================
  // Video Data
  // ==============================================================

  late Future<List<VideoModel>> _videosFuture;

  // ==============================================================
  // Lifecycle
  // ==============================================================

  @override
  void initState() {
    super.initState();

    _loadVideos();
  }

  // ==============================================================
  // Load Videos
  // ==============================================================

  void _loadVideos() {
    _videosFuture = _repository.getVideos();
  }

  // ==============================================================
  // Refresh
  // ==============================================================

  Future<void> _refresh() async {
    setState(() {
      _loadVideos();
    });

    try {
      await _videosFuture;
    } catch (_) {
      // FutureBuilder handles the error UI.
    }
  }

  // ==============================================================
  // Retry
  // ==============================================================

  void _retry() {
    setState(() {
      _loadVideos();
    });
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        bottom: false,


        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: _refresh,

          child: FutureBuilder<List<VideoModel>>(
            future: _videosFuture,

            builder: (context, snapshot) {
              // ========================================================
              // LOADING
              // ========================================================

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _HomeLoadingView();
              }

              // ========================================================
              // ERROR
              // ========================================================

              if (snapshot.hasError) {
                return _HomeErrorView(
                  message: snapshot.error.toString(),
                  onRetry: _retry,
                );
              }

              // ========================================================
              // DATA
              // ========================================================

              final List<VideoModel> videos = snapshot.data ?? <VideoModel>[];

              // ========================================================
              // EMPTY
              // ========================================================

              if (videos.isEmpty) {
                return const _EmptyHomeView();
              }

              // ========================================================
              // MAIN HOME
              // ========================================================

              return _HomeContent(videos: videos);
            },
            
          ),
        ),
      ),
    );
  }
}

//======================================================================
// HOME CONTENT
//======================================================================

class _HomeContent extends StatelessWidget {
  final List<VideoModel> videos;

  const _HomeContent({required this.videos});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.only(bottom: 120),

      children: [
        // ============================================================
        // APP BAR
        // ============================================================
        const HomeAppBar(),

ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HlsScratchTestPage()),
            );
          },
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('Test HLS Streaming'),
        ),
const SizedBox(height: 10),

        ElevatedButton.icon(
          onPressed: () {
            debugPrint('[HOME] Opening independent video playback test page');

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TestVideoPage()),
            );
          },
          icon: const Icon(Icons.video_library_outlined),
          label: const Text('Test Video Playback'),
        ),
        const SizedBox(height: AppSpacing.md),

        // ============================================================
        // HERO
        // ============================================================
        HeroBanner(video: videos.first),

        const SizedBox(height: AppSpacing.xl),

        // ============================================================
        // NOW SCREENING
        // ============================================================
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: SectionHeader(title: '🎬 Now Screening'),
        ),

        const SizedBox(height: AppSpacing.md),

        // ============================================================
        // VIDEO CAROUSEL
        // ============================================================
        HorizontalVideoList(videos: videos),

        const SizedBox(height: AppSpacing.xl),

        // ============================================================
        // FUTURE SECTIONS
        // ============================================================
        //
        // Do NOT add fake content yet.
        //
        // Future MVP+ sections:
        //
        // 🔥 Trending
        // 🎬 Short Films
        // ⭐ Editor's Picks
        // 🎭 Categories
        //
        // These should be backed by real PeerTube/API data.
        //
      ],
    );
  }
}

//======================================================================
// LOADING VIEW
//======================================================================

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.only(bottom: 120),

      children: [
        // ============================================================
        // APP BAR
        // ============================================================
        const HomeAppBar(),

        const SizedBox(height: AppSpacing.md),

        // ============================================================
        // HERO SKELETON
        // ============================================================
        Container(
          height: 250,

          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),

          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),

          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ============================================================
        // SECTION TITLE
        // ============================================================
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),

          child: Text('🎬 Now Screening', style: AppTextStyles.sectionTitle),
        ),

        const SizedBox(height: AppSpacing.md),

        // ============================================================
        // VIDEO SKELETONS
        // ============================================================
        SizedBox(
          height: 180,

          child: ListView.separated(
            scrollDirection: Axis.horizontal,

            physics: const ClampingScrollPhysics(),

            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),

            itemCount: 3,

            separatorBuilder: (_, __) {
              return const SizedBox(width: AppSpacing.md);
            },

            itemBuilder: (_, __) {
              return const _VideoCardSkeleton();
            },
          ),
        ),
      ],
    );
  }
}

//======================================================================
// VIDEO CARD SKELETON
//======================================================================

class _VideoCardSkeleton extends StatelessWidget {
  const _VideoCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Thumbnail
          Container(
            height: 124,

            decoration: BoxDecoration(
              color: AppColors.surface,

              borderRadius: BorderRadius.circular(16),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Title
          Container(
            height: 14,
            width: 180,

            decoration: BoxDecoration(
              color: AppColors.surface,

              borderRadius: BorderRadius.circular(6),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Creator
          Container(
            height: 11,
            width: 120,

            decoration: BoxDecoration(
              color: AppColors.surface,

              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}

//======================================================================
// ERROR VIEW
//======================================================================

class _HomeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.only(bottom: 120),

      children: [
        const HomeAppBar(),

        const SizedBox(height: 100),

        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),

            child: Column(
              children: [
                // ======================================================
                // ERROR ICON
                // ======================================================
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 56,
                  color: AppColors.textMuted,
                ),

                const SizedBox(height: AppSpacing.md),

                // ======================================================
                // TITLE
                // ======================================================
                Text(
                  'Unable to load Cinimini',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle,
                ),

                const SizedBox(height: AppSpacing.sm),

                // ======================================================
                // DESCRIPTION
                // ======================================================
                Text(
                  'We couldn\'t connect to the video server.\n'
                  'Please make sure PeerTube is running.',

                  textAlign: TextAlign.center,

                  style: AppTextStyles.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.lg),

                // ======================================================
                // RETRY
                // ======================================================
                FilledButton.icon(
                  onPressed: onRetry,

                  icon: const Icon(Icons.refresh_rounded),

                  label: const Text('Try Again'),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ======================================================
                // TECHNICAL ERROR
                // ======================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(AppSpacing.md),

                  decoration: BoxDecoration(
                    color: AppColors.surface,

                    borderRadius: BorderRadius.circular(12),

                    border: Border.all(color: AppColors.border),
                  ),

                  child: Text(
                    message,

                    maxLines: 4,

                    overflow: TextOverflow.ellipsis,

                    textAlign: TextAlign.center,

                    style: AppTextStyles.metadata,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//======================================================================
// EMPTY VIEW
//======================================================================

class _EmptyHomeView extends StatelessWidget {
  const _EmptyHomeView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.only(bottom: 120),

      children: [
        // ============================================================
        // APP BAR
        // ============================================================
        const HomeAppBar(),

        const SizedBox(height: 140),

        // ============================================================
        // ICON
        // ============================================================
        const Center(
          child: Icon(
            Icons.movie_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ============================================================
        // TITLE
        // ============================================================
        Center(
          child: Text(
            'No films available yet',
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ============================================================
        // DESCRIPTION
        // ============================================================
        Center(
          child: Text(
            'Your cinematic journey starts here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
