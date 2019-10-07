import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:danhs_ecommerce/util/item_detail_utils.dart' as itemDetailUtils;
import 'package:danhs_ecommerce/util/network_utils.dart' as networkUtils;

class ItemDetailPage extends StatefulWidget {
  final String itemId;

  ItemDetailPage({Key key, @required this.itemId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemDetailWidget(itemId);
  }
}

class _ItemDetailWidget extends State<ItemDetailPage> {
  final String itemId;

  _ItemDetailWidget(this.itemId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  updateItemDetailWidget(),
    );
  }

  Widget updateItemDetailWidget() {
    return new FutureBuilder(
      future: getItemDetail(),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            if (snapshot.hasData) {
              var results = itemDetailUtils.ItemDetail.fromJson(snapshot.data);
              return ItemDescriptionWidget(results);
            } else {
              return new Container();
            }
        }
      }
    );
  }

  Future<Map> getItemDetail() async {
    String apiUrl = 'https://api.ebay.com/buy/browse/v1/item/$itemId';

    final response = await http.get(
      apiUrl,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer ${networkUtils.getToken()}",
      }
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 400 || response.statusCode == 401) {
      String authUrl = 'https://api.ebay.com/identity/v1/oauth2/token';
      String credentials = "${networkUtils.APP_ID}:${networkUtils.CERT_ID}";
      String encodedCredentials = base64Url.encode(utf8.encode(credentials));

      final authResponse = await http.post(
        authUrl,
        headers: {
          "Authorization": "Basic $encodedCredentials",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          "grant_type": "client_credentials",
          "scope": "https://api.ebay.com/oauth/api_scope",
        },
      );

      if (authResponse.statusCode == 200) {
        networkUtils.setToken(json.decode(authResponse.body)["access_token"]);
        return getItemDetail();
      } else {
        throw Exception('Failed to acquire authentication');
      }     
    }
    else {
      throw Exception('Failed to fetch data');
    }
  }
}

class ItemDescriptionWidget extends StatelessWidget {
  final itemDetailUtils.ItemDetail item;
  ItemDescriptionWidget(this.item);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(       
        children: <Widget>[
          ItemDetailHeader(item),
          ItemShortDescription(item),
          PhotoScroller(item),
        ],
      )
    );
  }
}

class PhotoScroller extends StatelessWidget {
  final itemDetailUtils.ItemDetail item;

  PhotoScroller(this.item);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Photos',
            style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 18.0),
          ),
        ),
        SizedBox.fromSize(
          size: const Size.fromHeight(100.0),
          child: ListView.builder(
            itemCount: item.additionalImages.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 8.0, left: 20.0),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Container (
                    height: 160.0,
                    width: 120.0,
                    decoration: BoxDecoration (
                      image: DecorationImage (
                        fit: BoxFit.cover,
                        image: NetworkImage(item.image.imageUrl),
                      )
                    ),
                  ),
                ),
              );
            },
          )
        )
      ],
    );
  }
}

class ItemShortDescription extends StatelessWidget {
  final itemDetailUtils.ItemDetail item;

  ItemShortDescription(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Description',
            style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 18.0),
          ),
          SizedBox(height: 8.0,),
          Text(
            item.shortDescription,
            style: Theme.of(context).textTheme.body1.copyWith(
              color: Colors.black45,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemDetailHeader extends StatelessWidget {
  final itemDetailUtils.ItemDetail item;

  ItemDetailHeader(this.item);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 180.0),
          child: ArcBannerImage(),
        ),
        Positioned(
          left: 20.0,
          right: 20.0,
          bottom: 0.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Material(
                borderRadius: BorderRadius.circular(4.0),
                elevation: 2.0,
                child: Container (
                  height: 180.0,
                  width: 100.0,
                  decoration: BoxDecoration (
                    borderRadius: BorderRadius.only (
                      bottomLeft: Radius.circular(5),
                      topLeft: Radius.circular(5)
                    ),
                    image: DecorationImage (
                      fit: BoxFit.cover,
                      image: NetworkImage(item.image.imageUrl),
                    )
                  ),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.title,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 8.0),
                    PricingInformation(item),
                    SizedBox(height: 12.0,),
                    SellerInformation(item),
                  ],
                )
              )
            ],
          ),
        ),
      ],
    );
  }
}

class SellerInformation extends StatelessWidget {
  final itemDetailUtils.ItemDetail item;

  SellerInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      textDirection: TextDirection.ltr,
      verticalDirection: VerticalDirection.down,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              item.seller.username,
              style: Theme.of(context).textTheme.title.copyWith(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).accentColor,
              ),
            ),
            SizedBox(height: 4.0,),
            Text(
              'Seller',
              style: Theme.of(context).textTheme.caption.copyWith(color: Colors.black45),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              item.seller.feedbackScore,
              style: Theme.of(context).textTheme.title.copyWith(
                fontWeight: FontWeight.w400,
                color: Theme.of(context).accentColor,
              ),
            ),
            SizedBox(height: 4.0,),
            Text(
              'Feedback Score',
              style: Theme.of(context).textTheme.caption.copyWith(color: Colors.black45),
            ),
          ],
        )
      ],
    );
  } 
}

class PricingInformation extends StatelessWidget {
  final itemDetailUtils.ItemDetail item;

  PricingInformation(this.item);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: '\$ ' + item.price.value + " ",
                style: TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.normal,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                )
              ),
              TextSpan(
                text: item.price.currency,
                style: TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.normal,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                )
              )
            ]
          ),
        ),
        SizedBox(width: 8.0,),
        Text(
          item.condition,
          style: TextStyle(
            fontSize: 15.0,
            fontStyle: FontStyle.normal,
            color: item.condition == "New" ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ArcBannerImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return ClipPath(
      clipper: ArcClipper(),
      child: Image.asset(
        'assets/ebay_logo.png',
        width: screenWidth,
        height: 180.0,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 30);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}