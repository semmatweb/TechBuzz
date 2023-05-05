import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:intl/intl.dart';
import '../controllers/category_controller.dart';
import '../models/category_model.dart';
import '../screens/category_detail_screen.dart';
import '../widgets/states/failed_state.dart';
import '../widgets/states/loading_state.dart';

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
          return const LoadingState();
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FailedState(
                stateIcon: Icons.error,
                stateText: 'Failed Retrieving Category',
                onPressed: () {
                  setState(() {
                    _fetchedCategory = _controller.getAllCategories();
                  });
                },
              ),
            ],
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
                ? FlavorConfig.instance.variables['appBlack']
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
                padding: const EdgeInsets.all(16),
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
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              NumberFormat.compact().format(categoryData.count),
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
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 3.8,
                            child: Text(
                              categoryData.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: foregroundColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
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
