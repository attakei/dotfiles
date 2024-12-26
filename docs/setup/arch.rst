==========
Arch Linux
==========

基本要件
========

* インストール対象のユーザーがいること。
* pacmanなどを用いて、wezterm, nushell, miseがすべてインストールされていること。

.. code-block:: console
   :caption: Pacman

    sudo pacman -S wezterm nushell mise

.. code-block:: console
   :caption: Paru

    paru -S wezterm nushell mise ghq

セットアップ
============

.. code-block:: console

    ghq get attakei/dotfiles
    cd attakei/dotfiles
    nu tools/setup

