-schema=education_platform
    version = 1.0
    name = "Online Education Platform"
    author = "Example"
    date = "2024/12/30"

# 核心数据类型定义
-types
    # 用户相关
    User:
        id: string
        name: string
        email: string
        role: UserRole
        preferences: UserPreferences
        learning_path: [CourseId]
        achievements: [Achievement]
        created_at: timestamp
        constraints:
            - email matches "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"

    UserPreferences:
        preferred_categories: [string]
        difficulty_level: enum(beginner, intermediate, advanced)
        learning_pace: enum(slow, normal, fast)
        notification_settings: NotificationSettings

    NotificationSettings:
        email_enabled: bool
        push_enabled: bool
        types: {
            course_reminder: bool,
            assignment_due: bool,
            live_session: bool,
            achievement: bool
        }

    # 课程相关
    Course:
        id: CourseId
        title: string
        description: string
        category: [string]
        difficulty: enum(beginner, intermediate, advanced)
        prerequisites: [CourseId]
        modules: [Module]
        instructor: UserId
        price: decimal
        rating: float
        enrollment_count: int
        created_at: timestamp
        status: enum(draft, published, archived)
        constraints:
            - rating between 0 and 5
            - len(modules) > 0
        computed:
            duration = sum(modules.duration)
            is_premium = price > 0

    Module:
        id: string
        title: string
        content_type: enum(video, article, quiz, assignment)
        content: Content
        duration: int
        order: int
        prerequisites: [string]

    Content:
        video_url?: string
        article_content?: string
        quiz?: Quiz
        assignment?: Assignment

    Quiz:
        questions: [Question]
        passing_score: int
        time_limit: int
        attempts_allowed: int

    Question:
        text: string
        type: enum(multiple_choice, true_false, open_ended)
        options?: [string]
        correct_answer: string
        points: int

    Assignment:
        description: string
        deadline: timestamp
        rubric: [RubricItem]
        max_score: int
        submission_type: enum(text, file, link)

    RubricItem:
        criterion: string
        weight: float
        levels: [ScoringLevel]

    ScoringLevel:
        score: int
        description: string

    # 学习进度
    Progress:
        user_id: UserId
        course_id: CourseId
        modules_completed: [string]
        current_module: string
        quiz_scores: {string: int}
        assignment_scores: {string: int}
        last_accessed: timestamp
        computed:
            completion_percentage = (len(modules_completed) / len(course.modules)) * 100
            average_score = avg(values(quiz_scores))

    # 订阅和支付
    Subscription:
        user_id: UserId
        plan: SubscriptionPlan
        status: enum(active, cancelled, expired)
        start_date: timestamp
        end_date: timestamp
        payment_method: PaymentMethod
        auto_renew: bool

    PaymentMethod:
        type: enum(credit_card, paypal, bank_transfer)
        details: PaymentDetails
        is_default: bool

    # 直播课程
    LiveSession:
        id: string
        course_id: CourseId
        instructor: UserId
        title: string
        description: string
        scheduled_time: timestamp
        duration: int
        max_participants: int
        current_participants: int
        status: enum(scheduled, live, ended)
        chat_enabled: bool
        recording_url?: string
        constraints:
            - current_participants <= max_participants

# API 定义
-api
    # 课程管理接口
    CourseAPI:
        CreateCourse:
            method: POST
            path: /courses
            input: Course
            output: {success: Course, error: Error}
            auth: required
            roles: [instructor, admin]

        UpdateCourse:
            method: PUT
            path: /courses/{id}
            input: {
                title?: string,
                description?: string,
                category?: [string],
                difficulty?: string,
                price?: decimal,
                status?: string
            }
            output: {success: Course, error: Error}
            auth: required
            roles: [instructor, admin]

        GetCourse:
            method: GET
            path: /courses/{id}
            output: {
                course: Course,
                instructor_info: UserProfile,
                enrollment_stats: EnrollmentStats,
                reviews: [Review],
                related_courses: [Course]
            }
            cache: {
                duration: 300,
                vary_by: [user_id, role]
            }

        ListCourses:
            method: GET
            path: /courses
            input: {
                category?: [string],
                difficulty?: string,
                price_range?: {min: decimal, max: decimal},
                instructor_id?: string,
                status?: string,
                sort_by?: string,
                page: int,
                page_size: int
            }
            output: {
                courses: [Course],
                total: int,
                filters: AvailableFilters
            }
            cache: {duration: 60}

        EnrollCourse:
            method: POST
            path: /courses/{id}/enroll
            input: {
                user_id: string,
                payment_method_id?: string,
                coupon_code?: string
            }
            output: {
                success: bool,
                enrollment: Enrollment,
                payment_status?: PaymentStatus,
                error: Error
            }
            auth: required
            rate_limit: 10/minute

        # 课程内容管理
        AddModule:
            method: POST
            path: /courses/{id}/modules
            input: Module
            output: {success: Module, error: Error}
            auth: required
            roles: [instructor, admin]

        UpdateModule:
            method: PUT
            path: /courses/{id}/modules/{module_id}
            input: {
                title?: string,
                content?: Content,
                duration?: int,
                order?: int
            }
            output: {success: Module, error: Error}
            auth: required
            roles: [instructor, admin]

        ReorderModules:
            method: POST
            path: /courses/{id}/modules/reorder
            input: {module_orders: [{id: string, order: int}]}
            output: {success: bool, error: Error}
            auth: required
            roles: [instructor, admin]

    # 学习进度接口
    ProgressAPI:
        GetProgress:
            method: GET
            path: /courses/{course_id}/progress
            output: {
                overall_progress: Progress,
                module_progress: [ModuleProgress],
                quiz_results: [QuizResult],
                assignment_status: [AssignmentStatus],
                recommendations: [LearningRecommendation]
            }
            auth: required

        UpdateProgress:
            method: POST
            path: /courses/{course_id}/progress
            input: {
                module_id: string,
                status: enum(started, completed),
                time_spent: int,
                notes?: string
            }
            output: {
                updated_progress: Progress,
                unlocked_achievements?: [Achievement],
                next_steps: [LearningStep]
            }
            auth: required

        GetLearningPath:
            method: GET
            path: /users/{user_id}/learning-path
            output: {
                current_courses: [CourseProgress],
                recommended_next: [Course],
                learning_stats: LearningStats,
                certificates: [Certificate]
            }
            auth: required

    # 作业和评估接口
    AssignmentAPI:
        SubmitAssignment:
            method: POST
            path: /courses/{course_id}/assignments/{assignment_id}/submit
            input: {
                content: string,
                attachments?: [File],
                time_spent: int,
                draft?: bool
            }
            output: {
                submission: AssignmentSubmission,
                auto_feedback?: AssignmentFeedback,
                next_steps: [LearningStep]
            }
            auth: required

        GradeAssignment:
            method: POST
            path: /courses/{course_id}/assignments/{assignment_id}/grade
            input: {
                student_id: string,
                scores: [RubricScore],
                feedback: string,
                status: enum(pass, fail, revision_needed)
            }
            output: {success: bool, error: Error}
            auth: required
            roles: [instructor, teaching_assistant]

        RequestReview:
            method: POST
            path: /assignments/{assignment_id}/review-request
            input: {
                reason: string,
                specific_points: [string]
            }
            output: {
                review_request: ReviewRequest,
                estimated_response_time: int
            }
            auth: required

    # 直播课程接口
    LiveSessionAPI:
        ScheduleSession:
            method: POST
            path: /courses/{course_id}/live-sessions
            input: {
                title: string,
                description: string,
                scheduled_time: timestamp,
                duration: int,
                max_participants: int,
                settings: LiveSessionSettings
            }
            output: {
                session: LiveSession,
                calendar_event: CalendarEvent
            }
            auth: required
            roles: [instructor, admin]

        StartSession:
            method: POST
            path: /live-sessions/{id}/start
            input: {
                instructor_id: string,
                stream_settings: StreamSettings
            }
            output: {
                stream_url: string,
                chat_token: string,
                participant_list: [Participant]
            }
            auth: required
            roles: [instructor]

        JoinSession:
            method: POST
            path: /live-sessions/{id}/join
            input: {
                user_id: string,
                device_info: DeviceInfo
            }
            output: {
                session_token: string,
                chat_token: string,
                stream_url: string,
                materials: [SessionMaterial]
            }
            auth: required

        InteractInSession:
            method: POST
            path: /live-sessions/{id}/interact
            input: {
                type: enum(question, poll_response, reaction),
                content: string,
                timestamp: int
            }
            output: {
                interaction_id: string,
                status: string
            }
            auth: required
            rate_limit: 20/minute

    # 互动和社区接口
    CommunityAPI:
        CreateDiscussion:
            method: POST
            path: /courses/{course_id}/discussions
            input: {
                title: string,
                content: string,
                tags: [string],
                attachments?: [File]
            }
            output: {
                discussion: Discussion,
                notifications_sent: int
            }
            auth: required

        AnswerQuestion:
            method: POST
            path: /discussions/{discussion_id}/answer
            input: {
                content: string,
                references?: [Reference],
                is_instructor_response: bool
            }
            output: {
                answer: Answer,
                badges_earned?: [Badge]
            }
            auth: required

        CreateStudyGroup:
            method: POST
            path: /courses/{course_id}/study-groups
            input: {
                name: string,
                description: string,
                max_members: int,
                schedule: [StudySession],
                goals: [string]
            }
            output: {
                group: StudyGroup,
                invite_link: string
            }
            auth: required

    # 分析和报告接口
    AnalyticsAPI:
        GetCourseAnalytics:
            method: GET
            path: /courses/{course_id}/analytics
            input: {
                date_range: DateRange,
                metrics: [string],
                segment_by?: string
            }
            output: {
                enrollment_trends: EnrollmentTrends,
                completion_rates: CompletionRates,
                engagement_metrics: EngagementMetrics,
                revenue_data: RevenueData,
                user_feedback: FeedbackAnalytics
            }
            auth: required
            roles: [instructor, admin]

        GetLearnerAnalytics:
            method: GET
            path: /users/{user_id}/analytics
            output: {
                learning_patterns: LearningPatterns,
                skill_progress: [SkillProgress],
                time_distribution: TimeDistribution,
                strength_weaknesses: StrengthWeakness,
                improvement_suggestions: [Suggestion]
            }
            auth: required

        GenerateReport:
            method: POST
            path: /analytics/reports
            input: {
                report_type: string,
                parameters: ReportParameters,
                format: enum(pdf, excel, json)
            }
            output: {
                report_url: string,
                expiry: timestamp
            }
            auth: required
            roles: [instructor, admin]

    # 订阅和支付接口
    SubscriptionAPI:
        CreateSubscription:
            method: POST
            path: /subscriptions
            input: {
                user_id: string,
                plan_id: string,
                payment_method: PaymentMethod,
                coupon_code?: string,
                start_date: timestamp
            }
            output: {
                subscription: Subscription,
                payment_status: PaymentStatus,
                access_details: AccessDetails
            }
            auth: required

        UpdateSubscription:
            method: PUT
            path: /subscriptions/{id}
            input: {
                plan_id?: string,
                auto_renew?: bool,
                payment_method?: PaymentMethod
            }
            output: {
                updated_subscription: Subscription,
                price_change?: PriceChange
            }
            auth: required

        CancelSubscription:
            method: POST
            path: /subscriptions/{id}/cancel
            input: {
                reason: string,
                feedback?: string,
                end_immediately: bool
            }
            output: {
                cancellation: CancellationDetails,
                refund_info?: RefundInfo
            }
            auth: required

    # 通知接口
    NotificationAPI:
        GetNotifications:
            method: GET
            path: /users/{user_id}/notifications
            input: {
                type?: [string],
                status?: string,
                page: int,
                page_size: int
            }
            output: {
                notifications: [Notification],
                unread_count: int
            }
            auth: required

        UpdateNotificationPreferences:
            method: PUT
            path: /users/{user_id}/notification-preferences
            input: {
                email_preferences: EmailPreferences,
                push_preferences: PushPreferences,
                quiet_hours: [TimeRange]
            }
            output: {success: bool, error: Error}
            auth: required

    # 成就和游戏化接口
    AchievementAPI:
        GetAchievements:
            method: GET
            path: /users/{user_id}/achievements
            output: {
                earned: [Achievement],
                in_progress: [AchievementProgress],
                recommendations: [AchievementRecommendation]
            }
            auth: required

        ClaimReward:
            method: POST
            path: /achievements/{achievement_id}/claim
            input: {
                user_id: string,
                reward_choice?: string
            }
            output: {
                reward: Reward,
                new_achievements?: [Achievement]
            }
            auth: required

# 状态机定义
-states
    CourseEnrollment:
        initial: browsing
        states:
            browsing
            enrolled
            in_progress
            completed
            cancelled
        transitions:
            browsing -> enrolled:
                when: payment_verified or is_free_course
                actions: [create_progress_record, send_welcome_email]
            enrolled -> in_progress:
                when: first_module_accessed
                actions: [update_progress]
            in_progress -> completed:
                when: all_modules_completed and all_assignments_submitted
                actions: [issue_certificate, notify_completion]

    LiveSessionState:
        initial: scheduled
        states:
            scheduled
            preparing
            live
            ended
        transitions:
            scheduled -> preparing:
                when: time_before(session.scheduled_time, minutes=15)
                actions: [send_reminder_notifications]
            preparing -> live:
                when: instructor_started and time_reached(session.scheduled_time)
                actions: [start_streaming, enable_chat]
            live -> ended:
                when: instructor_ended or time_exceeded(session.duration)
                actions: [stop_streaming, save_recording]

# 业务规则
-rules
    CourseRecommendation:
        when: user.requests_recommendations
        actions:
            recommended_courses = filter(all_courses, course =>
                course.difficulty == user.preferences.difficulty_level and
                course.category in user.preferences.preferred_categories and
                not (course.id in user.completed_courses)
            )
            sorted_courses = sort(recommended_courses, course =>
                calculate_relevance_score(course, user.learning_history)
            )
            return limit(sorted_courses, 10)

    AssignmentGrading:
        when: submission_received
        validate:
            - submission.timestamp <= assignment.deadline
            - submission.type == assignment.submission_type
        actions:
            if assignment.auto_gradeable:
                score = auto_grade(submission, assignment.rubric)
            else:
                create_grading_task(submission, assignment.instructor)
            update_progress(user.id, course.id, assignment.id, score)

    AchievementUnlock:
        when: progress_updated
        actions:
            achievements = calculate_achievements(user.progress)
            new_achievements = filter(achievements, a => not (a in user.achievements))
            if len(new_achievements) > 0:
                update_user_achievements(user.id, new_achievements)
                send_achievement_notifications(user.id, new_achievements)

# 数据转换
-transformers
    ProgressToAnalytics:
        input: Progress
        output: AnalyticsData
        mapping:
            user_metrics = {
                completion_rate: input.completion_percentage,
                avg_quiz_score: input.average_score,
                time_spent: calculate_time_spent(input.module_access_logs),
                engagement_score: calculate_engagement(
                    input.quiz_attempts,
                    input.assignment_submissions,
                    input.forum_posts
                )
            }
            learning_patterns = analyze_learning_patterns(
                input.module_access_logs,
                input.quiz_scores,
                input.assignment_scores
            )

# 事件定义
-events
    UserEngagement:
        producer: LearningService
        payload: {
            user_id: string,
            course_id: string,
            action_type: string,
            timestamp: timestamp,
            metadata: object
        }
        subscribers:
            - AnalyticsService
            - RecommendationService
            - NotificationService

    AchievementUnlocked:
        producer: AchievementService
        payload: {
            user_id: string,
            achievement_id: string,
            timestamp: timestamp
        }
        subscribers:
            - NotificationService
            - UserProfileService
            - GamificationService

# 安全策略
-security
    Policies:
        CourseAccess:
            resources: ["/courses/**", "/live-sessions/**"]
            roles: [student, instructor, admin]
            rules:
                student: ["read", "enroll"]
                instructor: ["read", "write", "manage_own"]
                admin: ["read", "write", "manage_all"]

        ContentAccess:
            resources: ["/content/**"]
            rules:
                premium_content:
                    requires: active_subscription
                free_content:
                    requires: authenticated
