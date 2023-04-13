import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sqflite/sqflite.dart';
import '../controllers/bookmark_controller.dart';
import '../databases/bookmark_database.dart';
import '../screens/post_detail_screen.dart';
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
          return Center(
            child: LoadingAnimationWidget.prograssiveDots(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
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
              children: const [
                SizedBox(
                  height: 20,
                ),
                Divider(
                  thickness: 2,
                  color: Color.fromARGB(255, 224, 224, 224),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: Text(
              'NO\nBOOK\nMARK',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 192, 192, 192),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          );
        }
      },
    );
  }
}
