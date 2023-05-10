import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:html/parser.dart' show parse;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import '../ad_helper.dart';
import '../fb_ad_helper.dart';
import '../globals.dart';
import '../controllers/bookmark_controller.dart';
import '../controllers/post_detail_controller.dart';
import '../controllers/tag_controller.dart';
import '../databases/bookmark_database.dart';
import '../models/post_detail_model.dart';
import '../models/post_model.dart';
import '../models/tag_model.dart';
import '../screens/category_detail_screen.dart';
import '../screens/image_detail_screen.dart';
import '../screens/tag_detail_screen.dart';
import '../theme.dart';
import '../widgets/states/loading_state.dart';
import '../widgets/post_banner_admob.dart';
import '../widgets/post_item_card.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.postID,
  });

  final int postID;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _controller = PostDetailController();
  final _bookmarkController = BookmarkController();
  BookmarkDBManager bookmarkDatabase = BookmarkDBManager.instance;
  bool isBookmarkAlreadyExist = false;

  Future<PostDetail?>? _fetchedPostDetail;

  @override
  void initState() {
    super.initState();
    _getArticleSettings();
    _checkBookmarkData();
    _loadInterstitialAd();
    _loadFBInterstitialAd();
    _loadFBBannerAd();
    _fetchedPostDetail = _controller.getPostDetail(widget.postID);
  }

  Future<void> _getArticleSettings() async {
    if (articleBox?.get('articleFontSize') == null) {
      await articleBox?.put('articleFontSize', 16.0);
    }
  }

  void _checkBookmarkData() async {
    Database db = await bookmarkDatabase.db;

    List checkData = await db.query(
      "post_bookmark",
      where: "post_id = ${widget.postID}",
    );

    if (checkData.isNotEmpty) {
      setState(() {
        isBookmarkAlreadyExist = true;
      });
    }
  }

  InterstitialAd? _interstitialAd;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _interstitialAd = null;

              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, adError) {
              _interstitialAd = null;

              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to load interstitial ad: ${error.message}');

          _interstitialAd = null;

          _interstitialAd!.dispose();
          _loadInterstitialAd();
        },
      ),
    );
  }

  bool _isFBInterstitialAdLoaded = false;

  void _loadFBInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: FBAdHelper.interstitialAdPlacementId,
      listener: (result, value) {
        debugPrint('>> FAN > Interstitial Ad: $result --> $value');
        if (result == InterstitialAdResult.LOADED) {
          setState(() {
            _isFBInterstitialAdLoaded = true;
          });
        }

        if (result == InterstitialAdResult.ERROR &&
            value['invalidated'] == true) {
          setState(() {
            _isFBInterstitialAdLoaded = false;
          });
          _loadFBInterstitialAd();
        }

        if (result == InterstitialAdResult.DISMISSED &&
            value['invalidated'] == true) {
          setState(() {
            _isFBInterstitialAdLoaded = false;
          });
          _loadFBInterstitialAd();
        }
      },
    );
  }

  Widget _facebookBannerAd = const SizedBox.shrink();

  void _loadFBBannerAd() {
    setState(() {
      _facebookBannerAd = Column(
        children: [
          const SizedBox(height: 20),
          FacebookBannerAd(
            bannerSize: BannerSize.STANDARD,
            keepAlive: true,
            placementId: FBAdHelper.bannerAdPlacementId,
            listener: (result, value) {
              debugPrint("Banner Ad: $result -->  $value");
              if (result == BannerAdResult.ERROR &&
                  value["invalidated"] == true) {
                setState(() {
                  _facebookBannerAd = const SizedBox.shrink();
                });
              }
            },
          ),
        ],
      );
    });
    debugPrint('facebookBannerAd = $_facebookBannerAd');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return FutureBuilder<PostDetail?>(
      future: _fetchedPostDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(),
            body: const LoadingState(),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Unable to View Post',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        PostDetail postDetailData = snapshot.data!;

        final rawTitleString = parse(postDetailData.title.rendered);
        final String parsedTitleString =
            parse(rawTitleString.body!.text).documentElement!.text;

        void bookmarkPost() async {
          _bookmarkController.addBookmark(
            postID: postDetailData.id,
            postTitle: parsedTitleString,
            postCategory: postDetailData.postTerms.first.name,
            postDateTime: postDetailData.date.toIso8601String(),
            postImageUrl: postDetailData.featuredImageSrc.large,
          );

          setState(() {
            isBookmarkAlreadyExist = true;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post bookmarked'),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            ),
          );
        }

        void unbookmarkPost() async {
          Database db = await bookmarkDatabase.db;

          await db.delete("post_bookmark", where: "post_id = ${widget.postID}");

          setState(() {
            isBookmarkAlreadyExist = false;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post removed from bookmark'),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            ),
          );
        }

        Widget postDetailBannerAd() {
          if (FlavorConfig.instance.variables['adProvider'] == 'Google AdMob') {
            return StatefulBuilder(
              builder: (context, setState) {
                return const PostBannerAdMob();
              },
            );
          } else {
            return _facebookBannerAd;
          }
        }

        return WillPopScope(
          onWillPop: () async {
            if (FlavorConfig.instance.variables['adProvider'] ==
                'Google AdMob') {
              if (_interstitialAd == null) {
                _loadInterstitialAd();
              }

              if (_interstitialAd != null) {
                await _interstitialAd!.show();
              }
            } else if (FlavorConfig.instance.variables['adProvider'] ==
                'Facebook Ads') {
              if (_isFBInterstitialAdLoaded == true) {
                await FacebookInterstitialAd.showInterstitialAd(delay: 2000);
              } else {
                debugPrint("Interstial Ad not yet loaded!");
              }
            }

            Future.delayed(
              Duration.zero,
              () => Navigator.of(context).popUntil(ModalRoute.withName('/')),
            );

            return true;
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            extendBody: true,
            appBar: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 0,
            ),
            body: DraggableHome(
              title: Text(
                FlavorConfig.instance.variables['appName']
                    .toString()
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (FlavorConfig.instance.variables['adProvider'] ==
                      'Google AdMob') {
                    if (_interstitialAd == null) {
                      _loadInterstitialAd();
                    }

                    if (_interstitialAd != null) {
                      await _interstitialAd!.show();
                    }
                  } else if (FlavorConfig.instance.variables['adProvider'] ==
                      'Facebook Ads') {
                    if (_isFBInterstitialAdLoaded == true) {
                      await FacebookInterstitialAd.showInterstitialAd(
                          delay: 2000);
                    } else {
                      debugPrint("Interstial Ad not yet loaded!");
                    }
                  }

                  if (!mounted) return;
                  Navigator.of(context).popUntil(ModalRoute.withName('/'));
                },
              ),
              alwaysShowLeadingAndAction: true,
              appBarColor: AppTheme.isDark
                  ? FlavorConfig.instance.variables['appDarkPrimaryAccentColor']
                  : Theme.of(context).primaryColor,
              headerExpandedHeight: 0.2,
              headerWidget: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageDetailScreen(
                        imageUrl: postDetailData.featuredImageSrc.large,
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: postDetailData.featuredImageSrc.large,
                  color: Colors.black.withOpacity(0.5),
                  colorBlendMode: BlendMode.darken,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 1.5,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 1.5,
                      color: Theme.of(context).dividerTheme.color,
                      child: Center(
                        child: LoadingAnimationWidget.prograssiveDots(
                          color: Theme.of(context).iconTheme.color!,
                          size: 50,
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 1.5,
                      color: Theme.of(context).dividerTheme.color,
                      child: const Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              ),
              body: [
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  shrinkWrap: true,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CategoryDetailScreen(
                                  categoryID: postDetailData.postTerms.first.id,
                                  categoryName:
                                      postDetailData.postTerms.first.name,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.isDark
                                ? FlavorConfig.instance
                                    .variables['appDarkSecondaryAccentColor']
                                : FlavorConfig.instance
                                    .variables['appSecondaryAccentColor'],
                            elevation: 0,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            maximumSize: Size(
                              MediaQuery.of(context).size.width / 2,
                              40,
                            ),
                          ),
                          child: Text(
                            postDetailData.postTerms.first.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            Share.share(postDetailData.link);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.isDark
                                ? Theme.of(context).canvasColor
                                : FlavorConfig
                                    .instance.variables['appLightGrey'],
                            elevation: 0,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Icon(
                            Icons.shortcut,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (isBookmarkAlreadyExist == false) {
                              bookmarkPost();
                            } else {
                              unbookmarkPost();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBookmarkAlreadyExist
                                ? AppTheme.isDark
                                    ? FlavorConfig.instance
                                        .variables['appDarkPrimaryAccentColor']
                                    : FlavorConfig.instance
                                        .variables['appPrimaryAccentColor']
                                : AppTheme.isDark
                                    ? Theme.of(context).canvasColor
                                    : FlavorConfig
                                        .instance.variables['appLightGrey'],
                            elevation: 0,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Icon(
                            isBookmarkAlreadyExist
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            color: isBookmarkAlreadyExist
                                ? FlavorConfig
                                    .instance.variables['appDarkPrimaryColor']
                                : Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      parsedTitleString,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'by ',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              postDetailData.authorDetails.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Text(
                                DateFormat('dd MMMM y')
                                    .format(postDetailData.date),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                thickness: 2,
                                indent: 3,
                                endIndent: 3,
                              ),
                              Text(
                                DateFormat('HH:m').format(postDetailData.date),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(
                      thickness: 2,
                    ),
                    const SizedBox(height: 20),
                    HtmlWidget(
                      postDetailData.content.rendered,
                      textStyle: TextStyle(
                        fontSize: articleBox!.get('articleFontSize'),
                        fontWeight: FontWeight.w500,
                      ),
                      enableCaching: true,
                      onTapImage: (imageMetadata) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ImageDetailScreen(
                              imageUrl: imageMetadata.sources.first.url,
                            ),
                          ),
                        );
                      },
                      onTapUrl: (tappedUrl) {
                        FlutterWebBrowser.openWebPage(
                          url: tappedUrl,
                          customTabsOptions: CustomTabsOptions(
                            defaultColorSchemeParams:
                                CustomTabsColorSchemeParams(
                              toolbarColor: Theme.of(context).primaryColor,
                            ),
                            showTitle: true,
                          ),
                        );
                        debugPrint('OnTapUrl fired');
                        return true;
                      },
                    ),
                    PostTag(postID: widget.postID),
                    postDetailBannerAd(),
                    RelatedPost(
                      categoryID: postDetailData.postTerms.first.id,
                      postKeyword: parsedTitleString.split('').first,
                      excludePostID: postDetailData.id,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }
}

class PostTag extends StatefulWidget {
  const PostTag({super.key, required this.postID});

  final int postID;

  @override
  State<PostTag> createState() => _PostTagState();
}

class _PostTagState extends State<PostTag> {
  final _tagController = TagController();

  Future<List<Tag>?>? _fetchedTagFromPost;

  @override
  void initState() {
    super.initState();
    _fetchedTagFromPost = _tagController.getAllTagsFromPost(widget.postID);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Tag>?>(
      future: _fetchedTagFromPost,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Tag',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: snapshot.data!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3 / 1,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                ),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Tag tagData = snapshot.data![index];

                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TagDetailScreen(
                            tagID: tagData.id,
                            tagName: tagData.name,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.isDark
                          ? Theme.of(context).primaryColor
                          : FlavorConfig
                              .instance.variables['appPrimaryAccentColor'],
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      tagData.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.isDark
                            ? FlavorConfig
                                .instance.variables['appDarkPrimaryAccentColor']
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class RelatedPost extends StatefulWidget {
  const RelatedPost({
    super.key,
    required this.categoryID,
    required this.postKeyword,
    required this.excludePostID,
  });

  final int categoryID;
  final String postKeyword;
  final int excludePostID;

  @override
  State<RelatedPost> createState() => _RelatedPostState();
}

class _RelatedPostState extends State<RelatedPost> {
  final _controller = PostDetailController();

  Future<List<Post>?>? _fetchedRelatedPost;

  @override
  void initState() {
    super.initState();
    _fetchedRelatedPost = _controller.getRelatedPost(
      categoryID: widget.categoryID,
      searchKeyword: widget.postKeyword,
      excludePostID: widget.excludePostID,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>?>(
      future: _fetchedRelatedPost,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Divider(
                thickness: 2,
              ),
              const SizedBox(height: 20),
              const Text(
                'Related Post',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 40),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  Post postData = snapshot.data![index];

                  final rawTitleString = parse(postData.title.rendered);
                  final String parsedTitleString =
                      parse(rawTitleString.body!.text).documentElement!.text;

                  final isToday = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  );

                  return PostItem(
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
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  height: 20,
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
