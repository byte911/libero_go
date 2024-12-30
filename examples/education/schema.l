-schema=education_platform
    version = 1.0
    name = "Online Education Platform"
    author = "Example"
    date = "2024/12/30"

-import
    types.user = "./types/user.l"
    types.course = "./types/course.l"
    types.learning = "./types/learning.l"
    types.payment = "./types/payment.l"
    types.common = "./types/common.l"

    api.course = "./api/course.l"
    api.progress = "./api/progress.l"
    api.assignment = "./api/assignment.l"
    api.live = "./api/live.l"
    api.community = "./api/community.l"
    api.analytics = "./api/analytics.l"
    api.subscription = "./api/subscription.l"
    api.notification = "./api/notification.l"
    api.achievement = "./api/achievement.l"

    states.course = "./states/course.l"
    states.live_session = "./states/live_session.l"
    states.subscription = "./states/subscription.l"

    rules.recommendation = "./rules/recommendation.l"
    rules.grading = "./rules/grading.l"
    rules.achievement = "./rules/achievement.l"

    events.user = "./events/user.l"
    events.course = "./events/course.l"
    events.system = "./events/system.l"

    security.roles = "./security/roles.l"
    security.policies = "./security/policies.l"
