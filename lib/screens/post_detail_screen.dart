import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:html/parser.dart' show parse;
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
import '../widgets/post_item_card.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.postID,
    required this.postTitle,
    required this.postCategory,
    required this.postDateTime,
    required this.postImageUrl,
  });

  final int postID;
  final String postTitle;
  final String postCategory;
  final String postDateTime;
  final String postImageUrl;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _controller = PostDetailController();
  final _bookmarkController = BookmarkController();
  bool isBookmarkAlreadyExist = false;

  @override
  void initState() {
    super.initState();
    checkBookmarkData();
  }

  void checkBookmarkData() async {
    BookmarkDBManager bookmarkDatabase = BookmarkDBManager.instance;
    Database db = await bookmarkDatabase.db;

    final rawTitleString = parse(widget.postTitle);
    final String parsedTitleString =
        parse(rawTitleString.body!.text).documentElement!.text;

    List checkData = await db.query(
      "post_bookmark",
      columns: [
        "post_id",
        "post_title",
        "post_category",
        "post_datetime",
        "post_imageurl",
        "is_bookmarked"
      ],
      where:
          "post_id = ${widget.postID} and post_title = '$parsedTitleString' and post_category = '${widget.postCategory}' and post_datetime = '${widget.postDateTime}' and post_imageurl = '${widget.postImageUrl}' and is_bookmarked = 1",
    );

    if (checkData.isNotEmpty) {
      setState(() {
        isBookmarkAlreadyExist = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return FutureBuilder<PostDetail>(
      future: _controller.getPostDetail(widget.postID),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(),
            body: Center(
              child: LoadingAnimationWidget.prograssiveDots(
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            ),
          );
        }

        PostDetail postDetailData = snapshot.data!;

        final rawPostTitleString = parse(postDetailData.title.rendered);
        final String parsedPostTitleString =
            parse(rawPostTitleString.body!.text).documentElement!.text;

        return Scaffold(
          extendBodyBehindAppBar: true,
          extendBody: true,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Theme.of(context).primaryColor,
            elevation: 0,
            toolbarHeight: 0,
          ),
          body: DraggableHome(
            title: const Text(
              'ININEWS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                height: 1,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            alwaysShowLeadingAndAction: true,
            appBarColor: Theme.of(context).primaryColor,
            headerExpandedHeight: 0.2,
            headerWidget: CachedNetworkImage(
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
                  color: const Color.fromARGB(255, 224, 224, 224),
                  child: Center(
                    child: LoadingAnimationWidget.prograssiveDots(
                        color: const Color.fromARGB(255, 192, 192, 192),
                        size: 50),
                  ),
                );
              },
              errorWidget: (context, url, error) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 1.5,
                  color: const Color.fromARGB(255, 224, 224, 224),
                  child: const Center(
                    child: Icon(Icons.error, size: 50),
                  ),
                );
              },
            ),
            body: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            backgroundColor:
                                const Color.fromARGB(255, 250, 230, 200),
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
                            style: const TextStyle(
                              color: Colors.orange,
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
                            backgroundColor: Colors.grey[300],
                            elevation: 0,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: const Icon(
                            Icons.shortcut,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final rawBookmarkTitleString =
                                parse(postDetailData.title.rendered);
                            final String parsedBookmarkTitleString =
                                parse(rawBookmarkTitleString.body!.text)
                                    .documentElement!
                                    .text;

                            if (isBookmarkAlreadyExist == false) {
                              _bookmarkController.addBookmark(
                                postID: postDetailData.id,
                                postTitle: parsedBookmarkTitleString,
                                postCategory:
                                    postDetailData.postTerms.first.name,
                                postDateTime:
                                    postDetailData.date.toIso8601String(),
                                postImageUrl:
                                    postDetailData.featuredImageSrc.large,
                              );

                              setState(() {
                                isBookmarkAlreadyExist = true;
                              });

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Post bookmarked.'),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            } else {
                              BookmarkDBManager bookmarkDatabase =
                                  BookmarkDBManager.instance;

                              Database db = await bookmarkDatabase.db;

                              await db.delete("post_bookmark",
                                  where: "post_id = ${widget.postID}");

                              setState(() {
                                isBookmarkAlreadyExist = false;
                              });

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Post removed from bookmark.'),
                                  backgroundColor: Colors.black,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBookmarkAlreadyExist
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.15)
                                : Colors.grey[300],
                            elevation: 0,
                            surfaceTintColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Icon(
                            isBookmarkAlreadyExist
                                ? Icons.bookmark
                                : Icons.bookmark_add_outlined,
                            color: isBookmarkAlreadyExist
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      parsedPostTitleString,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 54, 54, 54),
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
                            const Text(
                              'by ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 54, 54, 54),
                              ),
                            ),
                            Text(
                              postDetailData.authorDetails.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 54, 54, 54),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('EEE, dd MMMM y')
                              .format(postDetailData.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 54, 54, 54),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(
                      color: Color.fromARGB(255, 224, 224, 224),
                      thickness: 2,
                    ),
                    const SizedBox(height: 20),
                    HtmlWidget(
                      postDetailData.content.rendered,
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 54, 54, 54),
                        fontSize: 16,
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
                    ),
                    PostTag(postID: widget.postID),
                    RelatedPost(
                      categoryID: postDetailData.postTerms.first.id,
                      postKeyword: parsedPostTitleString.split('').first,
                      excludePostID: postDetailData.id,
                    ),
                    const SizedBox(height: 30),
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
          return Center(
            child: LoadingAnimationWidget.prograssiveDots(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Tag',
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 54, 54),
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
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.15),
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
                      style: TextStyle(color: Theme.of(context).primaryColor),
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
          return Center(
            child: LoadingAnimationWidget.prograssiveDots(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Divider(
                color: Color.fromARGB(255, 224, 224, 224),
                thickness: 2,
              ),
              const SizedBox(height: 20),
              const Text(
                'Related Post',
                style: TextStyle(
                  color: Color.fromARGB(255, 54, 54, 54),
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

                  return PostItem(
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
