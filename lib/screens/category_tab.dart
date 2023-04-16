import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';
import '../screens/category_detail_screen.dart';

class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key});

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  final _controller = CategoryController();

  Future<List<Category>?>? _fetchedCategory;

  @override
  void initState() {
    super.initState();
    _fetchedCategory = _controller.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>?>(
      future: _fetchedCategory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.prograssiveDots(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
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
                  'Failed to fetch category',
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
                    setState(() {
                      _fetchedCategory = _controller.getAllCategories();
                    });
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
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            Category categoryData = snapshot.data![index];

            var backgroundColor = Color.fromARGB(
              255,
              Random().nextInt(256) + 128,
              Random().nextInt(256) + 128,
              Random().nextInt(256) + 128,
            );
            var foregroundColor = backgroundColor.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white;

            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailScreen(
                      categoryID: categoryData.id,
                      categoryName: categoryData.name,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        categoryData.name.substring(0, 1),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.w700,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              categoryData.count.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            categoryData.name,
                            maxLines: 2,
                            style: TextStyle(
                              color: foregroundColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
