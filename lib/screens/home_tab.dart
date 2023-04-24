import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:html/parser.dart' show parse;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';
import '../controllers/post_controller.dart';
import '../models/menu_model.dart';
import '../models/post_model.dart';
import '../screens/post_detail_screen.dart';
import '../screens/states/empty_state.dart';
import '../screens/states/failed_state.dart';
import '../screens/states/loading_state.dart';
import '../screens/states/refresh_state.dart';
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
                unselectedLabelColor:
                    FlavorConfig.instance.variables['appGrey'],
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                automaticIndicatorColorAdjustment: true,
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
  BannerAd? _bannerAd;

  Future<void> _loadBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate() - 40,
    );

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: adSize!,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _bannerAd = null;
          });
          debugPrint('Failed to load banner ad: ${error.message}');
          ad.dispose();
        },
        onAdClosed: (ad) {
          setState(() {
            _bannerAd = null;
          });
          ad.dispose();
        },
      ),
    );
    return _bannerAd!.load();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _loadBannerAd);
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
                    Future.delayed(Duration.zero, _loadBannerAd);
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
                            postTitle: postData.title.rendered,
                            postCategory: postData.postTerms.first.name,
                            postDateTime: postData.date.toIso8601String(),
                            postImageUrl: postData.featuredImageSrc.large,
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
                            postTitle: postData.title.rendered,
                            postCategory: postData.postTerms.first.name,
                            postDateTime: postData.date.toIso8601String(),
                            postImageUrl: postData.featuredImageSrc.large,
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
          if (index == 5 && _bannerAd != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(
                    key: Key(_bannerAd!.adUnitId),
                    ad: _bannerAd!,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          } else {
            return const SizedBox(height: 30);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
