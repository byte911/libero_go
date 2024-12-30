-schema=course_states
    version = 1.0

-states
    CourseState:
        initial: draft
        states:
            draft:
                description: "课程正在编辑中"
            review:
                description: "课程等待审核"
            published:
                description: "课程已发布"
            archived:
                description: "课程已归档"
        transitions:
            draft -> review:
                when: course_submitted
                actions: [notify_reviewers]
            review -> draft:
                when: review_rejected
                actions: [notify_instructor]
            review -> published:
                when: review_approved
                actions: [
                    update_course_status,
                    notify_instructor,
                    index_for_search
                ]
            published -> archived:
                when: archive_requested
                actions: [
                    update_course_status,
                    notify_enrolled_students
                ]
            archived -> published:
                when: restore_requested
                actions: [
                    update_course_status,
                    notify_enrolled_students
                ]

    CourseEnrollment:
        initial: browsing
        states:
            browsing:
                description: "用户正在浏览课程"
            enrolled:
                description: "已注册但未开始"
            in_progress:
                description: "正在学习中"
            completed:
                description: "课程已完成"
            cancelled:
                description: "注册已取消"
        transitions:
            browsing -> enrolled:
                when: payment_verified or is_free_course
                actions: [
                    create_progress_record,
                    send_welcome_email,
                    add_to_learning_path
                ]
            enrolled -> in_progress:
                when: first_module_accessed
                actions: [update_progress]
            in_progress -> completed:
                when: all_modules_completed and all_assignments_submitted
                actions: [
                    issue_certificate,
                    notify_completion,
                    update_achievements
                ]
            enrolled -> cancelled:
                when: cancellation_requested
                actions: [
                    process_refund,
                    remove_from_learning_path
                ]
            in_progress -> cancelled:
                when: cancellation_requested
                actions: [
                    process_refund,
                    remove_from_learning_path,
                    archive_progress
                ]
