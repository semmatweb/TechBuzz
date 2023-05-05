import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:ini_news_flutter/theme.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FeaturedPostItem extends StatelessWidget {
  const FeaturedPostItem({
    super.key,
    required this.onTap,
    required this.postTitle,
    required this.postCategory,
    required this.postDateTime,
    required this.postImageUrl,
  });

  final void Function()? onTap;

  final String? postTitle;
  final String? postCategory;
  final String? postDateTime;
  final String? postImageUrl;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      child: CachedNetworkImage(
        imageUrl: postImageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width / 1.5,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOver,
              ),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 15,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppTheme.isDark
                        ? FlavorConfig
                            .instance.variables['appDarkSecondaryAccentColor']
                        : FlavorConfig
                            .instance.variables['appSecondaryAccentColor'],
                  ),
                  child: Text(
                    postCategory!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  postTitle!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  postDateTime!,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width / 1.5,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
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
            decoration: BoxDecoration(
              color: Theme.of(context).dividerTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
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
    );
  }
}
