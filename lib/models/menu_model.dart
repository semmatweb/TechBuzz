// To parse this JSON data, do
//
//     final menu = menuFromJson(jsonString);

import 'dart:convert';

Menu menuFromJson(String str) => Menu.fromJson(json.decode(str));

String menuToJson(Menu data) => json.encode(data.toJson());

class Menu {
  Menu({
    required this.primary,
  });

  List<Primary> primary;

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        primary:
            List<Primary>.from(json["primary"].map((x) => Primary.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "primary": List<dynamic>.from(primary.map((x) => x.toJson())),
      };
}

class Primary {
  Primary({
    required this.parent,
    required this.child,
  });

  Parent parent;
  List<dynamic> child;

  factory Primary.fromJson(Map<String, dynamic> json) => Primary(
        parent: Parent.fromJson(json["parent"]),
        child: List<dynamic>.from(json["child"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "parent": parent.toJson(),
        "child": List<dynamic>.from(child.map((x) => x)),
      };
}

class Parent {
  Parent({
    required this.id,
    required this.title,
    required this.slug,
    required this.menuOrder,
    required this.parentId,
    required this.postType,
    required this.url,
    required this.typeLabel,
    required this.itemId,
  });

  int id;
  String title;
  String slug;
  int menuOrder;
  String parentId;
  String postType;
  String url;
  String typeLabel;
  String itemId;

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
        id: json["ID"],
        title: json["title"],
        slug: json["slug"],
        menuOrder: json["menu_order"],
        parentId: json["parent_id"],
        postType: json["post_type"],
        url: json["url"],
        typeLabel: json["type_label"],
        itemId: json["item_id"],
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "title": title,
        "slug": slug,
        "menu_order": menuOrder,
        "parent_id": parentId,
        "post_type": postType,
        "url": url,
        "type_label": typeLabel,
        "item_id": itemId,
      };
}
