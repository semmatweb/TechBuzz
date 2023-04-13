import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:html/parser.dart' show parse;
import '../controllers/post_controller.dart';
import '../models/menu_model.dart';
import '../models/post_model.dart';
import '../screens/post_detail_screen.dart';
import '../widgets/featured_post_item_card.dart';
import '../widgets/post_item_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _controller = PostController();

  Future<Menu>? _fetchedMenu;

  @override
  void initState() {
    super.initState();
    _fetchedMenu = _controller.getAllMenu();
    _controller.allPostController.addPageRequestListener((pageKey) {
      _controller.getAllPost(pageKey);
    });
    _controller.firstCategoryPostController.addPageRequestListener((pageKey) {
      _controller.getFilteredPost(
        pageKey: pageKey,
        categoryIndex: 0,
        postPagingController: _controller.firstCategoryPostController,
      );
    });
    _controller.secondCategoryPostController.addPageRequestListener((pageKey) {
      _controller.getFilteredPost(
        pageKey: pageKey,
        categoryIndex: 1,
        postPagingController: _controller.secondCategoryPostController,
      );
    });
    _controller.thirdCategoryPostController.addPageRequestListener((pageKey) {
      _controller.getFilteredPost(
        pageKey: pageKey,
        categoryIndex: 2,
        postPagingController: _controller.thirdCategoryPostController,
      );
    });
    _controller.fourthCategoryPostController.addPageRequestListener((pageKey) {
      _controller.getFilteredPost(
        pageKey: pageKey,
        categoryIndex: 3,
        postPagingController: _controller.fourthCategoryPostController,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Menu>(
      future: _fetchedMenu,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: LoadingAnimationWidget.prograssiveDots(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
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
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelColor: const Color.fromARGB(255, 114, 114, 114),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500),
                indicatorColor: Theme.of(context).primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  const Tab(text: 'Explore'),
                  Tab(text: filterData(0).title),
                  Tab(text: filterData(1).title),
                  Tab(text: filterData(2).title),
                  Tab(text: filterData(3).title),
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

class PostTab extends StatelessWidget {
  const PostTab({super.key, required this.pagingController});

  final PagingController<int, Post> pagingController;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => pagingController.refresh()),
      color: Theme.of(context).primaryColor,
      child: PagedListView<int, Post>.separated(
        pagingController: pagingController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        cacheExtent: 500,
        addAutomaticKeepAlives: true,
        padding: const EdgeInsets.all(24),
        builderDelegate: PagedChildBuilderDelegate<Post>(
          firstPageProgressIndicatorBuilder: (context) {
            return Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            );
          },
          newPageProgressIndicatorBuilder: (context) {
            return Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            );
          },
          noItemsFoundIndicatorBuilder: (context) {
            return const Center(
              child: Text(
                'NO\nPOST',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 192, 192, 192),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            );
          },
          animateTransitions: true,
          itemBuilder: (context, postData, index) {
            final rawTitleString = parse(postData.title.rendered);
            final String parsedTitleString =
                parse(rawTitleString.body!.text).documentElement!.text;

            return Column(
              children: [
                if (postData == pagingController.itemList!.first)
                  FeaturedPostItem(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postID: postData.id,
                            postTitle: postData.title.rendered,
                            postCategory: postData.postTerms.first.name,
                            postDateTime: postData.date.toIso8601String(),
                            postImageUrl: postData.featuredImageSrc.large,
                          ),
                        ),
                      );
                    },
                    postTitle: parsedTitleString,
                    postDateTime:
                        DateFormat('dd/MM/y | H:mm').format(postData.date),
                    postCategory: postData.postTerms.first.name,
                    postImageUrl: postData.featuredImageSrc.large,
                  ),
                if (postData != pagingController.itemList!.first)
                  PostItem(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postID: postData.id,
                            postTitle: postData.title.rendered,
                            postCategory: postData.postTerms.first.name,
                            postDateTime: postData.date.toIso8601String(),
                            postImageUrl: postData.featuredImageSrc.large,
                          ),
                        ),
                      );
                    },
                    postTitle: parsedTitleString,
                    postDateTime:
                        DateFormat('dd/MM/y | H:mm').format(postData.date),
                    postCategory: postData.postTerms.first.name,
                    postImageUrl: postData.featuredImageSrc.large,
                  ),
              ],
            );
          },
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 30),
      ),
    );
  }
}
