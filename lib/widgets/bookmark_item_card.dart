import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BookmarkPostItem extends StatelessWidget {
  const BookmarkPostItem({
    super.key,
    required this.onTap,
    required this.onButtonPressed,
    required this.bookmarkPostTitle,
    required this.bookmarkPostCategory,
    required this.bookmarkPostDateTime,
    required this.bookmarkPostImageUrl,
  });

  final void Function()? onTap;
  final void Function()? onButtonPressed;

  final String bookmarkPostTitle;
  final String bookmarkPostCategory;
  final String bookmarkPostDateTime;
  final String bookmarkPostImageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmarkPostCategory,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      bookmarkPostTitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 54, 54, 54),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      bookmarkPostDateTime,
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 114, 114, 114),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 24,
              ),
              CachedNetworkImage(
                imageUrl: bookmarkPostImageUrl,
                imageBuilder: (context, imageProvider) => Container(
                  width: MediaQuery.of(context).size.width / 3.5,
                  height: MediaQuery.of(context).size.width / 4.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.1),
                        BlendMode.srcOver,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Container(
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: MediaQuery.of(context).size.width / 4.5,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 224, 224, 224),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: LoadingAnimationWidget.prograssiveDots(
                        color: const Color.fromARGB(255, 192, 192, 192),
                        size: 50,
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return Container(
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: MediaQuery.of(context).size.width / 4.5,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 224, 224, 224),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.error,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
              child: const Text('Delete'),
            ),
          )
        ],
      ),
    );
  }
}
