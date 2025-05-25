#!/bin/bash
#============================================================
# creative_config.sh
# ─ キャラクター小説創作ワークスペース設定ファイル
#
# このファイルは setup_creative_workspace.sh で読み込まれ、
# デフォルト設定をオーバーライドします
#============================================================

# 創作ルールリポジトリ
RULE_REPOS=(
  "https://github.com/miyatti777/creative_rules_basic.git|.cursor/rules/basic"
  # 追加のルールリポジトリがあればここに記述
)

# 創作支援スクリプトリポジトリ
SCRIPT_REPOS=(
  "https://github.com/miyatti777/creative_scripts.git|scripts"
  # 追加のスクリプトリポジトリがあればここに記述
)

# 創作テンプレートリポジトリ
TEMPLATE_REPOS=(
  "https://github.com/miyatti777/creative_templates.git|Flow/templates"
  # 追加のテンプレートリポジトリがあればここに記述
)

# 創作コミュニティリポジトリ（オプション）
COMMUNITY_REPOS=(
  # "https://github.com/your-org/creative_community.git|Stock/community"
)

# 基本ディレクトリ（必要に応じて追加・変更）
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
  # 追加のディレクトリがあればここに記述
)

# 自動承認設定
# true: 確認メッセージをスキップ
# false: 各ステップで確認を求める
AUTO_APPROVE=false

# 自動クローン設定
# true: リポジトリを自動的にクローン
# false: クローンするかどうか確認を求める
AUTO_CLONE=false

# 創作者情報（オプション）
# セットアップ時に自動的に設定ファイルに反映されます
CREATOR_NAME="あなたの創作者名"
CREATOR_PEN_NAMES=("ペンネーム1" "ペンネーム2")
CREATOR_GENRES=("夢小説" "オリジナル小説" "ファンタジー")
CREATOR_FAVORITE_CHARACTERS=("推しキャラ1" "推しキャラ2")

# デフォルト創作設定
DEFAULT_WORK_TYPE="dream_novel"  # dream_novel / original_novel
AUTO_BACKUP=true
QUALITY_CHECK=true

# AI設定
AI_MODEL_PREFERENCE="claude"  # claude / gpt / gemini
AI_CREATIVITY_LEVEL="balanced"  # conservative / balanced / creative
AI_LANGUAGE_STYLE="natural"  # formal / natural / casual

# 高度な設定

# カスタムディレクトリパターン
# 作品ごとのディレクトリ構造をカスタマイズできます
WORK_DIR_PATTERN="Stock/creative_works/{work_type}/{work_name}"
SCENE_DIR_PATTERN="{work_dir}/scenes"
CHARACTER_DIR_PATTERN="{work_dir}/character_research"

# ファイル命名パターン
CHARACTER_ANALYSIS_PATTERN="character_analysis_{character_name}.md"
STORY_STRUCTURE_PATTERN="story_structure_{work_name}.md"
SCENE_DRAFT_PATTERN="draft_scene_{scene_name}.md"
FINAL_WORK_PATTERN="final_work.md"

# バックアップ設定
BACKUP_ENABLED=true
BACKUP_INTERVAL="daily"  # daily / weekly / manual
BACKUP_RETENTION_DAYS=30

# 品質チェック設定
QUALITY_CHECK_ENABLED=true
CHARACTER_CONSISTENCY_CHECK=true
READABILITY_CHECK=true
GRAMMAR_CHECK=false  # 外部ツール連携が必要

# コミュニティ設定
COMMUNITY_SHARING_ENABLED=false
FEEDBACK_SYSTEM_ENABLED=false
WORKSHOP_MODE_ENABLED=false

# デバッグ・ログ設定
DEBUG_MODE=false
LOG_LEVEL="INFO"  # DEBUG / INFO / WARNING / ERROR
LOG_FILE="logs/creative_workspace.log"

# 外部ツール連携設定
ENABLE_GIT_INTEGRATION=true
ENABLE_MARKDOWN_PREVIEW=true
ENABLE_SPELL_CHECK=false

# プラグイン・拡張設定
ENABLE_CUSTOM_PROMPTS=true
ENABLE_TEMPLATE_EXPANSION=true
ENABLE_AUTO_TAGGING=false

#============================================================
# 関数定義（高度なカスタマイズ用）
#============================================================

# カスタム初期化処理
custom_initialization() {
  log_info "カスタム初期化処理を実行しています..."
  
  # ここに独自の初期化処理を記述
  # 例：特定のファイルの作成、権限設定など
  
  log_success "カスタム初期化処理が完了しました"
}

# カスタムポストプロセス
custom_post_process() {
  log_info "カスタムポストプロセスを実行しています..."
  
  # ここに独自の後処理を記述
  # 例：追加のファイル作成、設定の調整など
  
  log_success "カスタムポストプロセスが完了しました"
}

# 環境固有の設定
setup_environment_specific() {
  local env_type="$1"  # development / production / workshop
  
  case "$env_type" in
    "development")
      DEBUG_MODE=true
      AUTO_BACKUP=true
      QUALITY_CHECK=true
      ;;
    "production")
      DEBUG_MODE=false
      AUTO_BACKUP=true
      QUALITY_CHECK=true
      COMMUNITY_SHARING_ENABLED=true
      ;;
    "workshop")
      AUTO_APPROVE=true
      AUTO_CLONE=true
      WORKSHOP_MODE_ENABLED=true
      ;;
  esac
}

#============================================================
# 設定の検証
#============================================================

validate_config() {
  # 必須設定の確認
  if [ -z "$CREATOR_NAME" ]; then
    log_warning "CREATOR_NAME が設定されていません"
  fi
  
  # ディレクトリパスの検証
  for dir in "${BASE_DIRS[@]}"; do
    if [[ "$dir" == *".."* ]]; then
      log_error "不正なディレクトリパス: $dir"
      return 1
    fi
  done
  
  # リポジトリURLの検証
  for repo in "${RULE_REPOS[@]}" "${SCRIPT_REPOS[@]}" "${TEMPLATE_REPOS[@]}"; do
    IFS='|' read -r url target <<< "$repo"
    if [[ ! "$url" =~ ^https?:// ]]; then
      log_warning "不正なリポジトリURL: $url"
    fi
  done
  
  log_success "設定の検証が完了しました"
}

# 設定の検証を実行
validate_config 