return {
  'vim-skk/skkeleton',
  dependencies = {
    {
      'vim-denops/denops.vim',
      lazy = false,
    },
  },
  -- keys による遅延ロードは、初回押下時に denops の skkeleton 登録が未完了で
  -- 入力が固まる競合を起こすため使わない。denops (lazy=false) がロード済みの
  -- 起動直後に skkeleton をロードしておき、キーマップは config 内で張る。
  event = 'VeryLazy',
  config = function()
    -- SKK server への接続先ホストを解決する。
    --   * ネイティブ環境 (Windows / macOS): 127.0.0.1
    --   * WSL 上の NeoVim (NAT モード): Windows ホスト側で動く SKK server に
    --     接続するため、`ip route` のデフォルトゲートウェイ (= Windows ホスト IP)
    --     を使う。/etc/resolv.conf の nameserver は Tailscale 等に書き換えられ
    --     ホスト IP と一致しないことがあるため参照しない。
    --   * WSL2 のミラーモード、または SKK server を WSL 内で起動する構成では
    --     常に 127.0.0.1 でよい (その場合は下の WSL 分岐を無効化する)。
    local function skk_server_host()
      if vim.fn.has('wsl') == 1 then
        local ok, output = pcall(vim.fn.system, { 'ip', 'route', 'show', 'default' })
        if ok then
          local ip = output:match('via%s+(%d+%.%d+%.%d+%.%d+)')
          if ip then
            return ip
          end
        end
      end
      return '127.0.0.1'
    end

    -- 変換辞書のソースとして SKK server (skk_server) を使う。
    -- 旧 API の useSkkServer は廃止され、sources へ 'skk_server' を指定する方式。
    vim.fn['skkeleton#config']({
      sources = { 'skk_server' },
      skkServerHost = skk_server_host(),
      skkServerPort = 1178,
      -- 以下は後日再調整する挙動オプション（必要になったらコメント解除する）。
      -- eggLikeNewline = true,          -- 変換確定時の <CR> で改行しない
      -- registerConvertResult = true,   -- google-suggest 等の変換結果をユーザー辞書に登録
      -- showCandidatesCount = 4,        -- 候補一覧を表示し始めるまでの候補数
      -- markerHenkan = '▽',             -- 変換入力中のマーカー
      -- markerHenkanSelect = '▼',       -- 候補選択中のマーカー
      -- skkServerReqEnc = 'euc-jp',     -- サーバーへ送る際のエンコーディング（既定 euc-jp）
      -- skkServerResEnc = 'euc-jp',     -- サーバーからの応答のエンコーディング（既定 euc-jp）
      -- skkServerTimeout = 5000,        -- サーバー応答のタイムアウト(ms)
    })

    -- insert / command-line モードで <C-j> により SKK 入力を ON/OFF する。
    vim.keymap.set({ 'i', 'c' }, '<C-j>', '<Plug>(skkeleton-toggle)', { desc = 'Toggle SKK input' })
  end,
}
