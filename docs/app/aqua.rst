====
aqua
====

:URL: https://aquaproj.github.io/
:Layer: Package layer

役割と利用スタンス
==================

使用OSを問わず、CLI/TUIで利用するアプリケーションの管理をするためのベース。
カスタムレジストリの構築を前提にしつつ、可能なかぎりここでの管理を行う。

次の2点は意識して切り分ける。

* どこでも使うもの
* dotfiles運用のために使うもの

インストール
============

OS layerの初期スクリプトで、下記のことを実施する。

* aquaのインストール

  * Windows: `Scoopを利用する <https://aquaproj.github.io/docs/install#scoop>`_
  * Linux: `Shell Scriptを使う <https://aquaproj.github.io/docs/products/aqua-installer#shell-script>`_

* 環境変数の設定
  
  * aquaが用意する ``bin`` を ``PATH`` へ追加。
  * :ref:`env-vars`: を一通り追加。

.. _env-vars:  

環境変数
========

:AQUA_GLOBAL_CONFIG:
  「どこでも有効となるアプリケーション」を設定するファイルのパス。
  この環境変数は、ログインシェルの実行より前には定義する必要がある。 [#use-nushell-in-aqua]_

  .. [#use-nushell-in-aqua] ターミナルエミュレーター起動時のシェルを、aquq管理下にあるNushellとする想定のため。

:AQUA_POLICY_CONFIG:
  「どこでも有効となるアプリケーション」を設定するファイルのパス。
  この環境変数は、ログインシェルの実行より前には定義する必要がある。 [#use-nushell-in-aqua]_

:PATH:
  aqua管理下にあるアプリのエントリーポイントをここに追加する必要がある。
  この環境変数は、ログインシェルの実行より前には定義する必要がある。 [#use-nushell-in-aqua]_

拡張設定 (extends)
==================

別リポジトリ（個人端末専用の設定など）のaqua設定を、グローバル設定に追加できる。

* ``extends/<名前>`` に、対象リポジトリへのシンボリックリンクを置く（ ``extends/`` はgit管理外）。
* ``scripts/aqua-env.nu`` が ``app/aqua/`` と ``extends/*/app/aqua/`` から
  ``aqua.yaml`` / ``aqua-policy.yaml`` を集め、 :ref:`env-vars` の値を組み立てて保存する。

  * Windows: ユーザー環境変数
  * Linux/macOS: ``~/.config/aqua-env.sh`` （ ``~/.profile`` / ``~/.bashrc`` / ``~/.zshenv`` から読み込む）

* シェルを経由せずに起動するアプリ（ターミナルエミュレーターから直接Nushellを起動する等）にも反映させるため、
  シェル起動時ではなくセットアップ時（ ``task update`` / ``task aqua:env`` ）に値を確定させる。
* ``AQUA_POLICY_CONFIG`` は存在しないパスを含むとエラーになるため、実在するファイルのみを含める。
* 構成を変えた後は ``task aqua:env`` を実行し、起動中のアプリを再起動する。
* 拡張を外した（リンクを消した）後は、Nushell自体もaqua経由で起動するため、
  存在しないポリシーファイルが残っているとNushellも起動できなくなる。
  基本のポリシーのみを指定して再構築する。

  .. code:: console

     $ AQUA_POLICY_CONFIG=$PWD/app/aqua/aqua-policy.yaml nu scripts/aqua-env.nu

補足事項
========

グローバル設定を切り離して、リポジトリ視点では ``aqua.yaml`` が消滅している。

そのままだとGitHub Actions内でインストール等に失敗するので、環境変数の設定とセットアップ時の明示的な設定が必要となる。

.. code:: yaml

   env:
     AQUA_GLOBAL_CONFIG: '${{ github.workspace }}/app/aqua/aqua.yaml'
     AQUA_POLICY_CONFIG: '${{ github.workspace }}/app/aqua/aqua-policy.yaml'
   jobs:
     lint:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v6
         - uses: aquaproj/aqua-installer@11dd79b4e498d471a9385aa9fb7f62bb5f52a73c # v4.0.4
           with:
             aqua_version: v2.51.2
           env:
             AQUA_CONFIG: 'app/aqua/aqua.yaml'
