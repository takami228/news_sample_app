import 'dart:async';
import 'package:http/http.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
          primarySwatch: Colors.pink,
          primaryColor: const Color(0xFFe91e63),
          accentColor: const Color(0xFFe91e63),
          canvasColor: const Color(0xFFfafafa)
      ),
      home: RssListPage(),
    );
  }
}

//RSS List
class RssListPage extends StatelessWidget {
  final List<String> names = [
    '主要ニュース',
    '国際情勢',
    '国内の出来事',
    'IT関係'
  ];

  final List<String> links = [
    'https://news.yahoo.co.jp/pickup/rss.xml',
    'https://news.yahoo.co.jp/pickup/world/rss.xml',
    'https://news.yahoo.co.jp/pickup/domestic/rss.xml',
    'https://news.yahoo.co.jp/pickup/computer/rss.xml'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yahoo! Checker'),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: items(context),
        ),
      ),
    );
  }

  List<Widget> items(BuildContext context){
    List<Widget> items = [];
    for(var i = 0; i < names.length; i++){
      items.add(
        ListTile(
          contentPadding: EdgeInsets.all(10.0),
          title: Text(
              names[i],
              style: TextStyle(fontSize: 24.0)
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyRssPage(
                    title: names[i],
                    url: links[i]
                ),
              )
            );
          },
        ),
      );
    }
    return items;
  }
}

//RSS Items List
class MyRssPage extends StatefulWidget {
  final String title;
  final String url;

  MyRssPage({@required this.title, @required this.url});

  @override
  _MyRssPageState createState() => new _MyRssPageState(title: title, url: url);
}

class _MyRssPageState extends State<MyRssPage>{
  final String title;
  final String url;
  List<Widget> _items = <Widget>[];

  _MyRssPageState({
    @required this.title,
    @required this.url
  }) { getItems(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(10.0),
          children: _items,
        )
      ),
    );
  }

  void getItems() async {
    List<Widget> list = <Widget>[];
    Response res = await get(url);
    var rssFeed = new RssFeed.parse(res.body);
    for(RssItem item in rssFeed.items){
      list.add(ListTile(
        contentPadding: EdgeInsets.all(10.0),
        title: Text(
          item.title,
          style: TextStyle(
              fontSize: 24.0
          ),
        ),
        subtitle: Text(
          item.pubDate
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ItemDetailPage(
                  item: item,
                  title: title,
                  url: url
                ),
              ),
          );
        },
       ),
      );
    }
    setState(() {
      _items = list;
    });
  }
}

class ItemDetailPage extends StatefulWidget {
  final RssItem item;
  final String title;
  final String url;

  ItemDetailPage({
    @required this.item,
    @required this.title,
    @required this.url,
  });

  @override
  _ItemDetails createState() => new _ItemDetails(item:item);
}

class _ItemDetails extends State<ItemDetailPage> {
  RssItem item;
  Widget _widget = Text('wait...',);
  _ItemDetails({
    @required this.item
  });

  @override
  void initState(){
    super.initState();
    getItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: _widget,
    );
  }

  void getItem() async {
    Response res = await get(item.link);
    dom.Document doc = dom.Document.html(res.body);
    dom.Element htitle = doc.querySelector('h2.tpcNews_title');
    dom.Element hbody = doc.querySelector('p.tpcNews_summary');
    dom.Element newslink = doc.querySelector('p.tpcNews_detailLink').querySelector("a");
    setState(() {
      _widget = SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  htitle.text,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold
                  )
                )
              ),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                      hbody.text,
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold
                      )
                  )
              ),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                        padding: EdgeInsets.all(10.0),
                        child: Text('続きを読む...', style: TextStyle(fontSize: 18.0)),
                        onPressed: (){
                          launch(newslink.attributes["href"]);
                        })
              ),
            ],
          )
        )
      );
    });
  }
}
