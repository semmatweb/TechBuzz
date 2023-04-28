import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html/parser.dart' show parse;
import '../controllers/category_controller.dart';
import '../models/post_model.dart';
import '../screens/post_detail_screen.dart';
import '../screens/states/empty_state.dart';
import '../screens/states/failed_state.dart';
import '../screens/states/loading_state.dart';
import '../screens/states/refresh_state.dart';
import '../widgets/post_item_card.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryID,
    required this.categoryName,
  });

  final int categoryID;
  final String categoryName;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final _controller = CategoryController();

  @override
  void initState() {
    super.initState();
    _controller.filteredPostController.addPageRequestListener((pageKey) {
      _controller.getCategoryPost(
        pageKey: pageKey,
        categoryID: widget.categoryID,
        postPagingController: _controller.filteredPostController,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryPagingController = _controller.filteredPostController;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: FlavorConfig.instance.variables['appBlack'],
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => categoryPagingController.refresh()),
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        child: PagedListView<int, Post>.separated(
          pagingController: categoryPagingController,
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
                      categoryPagingController.refresh();
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
                  categoryPagingController.refresh();
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
