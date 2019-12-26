
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

const _TEXT = """
* 本アプリは [株式会社ルネサンス](https://www.s-renaissance.co.jp/) および [株式会社インボディ・ジャパン](https://www.inbody.co.jp/) が提供する公式アプリではありません。[スポーツクラブ ルネサンス](https://www.s-re.jp/) および [体成分分析装置InBody](https://www.inbody.co.jp/inbody-series/) のユーザーが提供する非公式アプリです。
* 本アプリが収集した情報は、本アプリの機能提供のために利用します。目的外の利用を行うことはありません。
* 本アプリに関するレビューやフィードバックは App Store または Google Play にてお願いいたします。
* 本アプリは InBody370 で出力された測定結果のみ読み込み可能です。
* Icons made by [Freepik](https://www.flaticon.com/authors/freepik) from [www.flaticon.com](https://www.flaticon.com/)
""";

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('このアプリについて'),
      ),
      body: SafeArea(
        child: Markdown(
          data: _TEXT,
          onTapLink: ((url) => launch(url)),
        )
      )
    );
  }
}
