# CLAUDE.md — core-system-doc-format

このリポジトリは基幹システム開発の**ドキュメント体系テンプレート**（12フォーマット＋スキル4本＋ダッシュボード＋サンプル）。
ドキュメントのメンテナンスは **AI主体・人はレビューと承認** が前提。あなた（Claude）がその主体である。

## 最初に読むもの

1. [formats/README.md](formats/README.md) — 体系の索引（整合性モデル・12文書・貫通線3カテゴリ7本）
2. [formats/12-doc-ops-guide.md](formats/12-doc-ops-guide.md) — 運用ガイド＝メンテのルールブック（§5変更フロー・§7不変ルール・§8観点）

## ドキュメントを触るときの必須ルール（運用ガイドの要約）

- **変更は要件チケット起点**。上流→下流（論理→物理）の順に反映する。誤記修正等の要件外は「要件外の改訂ログ」へ
- 状態の言葉は全文書共通で **「未／反映中／済」の3語だけ**。トレーサビリティ§2のセルは正準形「**状態 日付 反映先ID**」（例 `済 2026-06-20 QA-007`、対象外は `−`）
- **改訂履歴は各文書に書かない** → 要件トレーサビリティ文書へ一元記録（マトリクス＝現況／タイムライン＝履歴の二重記録）
- **用語集が語彙の唯一の源**。値仕様・プロパティ名を下流で再定義しない
- **廃止・取り下げは消さない**。状態と経緯（取り下げコンテキスト）で残し、IDは欠番にしない
- プラットフォーム固有の製品名は物理層（アーキ§3・情報定義§5）だけ。他は概念で書く

## スキル（`.claude/skills/` に同梱＝このリポジトリで起動すればそのまま呼べる）

| やること | 従うファイル | 要点 |
|---|---|---|
| 既存プロジェクトへの**初回**完全導入 | [.claude/skills/kit-install/SKILL.md](.claude/skills/kit-install/SKILL.md) | キット内で実行し**導入先はパスで受け取る**。`templates/` から機械的にコピー＋スキル配置＋CLAUDE.md 追記（上書きしない） |
| 導入済みプロジェクトの**更新**（2回目以降） | [.claude/skills/kit-update/SKILL.md](.claude/skills/kit-update/SKILL.md) | キット所有（formats/・共通HTML・スキル・フック）は丸ごと入れ替え／プロジェクト所有（実文書・manifest・CLAUDE/AGENTS・settings）はマージか差分提示。**埋めた実文書は壊さない**（フォーマット追従は consistency-check で可視化→change-propagate で反映） |
| 整合性の検査 | [.claude/skills/consistency-check/SKILL.md](.claude/skills/consistency-check/SKILL.md) | 観点A〜H・**read-only既定**・「テンプレ自身をチェックして」で自己検査モード |
| 変更の反映 | [.claude/skills/change-propagate/SKILL.md](.claude/skills/change-propagate/SKILL.md) | 1層ずつ提案→確認が既定（「一括で」指示時のみ全適用）・反映のたびに二重記録 |

スキルとして読み込めない環境でも、上記の SKILL.md を直接読んで手順に従うこと。

consistency-check・change-propagateは `.agents/skills/` にもシンボリックリンクしてある（[Agent Skills 標準](https://agentskills.io)準拠のため、Codex CLI 等からも同じ中身を利用可能）。**実体は `.claude/skills/` の1つだけ**。`.agents/skills/` を実ファイルに置き換えたり内容を分岐させたりしないこと。

## ダッシュボード

- `dashboard/index.html` は全プロジェクト共通＝**編集しない**。プロジェクト差は同フォルダの `manifest.json` だけで吸収する
- テンプレ⇄サンプルの同期は `cp dashboard/index.html instance/library-lending/dashboard/`（diff で一致確認）
- 起動：`npx serve <配信ルート> -p <port>` → `/dashboard/`

## フォルダの役割と同期

- `formats/` … 12フォーマットの**正**（single source of truth）
- `templates/` … 導入用テンプレート（docs スケルトン12本・manifest.json・CLAUDE追記節）。**フォーマットの章立てを変えたら、対応するスケルトンも必ず追従させる**
- `instance/library-lending/` … 動くサンプル。`docs/` が実文書、`formats/` は標準のコピー。`.agents/skills/` も同様にキット直下と対になるシンボリックリンクを持つ
- **テンプレのフォーマットを変更したら**：①`instance/library-lending/formats/` へ cp で同期 ②consistency-check の「テンプレ自身をチェックして」を実行（文書数・貫通線・観点対応のドリフト検出）
- `formats/12-doc-ops-guide.md` を編集すると `.claude/hooks/check-doc-ops-guide-sync.sh`（PostToolUse）が自動でリマインドする。ただし判定は機械的（ファイル名一致のみ）なので、②の実行は省略せず必ず行うこと

## やってはいけないこと

- 整合を取るために文書・チケット・定義を**消す**（消さずに状態・注記で残す）
- `dashboard/index.html` への直接編集（manifest.json で吸収する）
- 各文書への改訂履歴章の新設（トレーサビリティに一元化済み）
- スケルトン生成時の内容の創作（埋めるのはプロジェクトの人間とAIの共同作業）
