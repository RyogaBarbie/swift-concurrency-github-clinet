TCAなどを導入せずにベタなSwiftConcurrencyとSwiftUIを使用したgithub client<br>
apiclinetやViewModel(Logic)部分へのSwiftConcurrencyの導入<br>
Viewなどのライフサイクルで破棄されるように、Taskのライフサイクルを管理するTaskBagの実装<br>
画面遷移やTab、Navigation周りはUIKitに寄せている<br>
<br>
buildするにはルート直下に.envファイルを作成し<br>
PersonalAccessTokenを貼り付けて、`make setup`してください
```
GITHUB_ACCESS_TOKEN=hogehogehoge
```
