#!/bin/bash
#============================================================
# setup_creative_workspace.sh
# ─ キャラクター小説創作ワークスペースの構築スクリプト
# 
# 使い方: ./setup_creative_workspace.sh [root_directory] [config_file]
#         ./setup_creative_workspace.sh [config_file]
# 例:     ./setup_creative_workspace.sh /Users/username/creative_workspace ./creative_config.sh
#         ./setup_creative_workspace.sh creative_config.sh  # カレントディレクトリに作成
#
# 創作に特化したフォルダ構造を作成し、必要なリソースをセットアップします
#============================================================

set -e

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# デフォルト設定
setup_default_config() {
  # 創作ルールリポジトリ
  RULE_REPOS=(
    "https://github.com/miyatti777/character_novel_v0.git|.cursor/rules/basic"
  )
  
  # 創作支援スクリプトリポジトリ（現在は不要）
  SCRIPT_REPOS=()
  
  # 創作テンプレートリポジトリ（現在は不要、ルールリポジトリに含まれる）
  TEMPLATE_REPOS=()
  
  # 基本ディレクトリ
  BASE_DIRS=(
    "Flow"
    "Flow/templates"
    "Stock"
    "Stock/creative_works"
    "Stock/creative_works/dream_novels"
    "Stock/creative_works/original_novels"
    "Stock/creative_works/shared_resources"
    "Stock/creative_works/shared_resources/character_templates"
    "Stock/creative_works/shared_resources/prompt_collections"
    "Stock/creative_works/shared_resources/reference_materials"
    "Stock/community"
    "Stock/community/workshops"
    "Stock/community/feedback"
    "Stock/community/guidelines"
    "Archived"
    "Archived/completed_works"
    "Archived/learning_history"
    "Archived/reference_archive"
    "scripts"
    ".cursor/rules"
    ".cursor/rules/basic"
    "config"
  )
  
  # AUTO_APPROVE：trueに設定すると確認メッセージをスキップ
  AUTO_APPROVE=false
  
  # AUTO_CLONE：trueに設定するとリポジトリを自動クローン
  AUTO_CLONE=false
}

# 引数解析
parse_arguments() {
  if [ $# -eq 0 ]; then
    # 引数なし：カレントディレクトリに作成
    ROOT_DIR="$(pwd)"
    CONFIG_FILE=""
  elif [ $# -eq 1 ]; then
    # 引数1つ：設定ファイルまたはディレクトリ
    if [[ "$1" == *.sh ]] || [[ "$1" == *.conf ]]; then
      # 設定ファイルの場合
      ROOT_DIR="$(pwd)"
      CONFIG_FILE="$1"
    else
      # ディレクトリの場合
      ROOT_DIR="$1"
      CONFIG_FILE=""
    fi
  elif [ $# -eq 2 ]; then
    # 引数2つ：ディレクトリと設定ファイル
    ROOT_DIR="$1"
    CONFIG_FILE="$2"
  else
    log_error "引数が多すぎます"
    echo "使い方: $0 [root_directory] [config_file]"
    exit 1
  fi
  
  # ルートディレクトリの絶対パス化
  ROOT_DIR="$(realpath "$ROOT_DIR")"
  
  log_info "創作ワークスペースを作成します: $ROOT_DIR"
  if [ -n "$CONFIG_FILE" ]; then
    log_info "設定ファイル: $CONFIG_FILE"
  fi
}

# コンフィグファイルの読み込み
load_config() {
  local config_file="$1"
  
  if [ -n "$config_file" ] && [ -f "$config_file" ]; then
    log_info "コンフィグファイルを読み込んでいます: $config_file"
    # shellcheck source=/dev/null
    source "$config_file"
    log_success "コンフィグファイルを読み込みました"
  else
    if [ -n "$config_file" ]; then
      log_warning "指定されたコンフィグファイルが見つかりません: $config_file"
    fi
    log_info "デフォルト設定を使用します"
  fi
}

# 基本ディレクトリの作成
create_base_directories() {
  log_info "基本ディレクトリ構造を作成しています..."
  
  for dir in "${BASE_DIRS[@]}"; do
    local full_path="$ROOT_DIR/$dir"
    if [ ! -d "$full_path" ]; then
      mkdir -p "$full_path"
      log_info "ディレクトリを作成しました: $dir"
    else
      log_info "ディレクトリは既に存在します: $dir"
    fi
  done
  
  log_success "基本ディレクトリ構造を作成しました"
}

# 日付フォルダの作成
create_date_folders() {
  log_info "日付フォルダを作成しています..."
  
  local today=$(date +%Y-%m-%d)
  local year_month=$(date +%Y%m)
  
  local flow_date_dir="$ROOT_DIR/Flow/$year_month/$today"
  mkdir -p "$flow_date_dir"
  
  log_success "日付フォルダを作成しました: Flow/$year_month/$today"
}

# 設定ファイルの作成
create_config_files() {
  log_info "設定ファイルを作成しています..."
  
  # 創作者設定ファイル
  local creator_config="$ROOT_DIR/config/creator_config.yaml"
  if [ ! -f "$creator_config" ]; then
    cat > "$creator_config" << 'EOF'
# 創作者設定ファイル
creator_info:
  name: "あなたの創作者名"
  pen_names:
    - "ペンネーム1"
    - "ペンネーム2"
  genres:
    - "夢小説"
    - "オリジナル小説"
    - "ファンタジー"
  favorite_characters:
    - "推しキャラ1"
    - "推しキャラ2"

# 創作設定
creative_settings:
  default_work_type: "dream_novel"  # dream_novel / original_novel
  auto_backup: true
  quality_check: true
  
# AI設定
ai_settings:
  model_preference: "claude"  # claude / gpt / gemini
  creativity_level: "balanced"  # conservative / balanced / creative
  language_style: "natural"  # formal / natural / casual
EOF
    log_success "創作者設定ファイルを作成しました: config/creator_config.yaml"
  else
    log_info "創作者設定ファイルは既に存在します"
  fi
  
  # .gitignore ファイル
  local gitignore="$ROOT_DIR/.gitignore"
  if [ ! -f "$gitignore" ]; then
    cat > "$gitignore" << 'EOF'
# 個人情報・設定
config/creator_config.yaml
config/personal_*.yaml

# 一時ファイル
*.tmp
*.temp
.DS_Store
Thumbs.db

# ログファイル
*.log
logs/

# バックアップファイル
*_backup_*
*.bak

# 作業中ファイル
*_draft_*
*_wip_*

# システムファイル
.cursor/
!.cursor/rules/
EOF
    log_success ".gitignoreファイルを作成しました"
  else
    log_info ".gitignoreファイルは既に存在します"
  fi
}

# リポジトリのクローン処理
clone_repository() {
  local url=$1
  local target=$2
  local full_path="$ROOT_DIR/$target"
  
  # ターゲットディレクトリが既に存在し、かつgitリポジトリである場合はpullのみ
  if [ -d "$full_path/.git" ]; then
    log_info "リポジトリは既に存在します: $target - 更新を試みます"
    (cd "$full_path" && git pull)
    if [ $? -eq 0 ]; then
      log_success "リポジトリを更新しました: $target"
    else
      log_warning "リポジトリの更新中にエラーが発生しました: $target"
      log_info "更新をスキップして継続します"
    fi
  else
    # 親ディレクトリを作成
    mkdir -p "$(dirname "$full_path")"
    
    # リポジトリをクローン
    log_info "リポジトリをクローンしています: $url -> $target"
    git clone "$url" "$full_path"
    if [ $? -eq 0 ]; then
      log_success "リポジトリをクローンしました: $target"
    else
      log_error "リポジトリのクローンに失敗しました: $url"
      return 1
    fi
  fi
}

# リポジトリのクローン
clone_repositories() {
  log_info "リポジトリをクローンしています..."
  
  # git が必要
  if ! command -v git &> /dev/null; then
    log_warning "git がインストールされていません。リポジトリクローンをスキップします。"
    return 1
  fi
  
  # 確認メッセージ
  if [ "$AUTO_CLONE" != "true" ] && [ "$AUTO_APPROVE" != "true" ]; then
    echo
    log_info "以下のリポジトリをクローンします："
    for repo in "${RULE_REPOS[@]}" "${SCRIPT_REPOS[@]}" "${TEMPLATE_REPOS[@]}"; do
      IFS='|' read -r url target <<< "$repo"
      echo "  - $url -> $target"
    done
    echo
    read -p "続行しますか？ (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      log_info "リポジトリクローンをスキップします"
      return 0
    fi
  fi
  
  # ルールリポジトリのクローン
  for repo in "${RULE_REPOS[@]}"; do
    IFS='|' read -r url target <<< "$repo"
    clone_repository "$url" "$target"
  done
  
  # スクリプトリポジトリのクローン
  for repo in "${SCRIPT_REPOS[@]}"; do
    IFS='|' read -r url target <<< "$repo"
    clone_repository "$url" "$target"
  done
  
  # テンプレートリポジトリのクローン
  for repo in "${TEMPLATE_REPOS[@]}"; do
    IFS='|' read -r url target <<< "$repo"
    clone_repository "$url" "$target"
  done
  
  log_success "リポジトリのクローンが完了しました"
}

# サンプルファイルの作成
create_sample_files() {
  log_info "サンプルファイルを作成しています..."
  
  local today=$(date +%Y-%m-%d)
  local year_month=$(date +%Y%m)
  local sample_dir="$ROOT_DIR/Flow/$year_month/$today"
  
  # サンプルキャラクター分析ファイル
  local sample_analysis="$sample_dir/sample_character_analysis.md"
  if [ ! -f "$sample_analysis" ]; then
    cat > "$sample_analysis" << 'EOF'
# キャラクター分析サンプル

## 基本情報
- **キャラクター名**: [キャラクター名]
- **作品名**: [作品名]
- **分析日**: [日付]

## 性格分析
### 基本的な性格特徴
1. [特徴1]
2. [特徴2]
3. [特徴3]
4. [特徴4]
5. [特徴5]

### 話し方・口調の特徴
- [口調の特徴]

### 他者との関係性の築き方
- [関係性の特徴]

## 魅力要素
### 表面的魅力
- [見た目・行動の魅力]

### 深層的魅力
- [内面・価値観の魅力]

## 創作への活用
### 夢主との関係性
- [関係性のアイデア]

### 重要なシーン
- [シーンのアイデア]
EOF
    log_success "サンプルキャラクター分析ファイルを作成しました"
  fi
  
  # README for Flow
  local flow_readme="$ROOT_DIR/Flow/README.md"
  if [ ! -f "$flow_readme" ]; then
    cat > "$flow_readme" << 'EOF'
# Flow ディレクトリ

このディレクトリには、日々の創作活動で作成されるドラフトやアイデアを保存します。

## 構造
- `YYYYMM/YYYY-MM-DD/`: 日付ごとのフォルダ
- `templates/`: 創作テンプレート

## ファイル命名規則
- `character_analysis_[キャラ名].md`: キャラクター分析
- `story_structure_[作品名].md`: 物語構成
- `draft_scene_[シーン名].md`: シーンドラフト
- `idea_[テーマ].md`: アイデアメモ

## 使い方
1. 毎日の創作活動は日付フォルダに保存
2. 完成した作品は「作品確定」コマンドでStockに移動
3. テンプレートを活用して効率的に創作
EOF
    log_success "Flow README を作成しました"
  fi
}

# メイン処理
main() {
  echo "============================================================"
  echo "キャラクター小説創作ワークスペース セットアップ"
  echo "============================================================"
  echo
  
  # 引数解析
  parse_arguments "$@"
  
  # デフォルト設定の読み込み
  setup_default_config
  
  # コンフィグファイルの読み込み
  load_config "$CONFIG_FILE"
  
  # ルートディレクトリの作成
  if [ ! -d "$ROOT_DIR" ]; then
    mkdir -p "$ROOT_DIR"
    log_success "ルートディレクトリを作成しました: $ROOT_DIR"
  fi
  
  # 基本ディレクトリの作成
  create_base_directories
  
  # 日付フォルダの作成
  create_date_folders
  
  # 設定ファイルの作成
  create_config_files
  
  # サンプルファイルの作成
  create_sample_files
  
  # リポジトリのクローン（オプション）
  if [ "$AUTO_CLONE" == "true" ] || [ "$AUTO_APPROVE" != "true" ]; then
    clone_repositories
  fi
  
  echo
  log_success "創作ワークスペースのセットアップが完了しました！"
  echo
  echo "次のステップ:"
  echo "1. config/creator_config.yaml を編集して個人設定を行う"
  echo "2. Cursor で $ROOT_DIR を開く"
  echo "3. チャットで「創作環境セットアップお願いします」と入力"
  echo "4. 「推しキャラ分析開始：[キャラクター名]」で創作開始"
  echo
  echo "創作ワークスペース: $ROOT_DIR"
  echo "今日の作業フォルダ: Flow/$(date +%Y%m)/$(date +%Y-%m-%d)"
  echo
}

# スクリプト実行
main "$@" 