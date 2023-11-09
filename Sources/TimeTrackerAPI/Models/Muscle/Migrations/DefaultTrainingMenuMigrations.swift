import FluentKit

enum DefaultTrainingMenuMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultTrainingMenuModel.schema)
                .id()
                .field(DefaultTrainingMenuModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultTrainingMenuModel.FieldKeys.v1.aerobic, .bool, .required)
                .field(DefaultTrainingMenuModel.FieldKeys.v1.order, .int, .required)

                .unique(on: DefaultTrainingMenuModel.FieldKeys.v1.name)

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultTrainingMenuModel.schema).delete()
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            let data: [(name: String, aerobic: Bool)] = [
                ("ランニング", true),
                ("シュラッグ", false),
                ("ネック・エクステンション", false),
                ("ラットプルダウン", false),
                ("チンニング", false),
                ("リバース・ラットプルダウン", false),
                ("ナローグリップ・ラットプルダウン", false),
                ("ベントオーバー・バーベルロウイング", false),
                ("ワンハンド・ダンベルロウイング", false),
                ("マシン・シーテッドロウイング(P)", false),
                ("マシン・シーテッドロウイング(N)", false),
                ("シーテッド・プーリーロウイング", false),
                ("パックプレス", false),
                ("アップライトロウイング", false),
                ("サイドレイズ", false),
                ("リアレイズ", false),
                ("フロントレイズ", false),
                ("フロントプレス", false),
                ("シーテッド・ダンベルプレス", false),
                ("ダンベルプレス", false),
                ("ペンチプレス", false),
                ("ダンベルフライ", false),
                ("バーベル・インクラインベンチプレス", false),
                ("ケーブル・クロスオーバー", false),
                ("ストレートアーム・ブルオーバー", false),
                ("ダンベル・ベンチプレス", false),
                ("ベックテック（ペクトラル・フライ）", false),
                ("ディップス", false),
                ("チェスト・プレス", false),
                ("インクライン・ダンベルカール", false),
                ("シーテッド・ダンベルカール", false),
                ("スタンディング・バーベルカール", false),
                ("シーテッド・コンセントレーションカール", false),
                ("リバース・バーベルカール", false),
                ("ライイング・トライセップスエクステンション", false),
                ("45度トライセップス・エクステンション", false),
                ("トライセップス・キックバック", false),
                ("トライセップス・プレスダウン", false),
                ("ダンベル・フレンチプレス", false),
                ("リストカール", false),
                ("リバース・リストカール", false),
                ("アブドミナル・ベンチクランチ", false),
                ("リバース・トランクツイスト", false),
                ("シットアップ", false),
                ("ケーブルクランチ", false),
                ("レッグレイズ", false),
                ("ツイスト", false),
                ("サイドベンド", false),
                ("パックエクステンション", false),
                ("デッドリフト", false),
                ("グッドモーニング・エクササイズ", false),
                ("スクワット", false),
                ("フロントスクワット", false),
                ("レッグプレス", false),
                ("フォワードランジ", false),
                ("サイドランジ", false),
                ("レッグエクステンション", false),
                ("レッグカール", false),
                ("スタンディング・レッグカール", false),
                ("レッグアダクション", false),
                ("シシースクワット", false),
                ("スタンディング・カーフレイズ", false),
                ("シーテッド・カーフレイズ", false),
                ("ドンキー・カーフレイズ", false),
            ]

            for (i, e) in data.enumerated() {
                if
                    let found = try await DefaultTrainingMenuModel
                    .query(on: db)
                    .filter(\.$name == e.name)
                    .first()
                {
                    found.aerobic = e.aerobic
                    found.order = i + 1
                    try await found.update(on: db)
                } else {
                    try await DefaultTrainingMenuModel(
                        name: e.name,
                        aerobic: e.aerobic,
                        order: i + 1
                    )
                    .create(on: db)
                }
            }
        }

        func revert(on db: Database) async throws {}
    }
}
