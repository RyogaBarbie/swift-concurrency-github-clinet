## About
TCAなどを導入せずにベタなSwiftConcurrencyとSwiftUIを使用したgithub client<br>
apiclinetやViewModel(Logic)部分へのSwiftConcurrencyの導入<br>
Taskを管理する（登録、キャンセル、キャンセルの確認）EffectManagerや<br>
Viewなどのライフサイクルで破棄されるように、Taskのライフサイクルを管理するTaskBagの実装<br>
画面遷移やTab、Navigation周りはUIKitに寄せている
## SetUp
buildするにはルート直下に.envファイルを作成し<br>
PersonalAccessTokenを貼り付けて、`make setup`してください
```
GITHUB_ACCESS_TOKEN=hogehogehoge
```
