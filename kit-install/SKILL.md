---
name: kit-install
description: >
  core-system-doc-format（基幹システム文書体系キット）を、既存のプロジェクトリポジトリへ完全導入するスキル。
  文書スケルトン12本・記載標準・ダッシュボード・AIスキル（.claude/skills）・CLAUDE.md設定まで一式をセットアップする。
  「このプロジェクトに文書体系を導入して」「キットをインストールして」「core-system-doc-format を導入して」
  「ドキュメント一式をこのリポジトリにセットアップして」など、クローン済みキットを対象プロジェクトへ導入したいときに必ずこのスキルを使うこと。
---

# 完全導入（kit-install）スキル

クローンした本キットから、**既存のプロジェクトリポジトリ**へ一式を導入する。
コピーは `templates/` を使った機械的な作業、AIがやるのはシステム名の差し込みと CLAUDE.md の追記だけ。**内容の創作はしない**。

> 文書だけの単体プロジェクトを新規に作りたい場合は doc-scaffold。本スキルは「開発リポジトリへの組み込み」用。

## 導入されるもの（対象プロジェクト内の配置）

```
{対象プロジェクト}/
├── .claude/skills/
│   ├── consistency-check/   ← 整合検査（「整合性をチェックして」で起動）
│   └── change-propagate/    ← 変更反映（「この要件を反映して」で起動）
├── CLAUDE.md                ← 運用ルールの節を追記（無ければ新規作成）
└── {docsDir}/               ← 既定 docs/。キットはこのフォルダに閉じる
    ├── 01-concept.md 〜 12-ops-runbook.md   ← スケルトン12本（★これから埋める本体）
    ├── formats/             ← 記載標準（キットの写し。変更しない）
    ├── dashboard/
    │   ├── index.html       ← 共通・無編集
    │   └── manifest.json    ← このプロジェクト用の設定
    └── README.md            ← この導入の説明・起動方法
```

## 進め方

### 1. ヒアリング（最大4問。自明なものは聞かない）

1. **キットのクローンパス**（この会話がキット内で始まっていればそこ）
2. **対象プロジェクトのルート**（カレントが対象ならそれ）
3. **システム名**（例：在庫管理システム）→ 各文書の `{システム名}` に差し込む
4. **文書フォルダ名**（既定 `docs/`。既存の docs/ が使用中なら `docs/system/` 等を提案）

### 2. 事前チェック（壊さないため）

- 対象が git リポジトリか確認（でなくても導入は可能。履歴管理を勧めるだけ）
- `{docsDir}/` が既に存在して**空でない**場合は、中身を見せて進め方を確認する（上書きしない）
- `.claude/skills/` に同名スキルが既にある場合も確認する

### 3. コピー（機械的に）

```bash
KIT={クローンパス}; DST={対象ルート}; DOCS={docsDir}

mkdir -p "$DST/$DOCS/dashboard" "$DST/.claude/skills"
cp "$KIT"/templates/docs/*.md   "$DST/$DOCS/"
cp -r "$KIT/formats"            "$DST/$DOCS/formats"
cp "$KIT/dashboard/index.html"  "$DST/$DOCS/dashboard/"
cp "$KIT/templates/manifest.json" "$DST/$DOCS/dashboard/manifest.json"
cp -r "$KIT/consistency-check" "$KIT/change-propagate" "$DST/.claude/skills/"
```

### 4. 差し込み（AIの仕事はここだけ）

1. `{システム名}` を置換する：`$DST/$DOCS/*.md`（**直下のみ**）と `dashboard/manifest.json`。**`formats/` 配下は置換しない**（記載標準の一部であり、スケルトン例に `{システム名}` が残っているのが正しい）
2. **CLAUDE.md**：
   - 無ければ `$KIT/templates/CLAUDE-section.md` を基に新規作成（`{DOCS_DIR}` を置換）
   - **既にあれば末尾に節を追記**（既存の内容には一切手を触れない）
3. `$DST/$DOCS/README.md` を生成：何が導入されたか・ダッシュボードの起動方法・書く順序・スキルの呼び出しフレーズ

### 5. 動作確認

- ファイル確認：文書12本＋`formats/`（13ファイル）＋`dashboard/`（2ファイル）＋スキル2本
- ダッシュボード：`npx serve $DST/$DOCS -p 4322` → `http://localhost:4322/dashboard/` で「12 / 12 文書を読込」
- トレーサビリティ（10）の§2はヘッダのみ＝**タイムラインが空でも正常**（要件を起票すると増えていく）と伝える

### 6. 完了報告と次の一歩

- 導入されたものの一覧と、**書く順序**を案内：構想・用語集 → 要件 → アーキ → 情報定義 → 機能仕様 → API仕様 →（実装）→ 品質保証 → データ移行 → 運用ランブック
- 以後の運用：変更は「この要件を反映して」（change-propagate）／点検は「整合性をチェックして」（consistency-check）
- コミットは**ユーザーに委ねる**（導入内容を確認してもらってから）

## 守るルール

- **内容を創作しない**（スケルトンは空欄のまま渡す。埋めるのはプロジェクトの人とAIの共同作業）
- **既存ファイルを上書きしない**（CLAUDE.md は追記のみ。衝突は必ず確認してから）
- `formats/` と `dashboard/index.html` は**無編集で写す**（プロジェクト差は manifest.json だけで吸収）
- 導入だけを行い、勝手にコミット・プッシュしない
