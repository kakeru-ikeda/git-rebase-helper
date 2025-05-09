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

# ヘルプメッセージと引数の処理
show_help() {
    printf "%bGit Rebaseヘルパー%b\n" "$BOLD" "$NC"
    separator
    printf "%b使用法:%b %s [オプション]\n" "$BOLD" "$NC" "$0"
    printf "\n"
    printf "%bオプション:%b\n" "$BOLD" "$NC" 
    printf "  %b-h, --help%b                  ヘルプメッセージを表示\n" "$GREEN" "$NC"
    printf "\n"
    printf "このツールは現在のブランチのコミットをすべて一つにまとめます。\n"
    printf "引数なしで実行すると、デフォルトでコミットのマージを実行します。\n"
    separator
}

# ヘルプオプション
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

printf "%bGit Rebaseヘルパー%b - コミットまとめツール\n" "$BOLD" "$NC"
separator

# 現在のリポジトリを確認
repo_name=$(basename -s .git $(git config --get remote.origin.url 2>/dev/null) || basename $(pwd))
printf "%bリポジトリ:%b %b%s%b\n" "$BOLD" "$NC" "$GREEN" "$repo_name" "$NC"

# 現在のブランチを確認
current_branch=$(git rev-parse --abbrev-ref HEAD)
printf "%b現在のブランチ:%b %b%s%b\n" "$BOLD" "$NC" "$GREEN" "$current_branch" "$NC"

# ブランチ内のコミット数を取得
main_branch="master"
if ! git show-ref --verify --quiet refs/heads/$main_branch; then
    main_branch="main"
    if ! git show-ref --verify --quiet refs/heads/$main_branch; then
        printf "%bマスターまたはメインブランチが見つかりませんでした。%b\n" "$YELLOW" "$NC"
        printf "デフォルトブランチからのコミット数を計算します。\n"
        
        # リモートのデフォルトブランチを取得
        default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
        if [ -n "$default_branch" ]; then
            main_branch=$default_branch
        else
            printf "%bデフォルトブランチを特定できませんでした。現在のHEADから5コミット分を処理します。%b\n" "$YELLOW" "$NC"
            commit_count=5
        fi
    fi
fi

if [ -z "$commit_count" ]; then
    commit_count=$(git rev-list --count HEAD ^$main_branch)
    printf "%b基準ブランチ:%b %b%s%b\n" "$BOLD" "$NC" "$GREEN" "$main_branch" "$NC"
    printf "%bコミット数:%b %b%s%b\n" "$BOLD" "$NC" "$GREEN" "$commit_count" "$NC"
fi

# 現在のコミット履歴を表示
printf "\n%b現在のコミット履歴:%b\n" "$BOLD" "$NC"
git log --oneline --color --max-count=10 | while read line; do
  printf "  %s\n" "$line"
done
[ $(git rev-list HEAD --count) -gt 10 ] && printf "  %b...%b\n" "$BLUE" "$NC"

if [ $commit_count -le 1 ]; then
    printf "\n%bまとめるコミットが1つ以下です。処理を終了します。%b\n" "$YELLOW" "$NC"
    exit 0
fi

printf "\n%b処理を開始します...%b\n" "$BOLD" "$NC"
printf "リベース対象: %bHEAD~%s%b から現在のHEADまで\n" "$GREEN" "$commit_count" "$NC"
printf "操作: %b最初のコミット以外を全てfixup%b\n" "$YELLOW" "$NC"

separator
printf "%bリベース中... しばらくお待ちください%b\n" "$YELLOW" "$NC"

# git rebase -i HEAD~{コミット数} を実行し、vim内の最上位行以外の"pick"を"f"に置換
VISUAL="sed -i '' '2,\$s/^pick/f/'" git rebase -i HEAD~$commit_count

if [ $? -eq 0 ]; then
    separator
    printf "%b✓ リベースが正常に完了しました！%b\n" "$GREEN" "$NC"
    printf "%b結果:%b すべてのコミットが最初のコミットにまとめられました\n" "$BOLD" "$NC"
    
    printf "\n%bリベース後のコミット:%b\n" "$BOLD" "$NC"
    git log --oneline --color --max-count=5

    [ $(git rev-list HEAD --count) -gt 5 ] && printf "  %b...%b\n" "$BLUE" "$NC"
    printf "\nコミットメッセージを編集する場合は:\n"
    printf "  %bgit commit --amend -m \"<新しいコミットメッセージ>\"%b\n" "$YELLOW" "$NC"
    printf "を実行してください。\n"
    printf "その後、%bgit push --force%b でリモートにプッシュしてください。\n" "$YELLOW" "$NC"
else
    separator
    printf "%b✗ リベース中にエラーが発生しました%b\n" "$RED" "$NC"
    printf "%b解決方法:%b\n" "$BOLD" "$NC"
    printf "  1. コンフリクトを解決\n"
    printf "  2. %bgit add <コンフリクトしたファイル>%b でファイルを追加\n" "$YELLOW" "$NC"
    printf "  3. %bgit rebase --continue%b でリベースを続行\n" "$YELLOW" "$NC"
    printf "または:\n"
    printf "  %bgit rebase --abort%b でリベースを中止\n" "$YELLOW" "$NC"
    exit 1
fi