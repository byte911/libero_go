-schema=user_types
    version = 1.0

-import
    common = "./common.l"

-types
    User:
        id: common.UserId
        name: string
        email: string
        role: UserRole
        preferences: UserPreferences
        learning_path: [common.CourseId]
        achievements: [Achievement]
        created_at: timestamp
        constraints:
            - email matches "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"

    UserRole:
        enum:
            - student
            - instructor
            - teaching_assistant
            - admin

    UserPreferences:
        preferred_categories: [string]
        difficulty_level: DifficultyLevel
        learning_pace: LearningPace
        notification_settings: NotificationSettings

    DifficultyLevel:
        enum:
            - beginner
            - intermediate
            - advanced

    LearningPace:
        enum:
            - slow
            - normal
            - fast

    NotificationSettings:
        email_enabled: bool
        push_enabled: bool
        types: {
            course_reminder: bool,
            assignment_due: bool,
            live_session: bool,
            achievement: bool
        }
        quiet_hours: [common.TimeRange]
