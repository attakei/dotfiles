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
  この環境変数は、ログインシェルの実行より前には定義する必要がある。 [#]_

:AQUA_POLICY_CONFIG:
  「どこでも有効となるアプリケーション」を設定するファイルのパス。

  .. [#] ターミナルエミュレーター起動時のシェルを、aquq管理下にあるNushellとする想定のため。
