import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:sqflite/sqflite.dart';
import '../controllers/bookmark_controller.dart';
import '../databases/bookmark_database.dart';
import '../screens/post_detail_screen.dart';
import '../widgets/states/empty_state.dart';
import '../widgets/states/loading_state.dart';
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

              final isToday = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
              );

              final parsedDateTime =
                  DateTime.parse(bookmarkData['post_datetime']);

              return BookmarkPostItem(
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postID: bookmarkData['post_id'],
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
                bookmarkPostDateTime: parsedDateTime == isToday
                    ? timeago.format(parsedDateTime)
                    : DateFormat('dd MMMM y').format(parsedDateTime),
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
