import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html/parser.dart' show parse;
import '../controllers/post_controller.dart';
import '../models/menu_model.dart';
import '../models/post_model.dart';
import '../screens/post_detail_screen.dart';
import '../widgets/states/empty_state.dart';
import '../widgets/states/failed_state.dart';
import '../widgets/states/loading_state.dart';
import '../widgets/states/refresh_state.dart';
import '../widgets/featured_post_item_card.dart';
import '../widgets/banner_admob.dart';
import '../widgets/post_item_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _controller = PostController();

  Future<Menu?>? _fetchedMenu;

  @override
  void initState() {
    super.initState();
    _fetchedMenu = _controller.getAllMenu();
    getAllPost();
    getFilteredPost(
      postPagingController: _controller.firstCategoryPostController,
      categoryIndex: 0,
    );
    getFilteredPost(
      postPagingController: _controller.secondCategoryPostController,
      categoryIndex: 1,
    );
    getFilteredPost(
      postPagingController: _controller.thirdCategoryPostController,
      categoryIndex: 2,
    );
    getFilteredPost(
      postPagingController: _controller.fourthCategoryPostController,
      categoryIndex: 3,
    );
  }

  void getAllPost() {
    _controller.allPostController.addPageRequestListener((pageKey) {
      _controller.getAllPost(pageKey);
    });
  }

  void getFilteredPost({
    required PagingController<int, Post> postPagingController,
    required int categoryIndex,
  }) {
    postPagingController.addPageRequestListener((pageKey) {
      _controller.getFilteredPost(
        pageKey: pageKey,
        categoryIndex: categoryIndex,
        postPagingController: postPagingController,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Menu?>(
      future: _fetchedMenu,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FailedState(
                stateIcon: Icons.error,
                stateText: 'Failed Retrieving Post',
                onPressed: () {
                  setState(() {
                    _fetchedMenu = _controller.getAllMenu();
                  });
                },
              ),
            ],
          );
        }

        Menu menuData = snapshot.data!;

        Parent filterData(int filterIndex) {
          return menuData.primary[filterIndex].parent;
        }

        return DefaultTabController(
          length: 5,
          initialIndex: 0,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                overlayColor: const MaterialStatePropertyAll(
                  Colors.transparent,
                ),
                labelColor: Theme.of(context).primaryColor,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  const Tab(
                    text: 'Explore',
                  ),
                  Tab(
                    text: filterData(0).title,
                  ),
                  Tab(
                    text: filterData(1).title,
                  ),
                  Tab(
                    text: filterData(2).title,
                  ),
                  Tab(
                    text: filterData(3).title,
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    PostTab(
                      pagingController: _controller.allPostController,
                    ),
                    PostTab(
                      pagingController: _controller.firstCategoryPostController,
                    ),
                    PostTab(
                      pagingController:
                          _controller.secondCategoryPostController,
                    ),
                    PostTab(
                      pagingController: _controller.thirdCategoryPostController,
                    ),
                    PostTab(
                      pagingController:
                          _controller.fourthCategoryPostController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PostTab extends StatefulWidget {
  const PostTab({super.key, required this.pagingController});

  final PagingController<int, Post> pagingController;

  @override
  State<PostTab> createState() => _PostTabState();
}

class _PostTabState extends State<PostTab> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => widget.pagingController.refresh()),
      child: PagedListView<int, Post>.separated(
        pagingController: widget.pagingController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        cacheExtent: 500,
        addAutomaticKeepAlives: true,
        padding: const EdgeInsets.all(20),
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
                    widget.pagingController.refresh();
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
                widget.pagingController.refresh();
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
                if (widget.pagingController.itemList != null &&
                    postData == widget.pagingController.itemList?.first)
                  FeaturedPostItem(
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
                    postImageUrl: postData.featuredImageSrc.large,
                  ),
                if (widget.pagingController.itemList != null &&
                    postData != widget.pagingController.itemList!.first)
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
                    postImageUrl: postData.featuredImageSrc.large,
                  ),
              ],
            );
          },
        ),
        separatorBuilder: (context, index) {
          if (index == 5) {
            return StatefulBuilder(
              builder: (context, setState) {
                return const BannerAdMob();
              },
            );
          } else {
            return const SizedBox(height: 30);
          }
        },
      ),
    );
  }
}
