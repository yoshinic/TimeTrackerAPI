import FluentKit

enum DefaultTrainingMenuMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultTrainingMenuModel.schema)
                .id()
                .field(DefaultTrainingMenuModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultTrainingMenuModel.FieldKeys.v1.mainPart, .uuid, .required)
                .field(DefaultTrainingMenuModel.FieldKeys.v1.aerobic, .bool, .required)
                .field(DefaultTrainingMenuModel.FieldKeys.v1.order, .int, .required)

                .foreignKey(
                    DefaultTrainingMenuModel.FieldKeys.v1.mainPart,
                    references: DefaultMusclePartModel.schema,
                    .id
                )

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
            let defaultMuscleParts = try await DefaultMusclePartModel
                .query(on: db)
                .all()

            guard
                let neck = defaultMuscleParts.filter({ $0.name == "首" }).first?.id,
                let shoulder = defaultMuscleParts.filter({ $0.name == "肩" }).first?.id,
                let chest = defaultMuscleParts.filter({ $0.name == "胸" }).first?.id,
                let back1 = defaultMuscleParts.filter({ $0.name == "上背" }).first?.id,
                let arm1 = defaultMuscleParts.filter({ $0.name == "上腕二頭筋" }).first?.id,
                let arm2 = defaultMuscleParts.filter({ $0.name == "上腕三頭筋" }).first?.id,
                let arm3 = defaultMuscleParts.filter({ $0.name == "前腕" }).first?.id,
                let stomach = defaultMuscleParts.filter({ $0.name == "腹" }).first?.id,
                let back2 = defaultMuscleParts.filter({ $0.name == "下背" }).first?.id,
                let thigh1 = defaultMuscleParts.filter({ $0.name == "大腿" }).first?.id,
                let thigh2 = defaultMuscleParts.filter({ $0.name == "下腿" }).first?.id,
                let other = defaultMuscleParts.filter({ $0.name == "その他" }).first?.id
            else { throw AppError.notFound }

            let data: [(name: String, mainPart: UUID, aerobic: Bool)] = [
                ("ランニング", other, true),
                ("シュラッグ", neck, false),
                ("ネック・エクステンション", neck, false),
                ("ラットプルダウン", back1, false),
                ("チンニング", back1, false),
                ("リバース・ラットプルダウン", back1, false),
                ("ナローグリップ・ラットプルダウン", back1, false),
                ("ベントオーバー・バーベルロウイング", back1, false),
                ("ワンハンド・ダンベルロウイング", back1, false),
                ("マシン・シーテッドロウイング(P)", back1, false),
                ("マシン・シーテッドロウイング(N)", back1, false),
                ("シーテッド・プーリーロウイング", back1, false),
                ("パックプレス", shoulder, false),
                ("アップライトロウイング", shoulder, false),
                ("サイドレイズ", shoulder, false),
                ("リアレイズ", shoulder, false),
                ("フロントレイズ", shoulder, false),
                ("フロントプレス", shoulder, false),
                ("シーテッド・ダンベルプレス", shoulder, false),
                ("ダンベルプレス", shoulder, false),
                ("ペンチプレス", chest, false),
                ("ダンベルフライ", chest, false),
                ("バーベル・インクラインベンチプレス", chest, false),
                ("ケーブル・クロスオーバー", chest, false),
                ("ストレートアーム・ブルオーバー", chest, false),
                ("ダンベル・ベンチプレス", chest, false),
                ("ベックテック（ペクトラル・フライ）", chest, false),
                ("ディップス", chest, false),
                ("チェスト・プレス", chest, false),
                ("インクライン・ダンベルカール", arm1, false),
                ("シーテッド・ダンベルカール", arm1, false),
                ("スタンディング・バーベルカール", arm1, false),
                ("シーテッド・コンセントレーションカール", arm1, false),
                ("リバース・バーベルカール", arm1, false),
                ("ライイング・トライセップスエクステンション", arm2, false),
                ("45度トライセップス・エクステンション", arm2, false),
                ("トライセップス・キックバック", arm2, false),
                ("トライセップス・プレスダウン", arm2, false),
                ("ダンベル・フレンチプレス", arm2, false),
                ("リストカール", arm3, false),
                ("リバース・リストカール", arm3, false),
                ("アブドミナル・ベンチクランチ", stomach, false),
                ("リバース・トランクツイスト", stomach, false),
                ("シットアップ", stomach, false),
                ("ケーブルクランチ", stomach, false),
                ("レッグレイズ", stomach, false),
                ("ツイスト", stomach, false),
                ("サイドベンド", stomach, false),
                ("パックエクステンション", back2, false),
                ("デッドリフト", back2, false),
                ("グッドモーニング・エクササイズ", back2, false),
                ("スクワット", thigh1, false),
                ("フロントスクワット", thigh1, false),
                ("レッグプレス", thigh1, false),
                ("フォワードランジ", thigh1, false),
                ("サイドランジ", thigh1, false),
                ("レッグエクステンション", thigh1, false),
                ("レッグカール", thigh1, false),
                ("スタンディング・レッグカール", thigh1, false),
                ("レッグアダクション", thigh1, false),
                ("シシースクワット", thigh1, false),
                ("スタンディング・カーフレイズ", thigh2, false),
                ("シーテッド・カーフレイズ", thigh2, false),
                ("ドンキー・カーフレイズ", thigh2, false),
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
                        mainPartId: e.mainPart,
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
