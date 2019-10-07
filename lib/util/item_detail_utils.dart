class ItemDetail {
  final String title;
  final String shortDescription;
  final Price price;
  final String condition;
  final ItemLocation itemLocation;
  final Image image;
  final List<Image> additionalImages;
  final Seller seller;

  ItemDetail({this.title, this.shortDescription, this.price, this.condition, this.image, this.itemLocation, this.additionalImages, this.seller});

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    List<Image> images = [];
    
    if (json['additionalImages'] != null) {
      var list = json['additionalImages'] as List;
      images = list.map((i) => Image.fromJson(i)).toList();
    }

    return new ItemDetail(
      title: json['title'],
      shortDescription: json['shortDescription'],
      price: Price.fromJson(json['price']),
      condition: json['condition'],
      itemLocation: ItemLocation.fromJson(json['itemLocation']),
      image: Image.fromJson(json['image']),
      additionalImages: images,
      seller: Seller.fromJson(json['seller']),
    );
  }
}

class Price {
  final String value;
  final String currency;

  Price({this.currency, this.value});

  factory Price.fromJson(Map<String, dynamic> json) {
    return new Price(
      value: json['value'],
      currency: json['currency'],
    );
  }
}

class ItemLocation {
  final String city;
  final String stateOrProvince;
  final String country;

  ItemLocation({this.city, this.country, this.stateOrProvince});

  factory ItemLocation.fromJson(Map<String, dynamic> json) {
    return new ItemLocation(
      city: json['city'],
      stateOrProvince: json['stateOrProvince'],
      country: json['country'],
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

class Seller {
  final String username;
  final String feedbackScore;

  Seller({this.feedbackScore, this.username});

  factory Seller.fromJson(Map<String, dynamic> json) {
    return new Seller(
      username: json['username'],
      feedbackScore: json['feedbackScore'].toString(),
    );
  }
}