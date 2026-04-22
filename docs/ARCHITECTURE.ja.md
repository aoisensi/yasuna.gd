# アーキテクチャ

🌐 [English](/docs/ARCHITECTURE.md) | **日本語**

## 基本の流れ

1. `YSNRunner` が `YSNScenario` を読み込んで実行する
2. `YSNScenario` に含まれる `YSNCue` が順に実行される
3. 実行状態は `YSNInstance` と各 `State` に保持される
4.  `YSNRunner.capture()` で状態を取得し、 `YSNRunner.restore()` で復元できる

## 主なクラス

### `YSNRunner`
<sub>extends `Node`</sub>

シナリオを実行する `Node` クラス。  
1つの `YSNRunner` から複数のシナリオを同時に実行することもできる。  

- `act()` シナリオを開始する。
- `capture()` 現在実行中のシナリオの状態を取得できる。
- `restore()` 状態を復元することができる。

アドオン使用者は、ワールド、キャラクター、ドアなどのインゲームノードに `YSNRunner` をぶら下げ、スクリプトから `YSNScenario` を渡して実行させる。  

### `YSNScenario`
<sub>extends `Resource`</sub>

複数のキューとその接続を管理する。  
1枚のグラフが1つの `YSNScenario` に相当する。  
アドオン使用者は、グラフエディタ上で `YSNScenario` を編集し、1シナリオ単位の流れを定義していく。  

### `YSNCue`
<sub>extends `Resource`</sub>

1つのグラフノードが1つの `YSNCue` に相当する。  
多種多様な継承クラスが用意されている。  
アドオン使用者は、 `YSNCue` の子クラスを書いて1処理単位の動きを定義していく。  
しかし `YSNCue` を直接継承する必要はなく(例外はあるかも)、推奨される継承元は以下の3つ。  

- `YSNCueStateless`
- `YSNCueAsync`
- `YSNCueReactive`

#### `YSNCueStateless`
<sub>extends `YSNCue`</sub>

ステートを保持しないシンプルなキュー。  
基本的には即座に完了する処理を実装するのに使う。  

#### `YSNCueStateful`
<sub>extends `YSNCue`</sub>

ステートを保持するキュー。  
`YSNCueAsync` と `YSNCueReactive` の共通基盤で、アドオン使用者が`YSNCueStateful` を直接継承する必要はほぼない。  

#### `YSNCueAsync`
<sub>extends `YSNCueStateful`</sub>

非同期処理をするキュー。  
実行するたびに新しいステートを生成する。  

#### `YSNCueReactive`
<sub>extends `YSNCueStateful`</sub>

複数のフローを受け取れるキュー。  
1インスタンスごとに1つのステートが生成される。  
`YSNCueAsync` との違いは、実行後も別のキューから再入力、中断、通知などの介入が可能。  

#### `YSNCueStateful.State`
<sub>extends `RefCounted`</sub>

ステートの実態。  
`YSNInstance` によって保持され、 `YSNRunner.capture()` や `YSNRunner.restore()` したときのエンコード/デコード処理も`State`に書く。  
`YSNCueAsync` か `YSNCueReactive` を継承したキューを定義する際は `State` も継承して定義する必要がある。  

#### `YSNInstance`
<sub>extends `RefCounted`</sub>

`YSNRunner.act()` が呼び出されるたびに1つ生成される。  
`YSNScenario` と紐づいており、1シナリオの動作を処理する。  

#### `YSNContext`
<sub>extends `RefCounted`</sub>

`YSNCue` などの処理が呼び出されるたびに渡されるコンテキスト。  
`YSNContext` を使ってランナーなどにアクセスできる。
