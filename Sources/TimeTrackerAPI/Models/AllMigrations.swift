import FluentKit

enum AllMigrations {
    struct v1: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await DefaultCategoryMigrations.v1().prepare(on: db)
            try await DefaultActivityMigrations.v1().prepare(on: db)

            try await CategoryMigrations.v1().prepare(on: db)
            try await ActivityMigrations.v1().prepare(on: db)

            try await RecordMigrations.v1().prepare(on: db)

            // Default Muscle
            try await DefaultMusclePartMigrations.v1().prepare(on: db)
            try await DefaultMusclePartDetailMigrations.v1().prepare(on: db)
            try await DefaultMuscleMigrations.v1().prepare(on: db)
            try await DefaultTrainingMenuMigrations.v1().prepare(on: db)
            try await DefaultTrainingMusclePartMigrations.v1().prepare(on: db)
            // Muscle
            try await MusclePartMigrations.v1().prepare(on: db)
            try await MusclePartDetailMigrations.v1().prepare(on: db)
            try await MuscleMigrations.v1().prepare(on: db)
            try await TrainingMenuMigrations.v1().prepare(on: db)
            try await TrainingMusclePartMigrations.v1().prepare(on: db)
            try await TrainingRecordMigrations.v1().prepare(on: db)
            try await MuscleTrainingRecordMigrations.v1().prepare(on: db)

            try await DefaultTrainingMenuEffectMigrations.v1().prepare(on: db)
        }

        func revert(on db: Database) async throws  {
            try await DefaultTrainingMenuEffectMigrations.v1().revert(on: db)

            // Muscle
            try await MuscleTrainingRecordMigrations.v1().revert(on: db)
            try await TrainingRecordMigrations.v1().revert(on: db)
            try await TrainingMusclePartMigrations.v1().revert(on: db)
            try await TrainingMenuMigrations.v1().revert(on: db)
            try await MuscleMigrations.v1().revert(on: db)
            try await MusclePartDetailMigrations.v1().revert(on: db)
            try await MusclePartMigrations.v1().revert(on: db)
            // Default Muscle
            try await DefaultTrainingMusclePartMigrations.v1().revert(on: db)
            try await DefaultTrainingMenuMigrations.v1().revert(on: db)
            try await DefaultMuscleMigrations.v1().revert(on: db)
            try await DefaultMusclePartDetailMigrations.v1().revert(on: db)
            try await DefaultMusclePartMigrations.v1().revert(on: db)

            try await RecordMigrations.v1().revert(on: db)

            try await ActivityMigrations.v1().revert(on: db)
            try await CategoryMigrations.v1().revert(on: db)

            try await DefaultActivityMigrations.v1().revert(on: db)
            try await DefaultCategoryMigrations.v1().revert(on: db)
        }
    }

    struct seed: AsyncMigration {
        func prepare(on db: Database) async throws {
            try await DefaultCategoryMigrations.seed().prepare(on: db)
            try await DefaultActivityMigrations.seed().prepare(on: db)

            try await CategoryMigrations.seed().prepare(on: db)
            try await ActivityMigrations.seed().prepare(on: db)

            try await RecordMigrations.seed().prepare(on: db)

            // Default Muscle
            try await DefaultMusclePartMigrations.seed().prepare(on: db)
            try await DefaultMusclePartDetailMigrations.seed().prepare(on: db)
            try await DefaultMuscleMigrations.seed().prepare(on: db)
            try await DefaultTrainingMenuMigrations.seed().prepare(on: db)
            try await DefaultTrainingMusclePartMigrations.seed().prepare(on: db)
            // Muscle
            try await MusclePartMigrations.seed().prepare(on: db)
            try await MusclePartDetailMigrations.seed().prepare(on: db)
            try await MuscleMigrations.seed().prepare(on: db)
            try await TrainingMenuMigrations.seed().prepare(on: db)
            try await TrainingMusclePartMigrations.seed().prepare(on: db)
            try await TrainingRecordMigrations.seed().prepare(on: db)
            try await MuscleTrainingRecordMigrations.seed().prepare(on: db)

            try await DefaultTrainingMenuEffectMigrations.seed().prepare(on: db)
        }

        func revert(on db: Database) async throws {
            try await DefaultTrainingMenuEffectMigrations.seed().revert(on: db)

            // Muscle
            try await MuscleTrainingRecordMigrations.seed().revert(on: db)
            try await TrainingRecordMigrations.seed().revert(on: db)
            try await TrainingMusclePartMigrations.seed().revert(on: db)
            try await TrainingMenuMigrations.seed().revert(on: db)
            try await MuscleMigrations.seed().revert(on: db)
            try await MusclePartDetailMigrations.seed().revert(on: db)
            try await MusclePartMigrations.seed().revert(on: db)
            // Default Muscle
            try await DefaultTrainingMusclePartMigrations.seed().revert(on: db)
            try await DefaultTrainingMenuMigrations.seed().revert(on: db)
            try await DefaultMuscleMigrations.seed().revert(on: db)
            try await DefaultMusclePartDetailMigrations.seed().revert(on: db)
            try await DefaultMusclePartMigrations.seed().revert(on: db)

            try await RecordMigrations.seed().revert(on: db)

            try await ActivityMigrations.seed().revert(on: db)
            try await CategoryMigrations.seed().revert(on: db)

            try await DefaultActivityMigrations.seed().revert(on: db)
            try await DefaultCategoryMigrations.seed().revert(on: db)
        }
    }
}
