import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/models/user_post_model.dart';
import 'package:khdmti_project/utils/responsive/responsive_helper.dart';

class SearchResultsScreen extends StatefulWidget {
  /// Initial query — comes from search bar text OR category label tap
  final String initialQuery;

  const SearchResultsScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchCtrl;
  List<UserPostModel> _results = [];
  bool _isLoading = false;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      _search(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Query Supabase ─────────────────────────────────────────────────────────
  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _activeQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _activeQuery = q;
    });

    try {
      // Search in postTitle AND description using ilike (case-insensitive)
      final titleRows = await Supabase.instance.client
          .from('user_posts')
          .select()
          .eq('isEnable', true)
          .ilike('postTitle', '%$q%')
          .order('created_at', ascending: false)
          .limit(30);

      final descRows = await Supabase.instance.client
          .from('user_posts')
          .select()
          .eq('isEnable', true)
          .ilike('discription', '%$q%')
          .order('created_at', ascending: false)
          .limit(30);

      // Merge + deduplicate by id
      final seen = <int>{};
      final merged = <UserPostModel>[];
      for (final row in [...titleRows, ...descRows]) {
        final model = UserPostModel.fromJson(row);
        if (model.id != null && seen.add(model.id!)) {
          merged.add(model);
        }
      }

      setState(() => _results = merged);
    } catch (e) {
      debugPrint('SearchResultsScreen: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Time ago helper ────────────────────────────────────────────────────────
  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xff1E293B) : Colors.white,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: isDark ? Colors.white : const Color(0xff1E293B),
                size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
            child: TextField(
              controller: _searchCtrl,
              autofocus: widget.initialQuery.isEmpty,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14,
                color:
                    isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'ابحث عن خدمة...',
                hintTextDirection: TextDirection.rtl,
                hintStyle: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xff475569)
                      : const Color(0xff94A3B8),
                ),
                filled: true,
                fillColor:
                    isDark ? const Color(0xff334155) : const Color(0xffF1F5F9),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: const Color(0xff94A3B8),
                        onPressed: () {
                          _searchCtrl.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
              onSubmitted: _search,
              onChanged: (v) {
                setState(() {}); // rebuild to show/hide clear button
                if (v.trim().isEmpty) _search('');
              },
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xff1173D4)),
              onPressed: () => _search(_searchCtrl.text),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Results count header ─────────────────────────────
            if (_activeQuery.isNotEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xff94A3B8)
                          : const Color(0xff64748B),
                    ),
                    children: [
                      TextSpan(
                        text: '${_results.length} نتيجة',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1173D4),
                        ),
                      ),
                      TextSpan(text: '  لـ  "$_activeQuery"'),
                    ],
                  ),
                ),
              ),

            // ── Body ─────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xff1173D4)),
                    )
                  : _activeQuery.isEmpty
                      ? _EmptyPrompt(isDark: isDark)
                      : _results.isEmpty
                          ? _NoResults(query: _activeQuery, isDark: isDark)
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _results.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) => _ResultCard(
                                post: _results[i],
                                isDark: isDark,
                                theme: theme,
                                timeAgo: _timeAgo(_results[i].createdAt),
                                query: _activeQuery,
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result Card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.post,
    required this.isDark,
    required this.theme,
    required this.timeAgo,
    required this.query,
  });

  final UserPostModel post;
  final bool isDark;
  final ThemeData theme;
  final String timeAgo;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon box ──
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xff1173D4).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline,
                color: Color(0xff1173D4), size: 24),
          ),
          const SizedBox(width: 14),

          // ── Content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with highlighted query
                _HighlightedText(
                  text: post.postTitle,
                  query: query,
                  baseStyle: theme.textTheme.titleSmall!.copyWith(
                    fontSize: context.adaptiveFontSize(14),
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xffF1F5F9)
                        : const Color(0xff1E293B),
                  ),
                  highlightColor: const Color(0xff1173D4),
                ),

                if (post.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: context.adaptiveFontSize(12),
                      color: isDark
                          ? const Color(0xff94A3B8)
                          : const Color(0xff64748B),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // ── Footer row ──
                Row(
                  children: [
                    // Available badge
                    if (post.isAvailable == true)
                      _Badge(label: 'متاح', color: const Color(0xff22C55E)),
                    if (post.isAvailable == true) const SizedBox(width: 8),

                    // PDF indicator
                    if (post.sourceId != null) ...[
                      const Icon(Icons.picture_as_pdf,
                          color: Color(0xffEF4444), size: 14),
                      const SizedBox(width: 4),
                    ],

                    const Spacer(),

                    // Time
                    Icon(Icons.access_time_outlined,
                        size: 12,
                        color: isDark
                            ? const Color(0xff64748B)
                            : const Color(0xff94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontSize: context.adaptiveFontSize(11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highlighted text (bolds the matching substring) ──────────────────────────

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseStyle,
    required this.highlightColor,
  });

  final String text;
  final String query;
  final TextStyle baseStyle;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final idx = lower.indexOf(lowerQ);

    if (idx == -1) {
      return Text(text,
          style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: baseStyle, children: [
        if (idx > 0) TextSpan(text: text.substring(0, idx)),
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: baseStyle.copyWith(
            color: highlightColor,
            backgroundColor: highlightColor.withValues(alpha: .12),
          ),
        ),
        if (idx + query.length < text.length)
          TextSpan(text: text.substring(idx + query.length)),
      ]),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Empty prompt (before any search) ─────────────────────────────────────────

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search,
              size: 60,
              color:
                  isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
          const SizedBox(height: 16),
          Text(
            'ابحث عن خدمة أو مهنة',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 15,
              color: isDark ? const Color(0xff64748B) : const Color(0xff94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── No results ────────────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.isDark});
  final String query;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined,
              size: 56,
              color:
                  isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج لـ "$query"',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرّب كلمة مختلفة أو تصنيفاً آخر',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              color: isDark ? const Color(0xff64748B) : const Color(0xff94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
