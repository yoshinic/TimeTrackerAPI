import FluentKit
import Foundation

extension DefaultTrainingMenuEffectModel {
    static func create(on db: Database) async throws {
        let effectData = try await createEffectData(on: db)
        let menus = try await createMenus(on: db)

        let m = DefaultTrainingMenuEffectModel(
            trainingMenu: .init(menus),
            trainingMenuEffect: .init(effectData)
        )

        try await m.create(on: db)
    }

    private static func createEffectData(
        on db: Database
    ) async throws -> [DefaultTrainingMenuEffectJSONData] {
        try await DefaultMusclePartModel
            .query(on: db)
            .join(children: \.$details, method: .left)
            .join(
                DefaultMuscleModel.self,
                on: \DefaultMuscleModel.$musclePart.$id == \DefaultMusclePartModel.$id,
                method: .left
            )
            .join(
                from: DefaultMuscleModel.self,
                children: \.$trainingMuscleParts
            )

            .group(.or) { or in
                or
                    .filter(
                        \DefaultMuscleModel.$musclePartDetail.$id
                            == \DefaultMusclePartDetailModel.$id
                    )
                    .filter(
                        DefaultMuscleModel.self,
                        \DefaultMuscleModel.$musclePartDetail.$id == nil
                    )
            }
            .all()
            .reduce(into: [DefaultTrainingMenuEffectJSONData]()) { res, part in
                let menuId = try part
                    .joined(DefaultTrainingMusclePartModel.self)
                    .$menu.id
                guard let partId = part.id else { return }

                let i = {
                    if let i = res.firstIndex(where: { $0.menuId == menuId }) {
                        return i
                    } else {
                        res.append(.init(menuId, []))
                        return res.count - 1
                    }
                }()

                let j = {
                    if let j = res[i].data
                        .firstIndex(where: { $0.id == partId })
                    {
                        return j
                    } else {
                        res[i].data.append(
                            .init(partId, part.name, part.order, [])
                        )
                        return res[i].data.count - 1
                    }
                }()

                let muscle = try part.joined(DefaultMuscleModel.self)

                let pd = try {
                    if let _ = muscle.$musclePartDetail.id {
                        return try part.joined(DefaultMusclePartDetailModel.self)
                    } else {
                        return .init(
                            musclePartId: muscle.$musclePart.id,
                            name: "",
                            order: -1
                        )
                    }
                }()

                let k = {
                    if
                        let k = res[i].data[j].details
                        .firstIndex(where: {
                            $0.id == pd.id || ($0.id == nil && pd.name.isEmpty)
                        })
                    {
                        return k
                    } else {
                        res[i].data[j].details.append(
                            .init(pd.id, pd.name, pd.order, [])
                        )
                        return res[i].data[j].details.count - 1
                    }
                }()

                let tmp = try muscle.joined(DefaultTrainingMusclePartModel.self)

                if let _ = res[i].data[j].details[k].effects
                    .firstIndex(where: { $0.id == muscle.id })
                {
                } else {
                    res[i].data[j].details[k].effects.append(
                        .init(
                            muscle.id,
                            muscle.name,
                            muscle.muscleDetail,
                            muscle.ruby,
                            tmp.effect,
                            muscle.order
                        )
                    )
                }
            }
            .map {
                var c = $0
                c.data = c.data.map {
                    var b = $0
                    b.details = b.details.map {
                        var a = $0
                        a.effects = $0.effects.sorted { $0.order < $1.order }
                        return a
                    }
                    b.details = b.details.sorted { $0.order < $1.order }
                    return b
                }
                c.data = c.data.sorted { $0.order < $1.order }
                return c
            }
    }

    private static func createMenus(
        on db: Database
    ) async throws -> [DefaultTrainingPartJSONData] {
        try await DefaultMusclePartModel
            .query(on: db)
            .join(
                from: DefaultMusclePartModel.self,
                children: \.$menus
            )
            .all()
            .reduce(into: [DefaultTrainingPartJSONData]()) { res, part in
                guard let partId = part.id else { return }

                let i = {
                    if let i = res.firstIndex(where: { $0.id == partId }) {
                        return i
                    } else {
                        res.append(.init(partId, part.name, part.order, []))
                        return res.count - 1
                    }
                }()

                let menu = try part.joined(DefaultTrainingMenuModel.self)

                if let _ = res[i].menus.firstIndex(where: { $0.id == menu.id }) {
                } else {
                    res[i].menus.append(.init(
                        menu.id!,
                        menu.name,
                        menu.aerobic,
                        menu.order
                    ))
                }
            }
            .map {
                var a = $0
                a.menus = a.menus.sorted { $0.order < $1.order }
                return a
            }
            .sorted { $0.order < $1.order }
    }

    public static func fetch(
        on db: Database
    ) async throws -> (
        menus: [DefaultTrainingPartJSONData],
        muscles: [UUID: [DefaultMusclePartJSONData]]
    ) {
        guard
            let data = try await DefaultTrainingMenuEffectModel
            .query(on: db)
            .first()
        else { return ([], [:]) }

        let menus = data.trainingMenu.data
        let muscles: [UUID: [DefaultMusclePartJSONData]]
            = data.trainingMenuEffect.data.reduce(into: [:]) {
                if $0[$1.menuId] == nil {
                    $0[$1.menuId] = []
                }
                $0[$1.menuId]!.append(contentsOf: $1.data)
            }

        return (menus, muscles)
    }
}
