import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ini_news_flutter/screens/states/empty_state.dart';
import 'package:ini_news_flutter/screens/states/loading_state.dart';
import 'package:ini_news_flutter/screens/states/failed_state.dart';
import 'package:ini_news_flutter/screens/states/refresh_state.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart' show parse;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';
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
          return const LoadingState();
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return FailedState(
            stateIcon: Icons.error,
            stateText: 'Failed Retrieving Post',
            onPressed: () {
              setState(() {
                _fetchedMenu = _controller.getAllMenu();
              });
            },
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

class PostTab extends StatefulWidget {
  const PostTab({super.key, required this.pagingController});

  final PagingController<int, Post> pagingController;

  @override
  State<PostTab> createState() => _PostTabState();
}

class _PostTabState extends State<PostTab> {
  Future<Widget> _getBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    BannerAd? bannerAd;

    bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: adSize!,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            bannerAd = null;
          });
          debugPrint('Failed to load banner ad: ${error.message}');
          ad.dispose();
        },
        onAdClosed: (ad) {
          setState(() {
            bannerAd = null;
          });
          ad.dispose();
        },
      ),
    );
    await bannerAd!.load();

    return SizedBox(
      width: double.infinity,
      height: bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: bannerAd!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(() => widget.pagingController.refresh()),
      color: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,
      child: PagedListView<int, Post>.separated(
        pagingController: widget.pagingController,
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
            return FailedState(
              stateIcon: Icons.error,
              stateText: 'Failed Retrieving Post',
              onPressed: () {
                widget.pagingController.refresh();
              },
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

            return Column(
              children: [
                if (postData == widget.pagingController.itemList!.first)
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
                if (postData != widget.pagingController.itemList!.first)
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
        separatorBuilder: (context, index) {
          if (index != 0 && index % 5 == 0) {
            return FutureBuilder<Widget>(
              future: _getBannerAd(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return const SizedBox(height: 30);
                }

                return Column(
                  children: [
                    const SizedBox(height: 30),
                    snapshot.data!,
                    const SizedBox(height: 30),
                  ],
                );
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
