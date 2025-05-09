# Git Rebase Helper

macOS向けのGitコミットリベースを簡単に行うためのツールです。

## 機能

- **コミットのマージ**: 現在のブランチの複数のコミットを1つにまとめることができます

## インストール

リポジトリをクローンして、実行権限を付与します：

```bash
git clone https://github.com/kakeru-ikeda/git-rebase-helper.git
cd git-rebase-helper
chmod +x src/rebase-commits.sh
```

必要に応じてPATHに追加するか、シンボリックリンクを作成してください：

```bash
ln -s "$(pwd)/src/rebase-commits.sh" /usr/local/bin/git-rebase-helper
```

## 使い方

### コミットをまとめる

現在のブランチの全コミットを1つにまとめる場合（デフォルト動作）：

```bash
./src/rebase-commits.sh
```

このコマンドは次の処理を行います：

1. 現在のリポジトリ名を表示
2. 現在のブランチ名を表示
3. デフォルトブランチ（master/main）からのコミット数を計算
4. `git rebase -i HEAD~{コミット数}` を実行
5. 最初のコミット以外をすべて「fixup」（f）に変更して自動的にコミットをまとめる

### ヘルプの表示

```bash
./src/rebase-commits.sh -h
```

または

```bash
./src/rebase-commits.sh --help
```

## 動作環境

- macOS
- zsh
- Git

## ライセンス

MIT