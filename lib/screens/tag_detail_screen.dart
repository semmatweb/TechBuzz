import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html/parser.dart' show parse;
import '../controllers/tag_controller.dart';
import '../models/post_model.dart';
import '../screens/post_detail_screen.dart';
import '../widgets/states/empty_state.dart';
import '../widgets/states/failed_state.dart';
import '../widgets/states/loading_state.dart';
import '../widgets/states/refresh_state.dart';
import '../widgets/post_item_card.dart';

class TagDetailScreen extends StatefulWidget {
  const TagDetailScreen({
    super.key,
    required this.tagID,
    required this.tagName,
  });

  final int tagID;
  final String tagName;

  @override
  State<TagDetailScreen> createState() => _TagDetailScreenState();
}

class _TagDetailScreenState extends State<TagDetailScreen> {
  final _controller = TagController();

  @override
  void initState() {
    super.initState();
    _controller.filteredPostController.addPageRequestListener((pageKey) {
      _controller.getTagPost(
        pageKey: pageKey,
        tagID: widget.tagID,
        postPagingController: _controller.filteredPostController,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagPagingController = _controller.filteredPostController;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.tagName,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => tagPagingController.refresh()),
        child: PagedListView<int, Post>.separated(
          pagingController: tagPagingController,
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
                      tagPagingController.refresh();
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
                  tagPagingController.refresh();
                },
              );
            },
            noItemsFoundIndicatorBuilder: (context) {
              return const EmptyState(stateText: 'NO\nPOST');
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
