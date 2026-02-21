import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/paper.dart';
import '../../common_widgets/compact_paper_card.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final List<String> _topics = [
    'All',
    'Machine Learning',
    'Neuroscience',
    'Climate Science',
    'Physics',
    'Economics',
    'Biology',
  ];

  String _selectedTopic = 'All';

  final List<Paper> _mockPapers = List.generate(
    10,
    (index) => Paper(
      id: 'browse_$index',
      title: 'A New Approach to $index',
      authors: ['Researcher $index'],
      source: PaperSource.arxiv,
      sourceUrl: '',
      publishedAt: DateTime.now().subtract(Duration(days: index)),
      topicTags: ['Machine Learning'],
      curiosityHook: 'This is a mock hook for reading $index.',
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text('Browse', style: theme.textTheme.headlineLarge),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search topics, authors, keywords...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.midGray,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.midGray,
                  ),
                  filled: true,
                  fillColor: AppColors.paperWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.sageDark),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _topics.length,
                itemBuilder: (context, index) {
                  final topic = _topics[index];
                  final isSelected = _selectedTopic == topic;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(topic),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTopic = topic;
                        });
                      },
                      labelStyle: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? AppColors.paperWhite
                            : AppColors.sageDark,
                      ),
                      backgroundColor: AppColors.sageLight,
                      selectedColor: AppColors.inkBlack,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.inkBlack
                            : AppColors.sageGreen,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Feed
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                itemCount: _mockPapers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return CompactPaperCard(
                    paper: _mockPapers[index],
                    onTap: () {
                      // Open detail modal
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
