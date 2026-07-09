# CLAUDE.md — 図書貸出システム（ドキュメント・プロジェクト）

このフォルダは基幹システム文書テンプレート（core-system-doc-format）を適用した**実プロジェクト**（サンプル）。
**`docs/` が実文書12本（正）**。`formats/` は採用した記載標準のコピー（変更しない。変えたいときはテンプレート側へ提案）。

## ドキュメントを触るときのルール

- 変更は要件チケット（`docs/03`）起点で、[change-propagate/SKILL.md](change-propagate/SKILL.md) の手順どおり上流→下流に反映し、[docs/10-traceability.md](docs/10-traceability.md) へ二重記録（マトリクス＋タイムライン）する
- 点検は [consistency-check/SKILL.md](consistency-check/SKILL.md)（観点A〜H・read-only既定）。対象は `docs/`
- 状態は「未／反映中／済」の3語・トレサビ§2セルは「状態 日付 反映先ID」・対象外は `−`
- 改訂履歴は各文書に書かない／用語集（`docs/02`）が語彙の源／廃止・取り下げは消さない

## ダッシュボード

```bash
npx serve . -p 4323   # → http://localhost:4323/dashboard/
```

`dashboard/index.html` は編集しない（設定は `dashboard/manifest.json`）。
