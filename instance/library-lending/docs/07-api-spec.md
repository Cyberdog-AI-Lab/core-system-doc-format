# API仕様 — 図書貸出システム

> 本書は[APIフォーマット](../formats/07-api-spec.md)に沿った実インスタンス。
> API-xxx は[機能仕様](06-func-spec.md) F-xxx の外部I/F。バリデーションは[用語集](02-glossary.md)の値仕様＝[情報定義](05-info-def.md)に従う。

## 1. 概要

館内業務API。認証は司書アカウント（館内LAN）。エラーは理由コードつきで返す。

## 2. 共通仕様

- リクエスト/レスポンスは構造化データ（JSON想定・プロトコル非依存で記述）。
- 日付はISO8601（`YYYY-MM-DD`）。
- 共通エラー：`VALIDATION`（値域違反）／`CONFLICT`（二重貸出・上限超過）／`NOT_FOUND`。

## 3. API詳細

### API-001 蔵書検索（← F-001 / R-001）
- 入力：`isbn`（13桁数字・任意）または `q`（タイトル語）。**`isbn` は用語集の値仕様で検証**。
- 出力：書誌＋蔵書状態一覧。該当なしは空配列。
- エラー：`VALIDATION`（ISBN桁数・文字種）。

### API-002 貸出登録（← F-002 / R-002・R-005）
- 入力：`copyId`, `memberId`, `loanedOn`。
- 処理：上限チェック→期限計算→登録（[情報定義](05-info-def.md) §4 の単一トランザクション）。
- 出力：`loanId`, `dueOn`, 蔵書状態 `ON_LOAN`。
- エラー：
  - `CONFLICT/DOUBLE_LOAN`：対象蔵書が貸出中。
  - `CONFLICT/LIMIT_EXCEEDED`：上限超過（`current`, `limit` を含む）。

### API-003 返却登録（← F-003 / R-003）
- 入力：`loanId`, `returnedOn`。
- 出力：貸出状態 `RETURNED`、蔵書状態 `AVAILABLE`（予約あれば `HELD`）、`overdueDays`（延滞時）。

### API-004 延滞一覧（← F-004 / R-004）
- 入力：`asOf`（基準日・省略時は当日）。
- 出力：延滞貸出の配列（`memberName`, `title`, `overdueDays`）。

## 4. マスタ共通パターン

- コード値（`MemberType`／`CopyStatus`／`LoanStatus`）は[用語集](02-glossary.md) §3 の値のみ許容。未知値は `VALIDATION`。
