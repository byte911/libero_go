# 在线教育平台

## 项目结构
```
education/
├── README.md                 # 项目说明
├── schema.l                  # 项目配置
├── types/                    # 类型定义
│   ├── user.l               # 用户相关类型
│   ├── course.l             # 课程相关类型
│   ├── learning.l           # 学习相关类型
│   ├── payment.l            # 支付相关类型
│   └── common.l             # 通用类型
├── api/                      # API 定义
│   ├── course.l             # 课程管理接口
│   ├── progress.l           # 学习进度接口
│   ├── assignment.l         # 作业和评估接口
│   ├── live.l               # 直播课程接口
│   ├── community.l          # 社区互动接口
│   ├── analytics.l          # 分析报告接口
│   ├── subscription.l       # 订阅支付接口
│   ├── notification.l       # 通知接口
│   └── achievement.l        # 成就接口
├── states/                   # 状态机定义
│   ├── course.l             # 课程状态
│   ├── live_session.l       # 直播课程状态
│   └── subscription.l       # 订阅状态
├── rules/                   # 业务规则
│   ├── recommendation.l     # 推荐规则
│   ├── grading.l           # 评分规则
│   └── achievement.l       # 成就规则
├── events/                  # 事件定义
│   ├── user.l              # 用户事件
│   ├── course.l            # 课程事件
│   └── system.l            # 系统事件
└── security/               # 安全策略
    ├── roles.l             # 角色定义
    └── policies.l          # 访问策略
```
