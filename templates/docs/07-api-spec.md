# {システム名}：API仕様

## 1. 概要

- 本書は {システム名} の API 詳細仕様。各APIの I/F と内部処理フローを定義する。
- 関連ドキュメント：機能仕様／情報定義

## 2. 共通仕様

- 認証・認可：
- 共通レスポンス形式：成功 `{ data }` ／ エラー `{ errors: [{ errorType, message }] }`
- エラーコード一覧：VALIDATION_ERROR / NOT_FOUND / CONFLICT / BUSINESS_RULE_VIOLATION / UNAUTHORIZED / FORBIDDEN / INTERNAL_ERROR
- 共通型定義：Pagination / DateString / Money など

## 3. {カテゴリ}関連API

### {API名}

- 概要：
- 利用画面：{機能仕様の画面}
- 関連情報定義：1-N, 3-N
- リクエスト（型）：
- レスポンス（型）：
- 内部処理フロー：1. 入力バリデーション 2. マスタ存在チェック 3. 業務ルール（情報定義 3-x） 4. データ操作（トランザクション境界 / 楽観ロック） 5. レスポンス構築
- バリデーションエラー：| コード | 条件 | メッセージ |

## 4. マスタAPIの共通パターン

- list / get / create / update（version 必須＝楽観ロック） / delete（参照されていれば不可）を1回だけ定義し、マスタ別は差分のみ書く。
