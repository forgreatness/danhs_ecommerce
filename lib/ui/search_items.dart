import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:danhs_ecommerce/util/item_summaries_utils.dart' as itemSummariesUtils;
import 'package:danhs_ecommerce/util/network_utils.dart' as networkUtils;
import 'package:danhs_ecommerce/ui/item_detail.dart' as itemDetailUi;

class SearchItems extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SearchItemsState();
}

class _SearchItemsState extends State<SearchItems> {
  var _searchKeyword;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.blue,
        title: new Text('Danh\'s Ecommerce', textAlign: TextAlign.left),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String query = await showSearch<String>(
                context: context,
                delegate: _SearchItemDelegate(hintText: "Search for any item"),
              );
              if (query != null && query != _searchKeyword) {
                _searchKeyword = query;
              }
            },
          )
        ],
      ),
      body: (_searchKeyword == null || _searchKeyword.isEmpty) ? Container() : updateListOfItemsWidget(_searchKeyword),
    );
  }

  Widget updateListOfItemsWidget(String keyword) {
    return new FutureBuilder(
      future: getItems(keyword),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
          var results = itemSummariesUtils.ItemSummaries.fromJson(snapshot.data);
          return ItemList(items: results);
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) {
          if (snapshot.hasError) {
            return Center(
              child: Container (
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width*0.8,
                child: Text(
                  "ERROR: " + snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Container();
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }

  Future<Map> getItems(String query) async {
    String apiUrl = 'https://api.ebay.com/buy/browse/v1/item_summary/search?q=$query&limit=20';

    final response = await http.get(
      apiUrl,
      headers: {
        HttpHeaders.authorizationHeader: "Bearer ${networkUtils.getToken()}",
      }
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
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
        return getItems(query);
      } else if (authResponse.statusCode == 429 || authResponse.statusCode == 400) {
        throw Exception('The request limit has been reached for the resource');
      } else {
        throw Exception('Failed to acquire authentication');
      }     
    }
    else {
      throw Exception('Failed to fetch data');
    }
  }
}

class ItemList extends StatefulWidget {
  final itemSummariesUtils.ItemSummaries items;

  ItemList({Key key, @required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ItemListWidget(items);
  }
}

class _ItemListWidget extends State<ItemList> {
  final itemSummariesUtils.ItemSummaries items;

  _ItemListWidget(this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: items.itemSummaries.length,
        itemBuilder: (context, index) {
          return ListTile(
            key: Key(items.itemSummaries[index].title),
            title: Card(
              elevation: 5,
              child: Container(
                height: 100.0,
                child: Row(
                  children: <Widget>[
                    ListItemImage(items.itemSummaries[index]),
                    Container(
                      height: 100.0,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListItemTitle(items.itemSummaries[index]),
                            ListItemPrice(items.itemSummaries[index]),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => itemDetailUi.ItemDetailPage(itemId: items.itemSummaries[index].itemId)));
            },
          );
        },
      )
    );
  }
}

class ListItemPrice extends StatelessWidget {
  final itemSummariesUtils.Item item;

  ListItemPrice(this.item);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(3, 0, 0, 3),
      child: Container(
        width: 260,
        child: Text.rich(
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
          )
        ),
      )
    );
  }
}

class ListItemTitle extends StatelessWidget {
  final itemSummariesUtils.Item item;

  ListItemTitle(this.item);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(3, 0, 0, 3),
      child: Container(
        width: 260,
        child: Text(
          item.title,
          style: new TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: 15.0,
            color: Colors.black,
            fontWeight: FontWeight.w500
          ),
          textAlign: TextAlign.left,
        ),
      )
    );
  }
}

class ListItemImage extends StatelessWidget {
  final itemSummariesUtils.Item item;

  ListItemImage(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      width: 70.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(5),
          topLeft: Radius.circular(5)
        ),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(item.image.imageUrl),
        )
      ),
    );
  }
}

class _SearchItemDelegate extends SearchDelegate<String> {
  _SearchItemDelegate({
    String hintText,
  }) : super(
       searchFieldLabel: hintText,
       keyboardType: TextInputType.text,
       textInputAction: TextInputAction.search,
      );

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isNotEmpty ?
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ) : IconButton(
        icon: const Icon(Icons.mic),
        tooltip: 'Voice input',
        onPressed: () {
          this.query = 'TBW: Get input from voice';
        },
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      title: Text(this.query),
      onTap: () {
        this.close(context, this.query);
      },
    );
  }
}