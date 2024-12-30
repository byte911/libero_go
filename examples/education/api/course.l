-schema=course_api
    version = 1.0

-import
    common = "../types/common.l"
    course = "../types/course.l"
    user = "../types/user.l"

-api
    CourseAPI:
        CreateCourse:
            method: POST
            path: /courses
            input: course.CreateCourseRequest
            output: common.Response[course.Course]
            auth: required
            roles: [instructor, admin]
            rate_limit: 100/hour

        UpdateCourse:
            method: PUT
            path: /courses/{id}
            input: course.UpdateCourseRequest
            output: common.Response[course.Course]
            auth: required
            roles: [instructor, admin]

        GetCourse:
            method: GET
            path: /courses/{id}
            output: common.Response[course.CourseDetails]
            cache: {
                duration: 300,
                vary_by: [user_id, role]
            }

        ListCourses:
            method: GET
            path: /courses
            input: course.ListCoursesRequest
            output: common.Response[common.PageResponse[course.Course]]
            cache: {duration: 60}

        # 课程内容管理
        AddModule:
            method: POST
            path: /courses/{id}/modules
            input: course.Module
            output: common.Response[course.Module]
            auth: required
            roles: [instructor, admin]

        UpdateModule:
            method: PUT
            path: /courses/{id}/modules/{module_id}
            input: course.UpdateModuleRequest
            output: common.Response[course.Module]
            auth: required
            roles: [instructor, admin]

        ReorderModules:
            method: POST
            path: /courses/{id}/modules/reorder
            input: course.ReorderModulesRequest
            output: common.Response[bool]
            auth: required
            roles: [instructor, admin]

        # 课程注册
        EnrollCourse:
            method: POST
            path: /courses/{id}/enroll
            input: course.EnrollmentRequest
            output: common.Response[course.Enrollment]
            auth: required
            rate_limit: 10/minute
