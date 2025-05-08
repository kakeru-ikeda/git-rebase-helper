#!/bin/zsh

# カラー表示が利用可能かチェック
if [ -t 1 ]; then
  # ターミナルが利用可能なら色を使う
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  NC='\033[0m' # No Color
else
  # ターミナルが利用できない場合は色をクリア
  GREEN=''
  BLUE=''
  YELLOW=''
  RED=''
  BOLD=''
  NC=''
fi

# セパレーター
separator() {
  printf "%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n" "$BLUE" "$NC"
}

# テスト用のGitリポジトリを作成して、スクリプトの動作を確認するテスト
printf "%bGit Rebaseヘルパー テスト%b\n" "$BOLD" "$NC"
separator

set -e  # エラー時に停止

# テスト用一時ディレクトリ作成
TEST_DIR=$(mktemp -d /tmp/git-rebase-test.XXXXXX)
printf "%bテスト環境を作成:%b %b%s%b\n" "$BOLD" "$NC" "$GREEN" "$TEST_DIR" "$NC"

# 現在の作業ディレクトリを記憶しておく
CURRENT_DIR=$(pwd)

# クリーンアップ関数
cleanup() {
  printf "\n%bテスト環境をクリーンアップします...%b\n" "$YELLOW" "$NC"
  cd "$CURRENT_DIR"
  rm -rf "$TEST_DIR"
  printf "%bクリーンアップ完了%b\n" "$GREEN" "$NC"
}

# 終了時またはエラー時にクリーンアップ
trap cleanup EXIT

# テスト用Gitリポジトリの初期化
printf "\n%bテスト用リポジトリを初期化:%b\n" "$BOLD" "$NC"
cd "$TEST_DIR"
git init
git config user.email "test@example.com"
git config user.name "Test User"
printf "%b✓ Gitリポジトリを初期化しました%b\n" "$GREEN" "$NC"

# メインブランチ作成
printf "\n%bメインブランチを作成:%b\n" "$BOLD" "$NC"
echo "# Test Repository" > README.md
git add README.md
git commit -m "Initial commit"
printf "%b✓ メインブランチにInitial commitを作成しました%b\n" "$GREEN" "$NC"

# フィーチャーブランチを作成して複数のコミットを追加
printf "\n%bフィーチャーブランチを作成:%b\n" "$BOLD" "$NC"
git checkout -b feature-branch
printf "%b✓ feature-branchを作成しました%b\n" "$GREEN" "$NC"

# 複数のコミットを作成
printf "\n%bテスト用コミットを作成:%b\n" "$BOLD" "$NC"
echo "# Feature 1" > feature1.md
git add feature1.md
git commit -m "Add feature 1"

echo "# Feature 2" > feature2.md
git add feature2.md
git commit -m "Add feature 2"

echo "# Feature 3" > feature3.md
git add feature3.md
git commit -m "Add feature 3"
printf "%b✓ 3つのテストコミットを作成しました%b\n" "$GREEN" "$NC"

# コミット履歴の表示
printf "\n%bテストリポジトリのコミット履歴:%b\n" "$BOLD" "$NC"
git log --oneline

# コミットをまとめるテスト
separator
printf "%bテスト 1: コミットをまとめる%b\n" "$BOLD" "$NC"
separator
bash "$CURRENT_DIR/src/rebase-commits.sh"

# 結果を確認
printf "\n%bリベース後のコミット履歴:%b\n" "$BOLD" "$NC"
git log --oneline

# ヘルプオプションのテスト
separator
printf "%bテスト 2: ヘルプオプション%b\n" "$BOLD" "$NC"
separator
bash "$CURRENT_DIR/src/rebase-commits.sh" -h

separator
printf "%b✓ すべてのテストが完了しました！%b\n" "$GREEN" "$NC"