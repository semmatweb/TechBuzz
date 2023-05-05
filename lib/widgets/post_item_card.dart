import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme.dart';

class PostItem extends StatelessWidget {
  const PostItem({
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postCategory!,
                  style: TextStyle(
                    color: AppTheme.isDark
                        ? FlavorConfig
                            .instance.variables['appDarkSecondaryAccentColor']
                        : Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  postTitle!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  postDateTime!,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall!.color,
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
            imageUrl: postImageUrl!,
            imageBuilder: (context, imageProvider) => Container(
              width: MediaQuery.of(context).size.width / 3.5,
              height: MediaQuery.of(context).size.width / 3.5,
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
                height: MediaQuery.of(context).size.width / 3.5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerTheme.color,
                  borderRadius: BorderRadius.circular(12),
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
                width: MediaQuery.of(context).size.width / 3.5,
                height: MediaQuery.of(context).size.width / 3.5,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerTheme.color,
                  borderRadius: BorderRadius.circular(12),
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
        ],
      ),
    );
  }
}
