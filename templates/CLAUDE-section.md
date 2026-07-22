## ドキュメント体系（core-system-doc-format）

このプロジェクトのドキュメントは `{DOCS_DIR}/` にあり、core-system-doc-format の体系で管理する。

- **変更は要件チケット起点**（`{DOCS_DIR}/03-requirement.md`）。上流→下流に反映し、`{DOCS_DIR}/10-traceability.md` の §2 マトリクス＋§3 タイムラインへ二重記録する
- マトリクスのセルは正準形「**状態 日付 反映先ID**」（状態は 未/反映中/済 の3語・対象外は −）
- 点検：「ドキュメントの整合性をチェックして」→ `.claude/skills/consistency-check`（観点A〜H・read-only既定）
- 反映：「この要件を反映して」→ `.claude/skills/change-propagate`（1層ずつ提案→確認が既定）
- `{DOCS_DIR}/12-doc-ops-guide.md` を編集すると、consistency-check/change-propagate への反映が必要か確認するようフックがリマインドする（`.claude/hooks/check-doc-ops-guide-sync.sh`）
- consistency-check・change-propagateは `.agents/skills/` にもシンボリックリンクしてあり、Codex CLI等からも同じ内容で使える（実体は `.claude/skills/` の1つだけ）
- 記載標準は `{DOCS_DIR}/formats/`（変更しない。変えたい場合はテンプレート側への提案として扱う）
- 用語・値仕様の源は `{DOCS_DIR}/02-glossary.md`。改訂履歴は各文書に書かない。廃止・取り下げは消さず状態で残す
- ダッシュボード：`npx serve {DOCS_DIR} -p 4322` → http://localhost:4322/dashboard/（`dashboard/index.html` は編集しない。設定は `manifest.json`）
