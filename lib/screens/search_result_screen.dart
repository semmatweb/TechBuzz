import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html/parser.dart' show parse;
import '../controllers/search_controller.dart';
import '../models/post_model.dart';
import '../screens/post_detail_screen.dart';
import '../widgets/states/empty_state.dart';
import '../widgets/states/failed_state.dart';
import '../widgets/states/loading_state.dart';
import '../widgets/states/refresh_state.dart';
import '../widgets/post_item_card.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({
    super.key,
    required this.searchKeyword,
  });

  final String searchKeyword;

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final _controller = SearchController();

  @override
  void initState() {
    super.initState();
    _controller.searchPostController.addPageRequestListener((pageKey) {
      _controller.getSearchResult(
        pageKey: pageKey,
        searchKeyword: widget.searchKeyword,
        postPagingController: _controller.searchPostController,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchPagingController = _controller.searchPostController;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.searchKeyword,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => searchPagingController.refresh()),
        child: PagedListView<int, Post>.separated(
          pagingController: searchPagingController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          cacheExtent: 500,
          addAutomaticKeepAlives: true,
          padding: const EdgeInsets.all(24),
          builderDelegate: PagedChildBuilderDelegate<Post>(
            firstPageProgressIndicatorBuilder: (context) {
              return const LoadingState();
            },
            firstPageErrorIndicatorBuilder: (context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FailedState(
                    stateIcon: Icons.error,
                    stateText: 'Failed Retrieving Post',
                    onPressed: () {
                      searchPagingController.refresh();
                    },
                  ),
                ],
              );
            },
            newPageProgressIndicatorBuilder: (context) {
              return const LoadingState();
            },
            newPageErrorIndicatorBuilder: (context) {
              return RefreshState(
                onPressed: () {
                  searchPagingController.refresh();
                },
              );
            },
            noItemsFoundIndicatorBuilder: (context) {
              return const EmptyState(stateText: 'RESULT\nNOT\nFOUND');
            },
            animateTransitions: true,
            itemBuilder: (context, postData, index) {
              final rawTitleString = parse(postData.title.rendered);
              final String parsedTitleString =
                  parse(rawTitleString.body!.text).documentElement!.text;

              final isToday = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              );

              return Column(
                children: [
                  PostItem(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postID: postData.id,
                          ),
                        ),
                      );
                    },
                    postTitle: parsedTitleString,
                    postDateTime: postData.date == isToday
                        ? timeago.format(postData.date)
                        : DateFormat('dd MMMM y').format(postData.date),
                    postCategory: postData.postTerms.first.name,
                    postImageUrl: postData.featuredImageSrc.medium,
                  ),
                ],
              );
            },
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 30),
        ),
      ),
    );
  }
}
