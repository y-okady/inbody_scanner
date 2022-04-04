# InBody Scanner for ルネサンス

スポーツクラブ ルネサンスに導入されている「InBody 370」の測定結果を読み取って記録します。

## 設定ファイル
### `.env`
```
ADMOB_APP_ID_IOS=<AdMob ID for iOS>
ADMOB_APP_ID_ANDROID=<AdMob ID for Android>
ADMOB_UNIT_ID_IOS=<AdMob Unit ID for iOS>
ADMOB_UNIT_ID_ANDROID=<AdMob Unit ID for Android>
```

### `ios/Runner/GoogleService-Info.plist`
Firebaseの「プロジェクトの設定」ページでダウンロードします。

## ビルド手順
- [Build and release an iOS app](https://docs.flutter.dev/deployment/ios)
