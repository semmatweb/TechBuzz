import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../controllers/bookmark_controller.dart';
import '../databases/bookmark_database.dart';
import '../screens/post_detail_screen.dart';
import '../screens/states/empty_state.dart';
import '../screens/states/loading_state.dart';
import '../widgets/bookmark_item_card.dart';

class BookmarkTab extends StatefulWidget {
  const BookmarkTab({super.key});

  @override
  State<BookmarkTab> createState() => _BookmarkTabState();
}

class _BookmarkTabState extends State<BookmarkTab> {
  final _controller = BookmarkController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _controller.getBookmark(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.separated(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> bookmarkData = snapshot.data![index];

              return BookmarkPostItem(
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postID: bookmarkData['post_id'],
                            postTitle: bookmarkData['post_title'],
                            postCategory: bookmarkData['post_category'],
                            postDateTime: bookmarkData['post_datetime'],
                            postImageUrl: bookmarkData['post_imageurl'],
                          ),
                        ),
                      )
                      .then((_) => setState(() {}));
                },
                onButtonPressed: () async {
                  BookmarkDBManager bookmarkDatabase =
                      BookmarkDBManager.instance;

                  Database db = await bookmarkDatabase.db;

                  await db.delete("post_bookmark",
                      where: "id = ${bookmarkData['id']}");

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post removed from bookmark.'),
                      backgroundColor: Colors.black,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  setState(() {});
                },
                bookmarkPostTitle: bookmarkData['post_title'],
                bookmarkPostCategory: bookmarkData['post_category'],
                bookmarkPostDateTime: DateFormat('dd/MM/y | H:mm')
                    .format(DateTime.parse(bookmarkData['post_datetime'])),
                bookmarkPostImageUrl: bookmarkData['post_imageurl'],
              );
            },
            separatorBuilder: (context, index) => Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Divider(
                  thickness: 2,
                  color: FlavorConfig.instance.variables['appLightGrey'],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        } else {
          return const EmptyState(stateText: 'NO\nBOOK\nMARK');
        }
      },
    );
  }
}
