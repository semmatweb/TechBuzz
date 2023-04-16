import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
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
          return Center(
            child: LoadingAnimationWidget.prograssiveDots(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Failed to fetch post',
                  style: TextStyle(
                    color: FlavorConfig.instance.variables['appBlack'],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _fetchedMenu = _controller.getAllMenu();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlavorConfig
                        .instance.variables['appPrimaryAccentColor'],
                    elevation: 0,
                    surfaceTintColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  icon: Icon(
                    Icons.refresh,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Retry',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
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
                unselectedLabelColor:
                    FlavorConfig.instance.variables['appGrey'],
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
      backgroundColor: Colors.white,
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
          firstPageErrorIndicatorBuilder: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Failed to fetch post',
                    style: TextStyle(
                      color: FlavorConfig.instance.variables['appBlack'],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pagingController.refresh();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlavorConfig
                          .instance.variables['appPrimaryAccentColor'],
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      'Retry',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
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
          newPageErrorIndicatorBuilder: (context) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  pagingController.refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      FlavorConfig.instance.variables['appPrimaryAccentColor'],
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text(
                  'Retry',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          },
          noItemsFoundIndicatorBuilder: (context) {
            return Center(
              child: Text(
                'NO\nPOST',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: FlavorConfig.instance.variables['appGrey'],
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
