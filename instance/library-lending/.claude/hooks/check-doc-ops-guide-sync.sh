#!/usr/bin/env bash
# PostToolUse hook: ドキュメント運用プロセスガイド（12番）が変更されたら、
# consistency-check / change-propagate への反映が必要か確認するようリマインドする。
# kit-install でプロジェクトへ導入した先でもそのまま動く汎用スクリプト（ファイル名一致で検知）。
input="$(cat)"
file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"

case "$file" in
  */12-doc-ops-guide.md)
    dir="$(dirname "$file")"
    if [ -d "$dir/../templates" ]; then
      # キット自身（core-system-doc-format）を開発しているケース
      followup="change-propagateの流儀（formats/ → スキルの順で修正）で反映し、instance/library-lending へ同期のうえ idea.md に経緯を記録してください。"
    else
      # kit-install で導入したプロジェクト（または同梱サンプル）を運用しているケース
      followup="change-propagateの流儀（上流→下流に反映し、要件トレーサビリティ文書へ記録）で反映してください。"
    fi
    msg="$(basename "$file") が変更されました。.claude/skills/consistency-check/SKILL.md（観点A〜H）と .claude/skills/change-propagate/SKILL.md（変更フロー・反映の順序）が、この変更と整合しているか確認してください。ズレがあれば${followup}"
    jq -n --arg msg "$msg" '{
      systemMessage: $msg,
      hookSpecificOutput: { hookEventName: "PostToolUse", additionalContext: $msg }
    }'
    ;;
esac
exit 0
