import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:html/parser.dart' show parse;
import '../controllers/search_controller.dart';
import '../models/post_model.dart';
import '../screens/post_detail_screen.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          widget.searchKeyword,
          style: TextStyle(
            color: FlavorConfig.instance.variables['appBlack'],
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => searchPagingController.refresh()),
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
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
                        searchPagingController.refresh();
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
                    searchPagingController.refresh();
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
              );
            },
            noItemsFoundIndicatorBuilder: (context) {
              return Center(
                child: Text(
                  'RESULT\nNOT\nFOUND',
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
