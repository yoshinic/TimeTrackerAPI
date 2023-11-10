import FluentKit

enum DefaultMuscleMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await db
                .schema(DefaultMuscleModel.schema)
                .id()
                .field(
                    DefaultMuscleModel.FieldKeys.v1.musclePartId,
                    .uuid,
                    .required
                )
                .field(
                    DefaultMuscleModel.FieldKeys.v1.musclePartDetailId,
                    .uuid
                )
                .field(DefaultMuscleModel.FieldKeys.v1.name, .string, .required)
                .field(DefaultMuscleModel.FieldKeys.v1.muscleDetail, .string, .required)
                .field(DefaultMuscleModel.FieldKeys.v1.ruby, .string, .required)
                .field(DefaultMuscleModel.FieldKeys.v1.order, .int, .required)

                .foreignKey(
                    DefaultMuscleModel.FieldKeys.v1.musclePartId,
                    references: DefaultMusclePartModel.schema,
                    .id
                )
                .foreignKey(
                    DefaultMuscleModel.FieldKeys.v1.musclePartDetailId,
                    references: DefaultMusclePartDetailModel.schema,
                    .id
                )

                .unique(
                    on:
                    DefaultMuscleModel.FieldKeys.v1.name,
                    DefaultMuscleModel.FieldKeys.v1.muscleDetail
                )

                .ignoreExisting()
                .create()
        }

        func revert(on db: Database) async throws  {
            try await db.schema(DefaultMuscleModel.schema).delete()
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
                let _ = defaultMuscleParts.filter({ $0.name == "その他" }).first?.id
            else { throw AppError.notFound }

            let dmpds = try await DefaultMusclePartDetailModel
                .query(on: db)
                .all()

            guard
                let id1 = dmpds.filter({ $0.name == "脊柱起立筋" }).first?.id,
                let id2 = dmpds.filter({ $0.name == "下部深背諸筋" }).first?.id,
                let id3 = dmpds.filter({ $0.name == "大腿四頭筋" }).first?.id,
                let id4 = dmpds.filter({ $0.name == "ハムストリング" }).first?.id
            else { throw AppError.notFound }

            let data: [(
                name: String,
                muscleDetail: String,
                ruby: String,
                musclePartId: UUID,
                musclePartDetailId: UUID?
            )] = [
                ("首の筋肉群", "", "", neck, nil),

                ("三角筋", "前", "", shoulder, nil),
                ("三角筋", "中", "", shoulder, nil),
                ("三角筋", "後", "", shoulder, nil),

                ("大胸筋", "上", "", chest, nil),
                ("大胸筋", "下", "", chest, nil),
                ("小胸筋", "", "", chest, nil),

                ("広背筋", "", "", back1, nil),
                ("僧帽筋", "上", "", back1, nil),
                ("僧帽筋", "中", "", back1, nil),
                ("僧帽筋", "下", "", back1, nil),
                ("大円筋", "", "", back1, nil),
                ("小円筋", "", "", back1, nil),
                ("菱形筋", "", "", back1, nil),
                ("辣上筋", "", "", back1, nil),
                ("辣下筋", "", "", back1, nil),

                ("鋸筋", "前", "", chest, nil),
                ("鋸筋", "後", "", chest, nil),

                ("上腕二頭筋", "", "", arm1, nil),
                ("上腕筋", "", "", arm1, nil),
                ("上腕三頭筋", "", "", arm2, nil),

                ("腕橈骨筋", "", "", arm3, nil),
                ("烏口腕筋", "", "", arm3, nil),
                ("長掌筋", "", "", arm3, nil),
                ("橈侧手根屈筋", "", "", arm3, nil),
                ("尺侧手根屈筋", "", "", arm3, nil),
                ("尺側手根伸筋", "", "", arm3, nil),
                ("長橈側手根伸筋", "", "", arm3, nil),
                ("総指伸筋", "", "", arm3, nil),
                ("短橈側手根伸筋", "", "", arm3, nil),
                ("小指伸筋", "", "", arm3, nil),

                ("腹直筋", "上", "", stomach, nil),
                ("腹直筋", "下", "", stomach, nil),
                ("外腹斜筋", "", "", stomach, nil),
                ("内腹斜筋", "", "", stomach, nil),
                ("腹横筋", "", "", stomach, nil),

                ("胸腸肋筋", "", "", back2, id1),
                ("腰腸肋筋", "", "", back2, id1),
                ("背最長筋", "", "", back2, id1),
                ("棘筋", "", "", back2, id1),
                ("横棘間筋", "", "", back2, id2),
                ("棘間筋", "", "", back2, id2),
                ("回旋筋", "", "", back2, id2),
                ("多裂筋", "", "", back2, id2),

                ("殿筋", "大", "", thigh1, nil),
                ("殿筋", "中", "", thigh1, nil),
                ("殿筋", "小", "", thigh1, nil),
                ("恥骨筋", "", "", thigh1, nil),
                ("薄筋", "", "", thigh1, nil),
                ("長内転筋", "", "", thigh1, nil),
                ("大内転筋", "", "", thigh1, nil),
                ("短内転筋", "", "", thigh1, nil),
                ("大腿直筋", "", "", thigh1, id3),
                ("中間広筋", "", "", thigh1, id3),
                ("外側広筋", "", "", thigh1, id3),
                ("内側広筋", "", "", thigh1, id3),
                ("大腿二頭筋", "", "", thigh1, id4),
                ("半膜様筋", "", "", thigh1, id4),
                ("半腱様筋", "", "", thigh1, id4),
                ("前骨筋", "", "", thigh1, nil),
                
                ("腓腹筋", "", "", thigh2, nil),
                ("ヒラメ筋", "", "", thigh2, nil),
            ]

            var order = 1
            var musclePartId: UUID? = nil
            var musclePartDetailId: UUID? = nil
            for e in data {
                if e.musclePartId != musclePartId {
                    order = 1
                    musclePartId = e.musclePartId
                }
                if e.musclePartDetailId != musclePartDetailId {
                    order = 1
                    musclePartDetailId = e.musclePartDetailId
                }

                if
                    let found = try await DefaultMuscleModel
                    .query(on: db)
                    .filter(\.$musclePart.$id == e.musclePartId)
                    .filter(\.$musclePartDetail.$id == e.musclePartDetailId)
                    .filter(\.$name == e.name)
                    .filter(\.$muscleDetail == e.muscleDetail)
                    .first()
                {
                    found.ruby = e.ruby
                    found.order = order
                    try await found.update(on: db)
                } else {
                    let m = DefaultMuscleModel(
                        musclePartId: e.musclePartId,
                        musclePartDetailId: e.musclePartDetailId,
                        name: e.name,
                        muscleDetail: e.muscleDetail,
                        ruby: e.ruby,
                        order: order
                    )
                    try await m.create(on: db)
                }

                order += 1
            }
        }

        func revert(on db: Database) async throws {}
    }
}
