class ItemSummaries {
  final List<Item> itemSummaries;

  ItemSummaries({this.itemSummaries});

  factory ItemSummaries.fromJson(Map<String, dynamic> json) {
    var list = json['itemSummaries'] as List;
    List<Item> itemList = list.map((i) => Item.fromJson(i)).toList();
    return new ItemSummaries(
      itemSummaries: itemList,
    );
  }
}

class Item {
  final String itemId;
  final String title;
  final Image image;
  final Price price;

  Item({this.itemId, this.title, this.image, this.price});

  factory Item.fromJson(Map<String, dynamic> json) {
    return new Item(
      itemId: json['itemId'],
      title: json['title'],
      image: Image.fromJson(json['image']),
      price: Price.fromJson(json['price']),
    );
  }
}

class Image {
  final String imageUrl;

  Image({this.imageUrl});

  factory Image.fromJson(Map<String, dynamic> json) {
    return new Image(
      imageUrl: json['imageUrl'],
    );
  }
}

class Price{
  final String value;
  final String currency;

  Price({this.value, this.currency});

  factory Price.fromJson(Map<String, dynamic> json) {
    return new Price(
      value: json['value'],
      currency: json['currency'],
    );
  }
}