# core-system-doc-format

基幹システム開発の**ドキュメント体系テンプレート**。
12種類の記載フォーマット＋整合性を維持するAIスキル＋進捗が見える俯瞰ダッシュボードを、**あなたのプロジェクトリポジトリへ一式導入**して使います。

> ドキュメントの問題は「書けない」ことではなく「**変更に追従できない**」こと。
> このキットは、維持を **AI主体**（人はレビューと承認）で回す前提で設計されています。
> 実証：サンプルを人手で書いたら不整合が11件混入 → AIチェックが全件検出＋人手の見落とし6件を追加検出 → 修正・再検証まで一周済み。

## 導入手順（メイン）

### 1. このキットをクローンする

```bash
git clone https://github.com/Cyberdog-AI-Lab/core-system-doc-format.git
```

### 2. 対象プロジェクトへ導入する

#### A. Claude Code で導入（推奨・kit-install スキル）

**クローンしたキットのフォルダで** Claude Code を起動します（スキルは `.claude/skills/` に同梱されているので、ここで起動すればそのまま呼べます）：

```bash
cd core-system-doc-format
claude
```

導入先プロジェクトの**パスを添えて**頼みます：

```
/kit-install ~/path/to/your-project に導入して
```

（スラッシュコマンドを使わず「`~/path/to/your-project` にこのキットを導入して」でも同じです）

kit-install スキルが、質問（システム名など最大3問）のあとに、**導入先プロジェクトに**以下を全部セットアップします：

```
{あなたのプロジェクト}/
├── .claude/skills/
│   ├── consistency-check/   ← 整合検査スキル（「整合性をチェックして」で起動）
│   └── change-propagate/    ← 変更反映スキル（「この要件を反映して」で起動）
├── .agents/skills/
│   ├── consistency-check → ../../.claude/skills/consistency-check   ← シンボリックリンク（Codex CLI等からも同じ中身を利用）
│   └── change-propagate  → ../../.claude/skills/change-propagate    ← シンボリックリンク
├── .claude/hooks/
│   └── check-doc-ops-guide-sync.sh  ← 12-doc-ops-guide.md 変更時に反映漏れをリマインドするフック
├── .claude/settings.json    ← 上記フックの登録（既存があればマージ・上書きしない）
├── CLAUDE.md                ← 運用ルールを追記（既存があれば末尾に追記・上書きしない）
└── docs/                    ← 文書一式はこのフォルダに閉じる
    ├── 01-concept.md 〜 12-doc-ops-guide.md   ← スケルトン12本（これから埋める本体）
    ├── formats/             ← 記載標準（書き方・スケルトン・ルールの原本）
    ├── dashboard/           ← 俯瞰ダッシュボード（index.html＋manifest.json）
    └── README.md            ← 導入内容と使い方
```

#### B. 手動で導入（コピーするだけ）

```bash
KIT=./core-system-doc-format   # クローンした場所
DST=.                          # あなたのプロジェクトのルート
DOCS=docs                      # 文書フォルダ名（好みで変更可）

mkdir -p "$DST/$DOCS/dashboard" "$DST/.claude/skills" "$DST/.claude/hooks"
cp "$KIT"/templates/docs/*.md    "$DST/$DOCS/"
cp -r "$KIT/formats"             "$DST/$DOCS/formats"
cp "$KIT/dashboard/index.html"   "$DST/$DOCS/dashboard/"
cp "$KIT/templates/manifest.json" "$DST/$DOCS/dashboard/manifest.json"
cp -r "$KIT/.claude/skills/consistency-check" "$KIT/.claude/skills/change-propagate" "$DST/.claude/skills/"
cp "$KIT/.claude/hooks/check-doc-ops-guide-sync.sh" "$DST/.claude/hooks/"
chmod +x "$DST/.claude/hooks/check-doc-ops-guide-sync.sh"

# .claude/skills/ は Agent Skills 標準（https://agentskills.io）準拠。Codex CLI 等は .agents/skills/ から読むため、
# 実体は増やさずシンボリックリンクで同じ中身を見せる（両ツールともシンボリックリンクを辿る仕様）
mkdir -p "$DST/.agents/skills"
ln -s ../../.claude/skills/consistency-check "$DST/.agents/skills/consistency-check"
ln -s ../../.claude/skills/change-propagate  "$DST/.agents/skills/change-propagate"
```

最後に、コピーしたファイル内の `{システム名}` を自分のシステム名に置換してください（docs/*.md と manifest.json）。
CLAUDE.md への運用ルール追記は `templates/CLAUDE-section.md` の内容を使えます。
フックを使うには `.claude/settings.json` に PostToolUse フックとして登録してください（内容は `.claude/skills/kit-install/SKILL.md` §4-3参照。既存の settings.json があればマージし、上書きしない）。

### 3. 使い始める

```bash
npx serve docs -p 4322
# → http://localhost:4322/dashboard/ （最初は12本の空スケルトンが見える）
```

- **書く順序**：構想・用語集 → 要件 → アーキテクチャ → 情報定義 → 機能仕様 → API仕様 →（実装）→ 品質保証 → データ移行 → システム維持保守ランブック（詳細：[formats/12-doc-ops-guide.md](formats/12-doc-ops-guide.md) §4）
- **変更するとき**：Claude Code に「**この要件を反映して**」→ 上流→下流に反映し、トレーサビリティへ自動記録
- **点検するとき**：「**ドキュメントの整合性をチェックして**」→ 8つの観点で検査（read-only）
- 要件を起票してトレーサビリティ（10）の表に行を足すと、ダッシュボードに**進捗タイムライン**が現れます

### 4. キットを最新化する（2回目以降）

キット側でフォーマットやスキル・ダッシュボードが更新されたら、導入済みプロジェクトへ追従させます。**最新のキットをクローンした状態で** Claude Code を起動し：

```
/kit-update ~/path/to/your-project を最新化して
```

kit-update は、キット所有ファイル（記載標準 `formats/`・ダッシュボード共通HTML・スキル本体・フック・`.agents/skills/`）を丸ごと入れ替え、プロジェクト所有ファイル（**あなたが埋めた実文書**・`manifest.json`・`CLAUDE.md`/`AGENTS.md`・`settings.json`）はマージか差分提示で扱います。**埋めた実文書は絶対に上書きしません**。フォーマットの章立てが変わっていた場合は、consistency-check で追従が必要な箇所を可視化し、change-propagate の流儀で1つずつ反映します。

## サンプルを見る（導入後の姿）

図書館の貸出システムを題材に、12文書を実際に埋めたサンプルを同梱しています。

- **オンラインデモ**：https://core-system-doc-format.vercel.app/
- ローカルで見る：`npx serve instance/library-lending -p 4323` → `http://localhost:4323/dashboard/`

要件11件の進捗タイムライン・自動チェック・保留チケット（取り下げも資産として残る）まで、運用イメージがそのまま見えます。

## キットの構成

```
core-system-doc-format/
├── README.md                ← 本ファイル
├── CLAUDE.md                ← Claude Code への運用指示（キット自体を触るとき用）
├── .claude/skills/          ← 同梱スキル4本（クローンで Claude Code を起動すればそのまま呼べる）
│   ├── kit-install/         ← プロジェクトへの初回完全導入（本README §2-A）
│   ├── kit-update/          ← 導入済みプロジェクトを最新キットへ更新（実文書は壊さない）
│   ├── consistency-check/   ← 整合性の検査（観点A〜H・read-only既定）
│   └── change-propagate/    ← 変更を上流→下流へ反映し記録
├── .claude/hooks/           ← 12-doc-ops-guide.md 変更時に反映漏れをリマインドするフック（kit-installで導入先にも配置）
├── .claude/settings.json    ← 上記フックの登録
├── .agents/skills/          ← 各スキルへのシンボリックリンク（Codex CLI等がAgent Skills標準経由で同じ中身を利用。consistency-check・change-propagateはkit-installで導入先にも配置）
├── templates/               ← 導入用テンプレート（docs スケルトン12本・manifest・CLAUDE追記節）
├── formats/                 ← 12フォーマットの正（索引＝formats/README.md）
├── dashboard/               ← 俯瞰ダッシュボード（index.html は全プロジェクト共通・編集不要）
└── instance/
    └── library-lending/     ← 動くサンプル（図書貸出。導入後と同じ構造）
```

## 12文書

| # | 文書 | 一言 |
|---|---|---|
| 01 | 構想／コンセプト | 向きを揃える北極星 |
| 02 | 用語集 | 語彙と値仕様の唯一の源 |
| 03 | 要件 | 検証可能な単位のチケット（トレーサビリティの起点） |
| 04 | システムアーキテクチャ | 基盤・非機能の実現（ADR含む） |
| 05 | 情報定義 | 全仕様の源流（エンティティ・論理／物理・バリデーション） |
| 06 | 機能仕様 | 画面・バッチ・状態遷移＋実装標準 |
| 07 | API仕様 | I/F（型）＋内部処理フロー |
| 08 | 品質保証 | 検証記録の蓄積（何が保証できたか） |
| 09 | データ移行 | 初回＋リリース随伴の移行台帳 |
| 10 | 要件トレーサビリティ | 全改訂の一元記録（ダッシュボードのデータ源） |
| 11 | システム維持保守ランブック | システム運用の手順＋リリース台帳 |
| 12 | 運用プロセスガイド | 文書メンテのルールブック（AI主体） |

詳細な索引・整合性モデル・貫通線（3カテゴリ7本）は [formats/README.md](formats/README.md)。

## 思想（3行）

1. **源に1回だけ書き、下流は参照する**（用語集＝語彙の源、情報定義＝仕様の源流）
2. **改訂履歴は各文書に書かない**。要件トレーサビリティに一元記録し、ダッシュボードがそれを描く
3. **AIが反映と検査、人はレビューと承認**（取り下げも消さずに資産として残す）

## ステータス

公開済み（初版）。ライセンスは近日確定します（確定までは All rights reserved の扱い）。
今後：実案件での運用検証／Hooks による自動化（コミット時の整合チェック）／第三者環境での再実走。
