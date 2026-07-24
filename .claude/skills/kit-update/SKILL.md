---
name: kit-update
description: >
  すでに core-system-doc-format（基幹システム文書体系キット）を導入済みのプロジェクトを、最新のキットへ更新するスキル。
  記載標準（formats/）・ダッシュボード・AIスキル（.claude/skills＋.agents/skillsシンボリックリンク）・反映漏れリマインドフック・
  CLAUDE.md/AGENTS.md の運用ルール節・settings.json のフック登録・manifest.json の構造キーを、埋めた実文書を壊さずに更新する。
  フォーマット（記載標準）の変更は consistency-check で差分を可視化し、change-propagate スキルで埋めた実文書へ反映まで完遂する。
  「キットを更新して」「core-system-doc-format を最新化して」「導入済みのプロジェクトにキットの変更を反映して」
  「フォーマットの更新を取り込んで」「skills を新しいバージョンにして」など、導入済みプロジェクトを最新キットへ追従させたいときに必ずこのスキルを使うこと。
---

# 更新（kit-update）スキル

**すでに導入済み**のプロジェクトを、最新のキットへ追従させる。`kit-install` が初回導入なら、こちらは2回目以降の更新。

このスキルの最重要原則は **「埋めた実文書を壊さない」**。導入後にプロジェクトの人とAIが埋めた `docs/*.md`（実データ）・`manifest.json`（プロジェクト設定）・`CLAUDE.md`/`AGENTS.md`（プロジェクト固有の記述）は、**上書きせず・マージ or 差分提示で扱う**。キットの写しにすぎない部分（記載標準・ダッシュボード共通HTML・スキル本体・フック）だけを丸ごと入れ替える。

> **実行場所はキットのクローン内**（本スキルは `.claude/skills/` に同梱）。更新先プロジェクトは**パスで受け取る**：
> `/kit-update ~/path/to/your-project を最新化して`

## 更新対象の2分類（これがこのスキルの背骨）

| 分類 | 対象 | 扱い |
|---|---|---|
| **キット所有（丸ごと入れ替え可）** | `{DOCS}/formats/`・`{DOCS}/dashboard/index.html`・`.claude/skills/consistency-check`・`.claude/skills/change-propagate`・`.claude/hooks/check-doc-ops-guide-sync.sh`・`.agents/skills/` のシンボリックリンク | 導入時に「編集しない」と約束した写し。キット側で**上書き**してよい |
| **プロジェクト所有（上書き禁止・マージか差分提示）** | `{DOCS}/01〜12-*.md`（埋めた実文書）・`{DOCS}/dashboard/manifest.json`・`CLAUDE.md`・`AGENTS.md`・`.claude/settings.json` | 人が埋めた・プロジェクト固有。**構造キーのマージ**か**差分提示**で扱い、中身は消さない |

判定は**版番号でなく実ファイルの内容差分**で行う（キットに版管理は無い。実体を突き合わせるのが最も確実）。

## 進め方

### 1. 対象の特定と現状把握

1. **KIT（キットのルート）**＝本スキルが同梱されているこのリポジトリ（通常はカレント）。聞かない。
2. **更新先プロジェクトのルート（DST）**＝頼まれたときにパスが添えられていればそれ。無ければ聞く。
3. **文書フォルダ（DOCS）を自動検出**：`DST` 配下で `dashboard/manifest.json` を持つフォルダ、または `01-concept.md`〜`12-doc-ops-guide.md` が並ぶフォルダを探す（既定 `docs/`。`docs/system/` 等になっている場合もある）。見つからなければ「このプロジェクトはまだ未導入では？ `kit-install` を検討」と伝える。
4. **導入済みの構成を確認**：スキル2本・フック・`.agents/skills/`・settings.json・CLAUDE.md/AGENTS.md の有無を一覧化する。

### 2. 差分プレビュー（何が変わるかを先に見せる）

書き換える前に、キット所有ファイルの差分を出してユーザーに見せる。**壊す変更が無いことを確認してから進む。**

```bash
KIT={キットのルート}; DST={更新先}; DOCS={検出した文書フォルダ}

echo "=== formats/（記載標準）==="
diff -rq "$KIT/formats" "$DST/$DOCS/formats" || true
echo "=== dashboard/index.html（共通HTML）==="
diff -q "$KIT/dashboard/index.html" "$DST/$DOCS/dashboard/index.html" || true
echo "=== skills（本体）==="
diff -rq "$KIT/.claude/skills/consistency-check" "$DST/.claude/skills/consistency-check" || true
diff -rq "$KIT/.claude/skills/change-propagate"  "$DST/.claude/skills/change-propagate" || true
echo "=== hook ==="
diff -q "$KIT/.claude/hooks/check-doc-ops-guide-sync.sh" "$DST/.claude/hooks/check-doc-ops-guide-sync.sh" || true
```

差分が無ければ「その分類は最新」と報告し、変更のある分類だけ次へ進む。

### 3. キット所有ファイルの更新（丸ごと入れ替え）

```bash
# 記載標準・共通HTML・スキル本体・フックを最新へ
cp -r "$KIT/formats/." "$DST/$DOCS/formats/"
cp "$KIT/dashboard/index.html" "$DST/$DOCS/dashboard/"
cp -r "$KIT/.claude/skills/consistency-check/." "$DST/.claude/skills/consistency-check/"
cp -r "$KIT/.claude/skills/change-propagate/."  "$DST/.claude/skills/change-propagate/"
cp "$KIT/.claude/hooks/check-doc-ops-guide-sync.sh" "$DST/.claude/hooks/"
chmod +x "$DST/.claude/hooks/check-doc-ops-guide-sync.sh"

# .agents/skills/ のシンボリックリンクが無ければ作る（旧バージョンからの更新で未整備なことがある）
mkdir -p "$DST/.agents/skills"
[ -e "$DST/.agents/skills/consistency-check" ] || ln -s ../../.claude/skills/consistency-check "$DST/.agents/skills/consistency-check"
[ -e "$DST/.agents/skills/change-propagate" ]  || ln -s ../../.claude/skills/change-propagate  "$DST/.agents/skills/change-propagate"
```

> **スキルが増減していたら**：キットの `.claude/skills/` から consistency-check・change-propagate 以外の「導入先に配るスキル」が増えていれば同様にコピー＋シンボリックリンク。廃止されたスキルは**消さず**、ユーザーに「キットから外れた」と伝えて判断を委ねる（消すのは常にユーザー承認のうえ）。

### 4. プロジェクト所有ファイルの更新（マージ・差分提示。ここがAIの本番）

**4-1. `manifest.json`（構造キーのマージ）**
キットの `templates/manifest.json` に、導入先の manifest.json に無い**構造キー**（例：この体系では過去に `skillsDir`・`skills` 配列、`formatsDir`〔各文書に「実文書／記載標準」切替を出す〕を追加した）があれば**足す**。ただし `title`・`subtitle`・`docs` の各エントリ値・`instance.file` など**プロジェクト固有の値は保持**する。`docs` 配列の要素が増減（文書の新設・改名）していたら、その差分を提示してマージする。判断に迷う値は上書きせず確認する。

> `formatsDir` は導入レイアウトでは `../formats/`（ダッシュボードと `formats/` が兄弟）。旧バージョンから更新するプロジェクトには未設定なので、これを足すと12番などの**記載標準（運用ルール全文）がダッシュボードで読めるようになる**。

**4-2. `CLAUDE.md` / `AGENTS.md`（キット節だけ差し替え）**
両方が存在しうる（Codex CLI を併用するプロジェクトは `AGENTS.md` を持つ）。存在する各ファイルについて：

- キットが追記した節（見出し `## ドキュメント体系（core-system-doc-format）`）を探す。
- 見つかれば、その**節だけ**を `templates/CLAUDE-section.md`（`{DOCS_DIR}` を実際の値へ置換）の最新内容へ差し替える。**節の外（プロジェクトが自分で書いた部分）には一切触れない**。差し替え前に diff を見せて確認する。
- 節が見つからなければ（ユーザーが消した・改名した）勝手に足さず、「キット節が見当たらない。追記しますか？」と確認する。
- `AGENTS.md` が無いが Codex CLI も使いたい場合は、`CLAUDE.md` のキット節と同じ内容で `AGENTS.md` を新規作成することを提案する（押し付けない）。

**4-3. `.claude/settings.json`（フック登録の確認・マージ）**
`hooks.PostToolUse` に `check-doc-ops-guide-sync.sh` を呼ぶ `matcher: "Edit|Write"` エントリがあるか確認。無ければ `kit-install` §4-3 と同じ手順で**追記**（既存の他設定は変更しない）。既にあれば何もしない。

```bash
jq -e '.hooks.PostToolUse[]? | select(.matcher=="Edit|Write") | .hooks[]? | select(.command|test("check-doc-ops-guide-sync"))' "$DST/.claude/settings.json" >/dev/null \
  && echo "フック登録あり（更新不要）" || echo "フック未登録 → 追記が必要"
```

**4-4. 埋めた実文書（`{DOCS}/01〜12-*.md`）は機械的に上書きしない**
フォーマット（記載標準）の章立て・表が変わっていても、**埋めた実文書を機械的に書き換えない**。§5 で consistency-check がドリフトを可視化し、**change-propagate スキルが**（既定の1層ずつ提案→確認で・埋めた内容を保持したまま）新フォーマットへ反映する。反映は §5 で**完遂**させ、宿題にしない。

### 5. フォーマット変更の実文書への反映（change-propagate スキルで完遂する）

§3で `formats/`（記載標準）を新しくしたことで、**埋めた実文書の章立て・表・記法が新フォーマットと食い違う**可能性がある。これを機械的に潰さず、かつ宿題で放置もせず、**change-propagate スキルを使って反映まで完遂する**：

1. **ドリフトの可視化**：consistency-check を `{DOCS}` に実走（観点G フォーマット準拠＝章一致・必須章の欠落・表の列/セル・改訂履歴章の混入を検出。併せてA〜Hで値域・状態・ID連鎖・用語ドリフトの破れも洗う）。→ **追従が要る文書と箇所の一覧**が出る。

2. **各文書を change-propagate で反映**：ドリフトのある文書ごとに **change-propagate スキルを起動**し、次の枠組みで反映する：
   - 入力は「**記載標準（`formats/NN`）の改訂に、実文書 `{DOCS}/NN` を追従させる**」。これは要件に紐づかない **要件外の改訂（リファクタ相当）** なので、change-propagate はこれを**トレーサビリティ §4「要件外の改訂ログ」**に記録する（§2 マトリクス・§3 タイムラインには載せない）。
   - change-propagate の既定どおり **1層ずつ提案 → ユーザー確認 → 適用**。**上流→下流**の順で伝わる（例：情報定義の表を新フォーマットに直したら、その属性を参照する機能仕様・API仕様・品質保証の記述も同じ流れで追従する）。
   - change-propagate の不変ルールがそのまま効く：**消さない・`formats/` に従う・用語集を源に・既存の値を勝手に創作しない**。埋めた中身は保持し、**新フォーマットの器に載せ替えるだけ**。

3. **文書の新設・章の追加が要る場合**：`templates/docs/` の該当スケルトンを器として使い、埋める中身はプロジェクトの人とAIの共同で（内容の創作はしない）。これも change-propagate の流れに乗せる。

4. **反映後の再チェック**：consistency-check を `{DOCS}` に再実走し、観点Gほかのドリフトが**解消**したことを確認する。残った指摘は §7 で報告する。

> 要は「キット所有＝丸ごと最新化／プロジェクト所有＝壊さずマージ／**実文書のフォーマット追従＝consistency-check で可視化 → change-propagate スキルで反映まで完遂 → consistency-check で再確認**」。

### 6. 検証

- 差分再確認：キット所有ファイルが `diff -rq` で**キットと一致**（＝最新化済み）。
- ダッシュボード：`npx serve "$DST/$DOCS" -p 4322` → `http://localhost:4322/dashboard/` で「12 / 12 文書を読込」・スキルタブ表示・コンソールエラー無し。
- フックの生存確認：`echo '{"tool_name":"Edit","tool_input":{"file_path":"'$DST'/'$DOCS'/12-doc-ops-guide.md"}}' | bash "$DST/.claude/hooks/check-doc-ops-guide-sync.sh"` が systemMessage を返す。
- シンボリックリンク：`readlink "$DST/.agents/skills/consistency-check"` が解決し、`cat` で本体が読める。
- **フォーマット追従の反映後 consistency-check が clean**（観点Gほかのドリフトが解消済み）。残る指摘は「人の判断が要る残件」だけ。

### 7. 完了報告

- **更新した分類**（formats/・dashboard・skills・hook・manifest構造キー・CLAUDE/AGENTS節）と、**変更が無かった分類**を分けて報告。
- **実文書のフォーマット追従の結果**：change-propagate で反映した文書・箇所と、トレーサビリティ §4「要件外の改訂ログ」に追記した行を報告。反映後の consistency-check が clean になった（またはどの指摘が残るか）まで示す。
- **人の判断が要る残件だけ**を残す（例：新設文書のドメイン中身、業務上のキー判定など、機械に決められないもの）。**機械的な追従は §5 で済んでいる状態**にする（宿題で放置しない）。
- コミットは**ユーザーに委ねる**（更新内容を確認してもらってから）。

## 守るルール

- **埋めた実文書（`docs/01〜12`）を機械的に上書きしない**。フォーマット追従は consistency-check で可視化し、**change-propagate スキルで（要件外→トレーサビリティ §4 改訂ログとして）反映まで完遂**する。宿題で放置しない。
- **`manifest.json`・`CLAUDE.md`・`AGENTS.md`・`.claude/settings.json` はマージか節差し替えのみ**。プロジェクト固有の値・記述を消さない。
- **キット所有ファイル**（formats/・dashboard/index.html・スキル本体・フック・`.agents/skills/`）だけ丸ごと入れ替える。
- `.agents/skills/` は**シンボリックリンクのまま**（実体化・内容分岐をしない）。
- 廃止されたスキル・文書は**消さず**、ユーザーに判断を委ねる（消すのは常にユーザー承認のうえ）。
- 更新だけを行い、勝手にコミット・プッシュしない。
