# Libero 语法规则

## 1. 基本结构

文件由多个段落(section)组成，每个段落以 `-` 开头，如：
```
-section_name
    content
```

## 2. Schema 定义

每个文件必须以 schema 定义开始：
```
-schema=name
    version = string
    name    = string
    author  = string
    date    = string
    copyright = string (optional)
```

## 3. 类型定义

使用 `-types` 定义数据类型：
```
-types
    TypeName:
        field_name: type_definition
        ...
```

### 类型规则
- 基本类型：
  - `string`: 字符串
  - `int`: 整数
  - `float`: 浮点数
  - `decimal`: 精确小数
  - `bool`: 布尔值
  - `timestamp`: 时间戳
  - `date`: 日期
  - `[Type]`: 数组类型
  - `{key: Type}`: 映射类型

- 约束定义：
```
constraints:
    - expression
    - field > value
    - field in [value1, value2]
```

- 计算字段：
```
computed:
    field = expression
```

## 4. 状态机定义

```
-states
    StateName:
        initial: state_name
        states:
            state1
            state2
            ...
        transitions:
            state1 -> state2:
                when: condition
                actions: [action1, action2]
```

## 5. API 定义

```
-api
    EndpointName:
        method: HTTP_METHOD
        path: url_path
        input: InputType
        output: OutputType | {success: Type, error: Type}
        auth: required | optional | none
        rate_limit: limit_expression
```

## 6. 业务规则

```
-rules
    RuleName:
        when: condition_expression
        validate:
            - condition1
            - condition2
        actions:
            - action1
            - action2
```

## 7. 事件定义

```
-events
    EventName:
        producer: ServiceName
        payload: PayloadType
        subscribers:
            - Service1
            - Service2
```

## 8. 数据转换

```
-transformers
    TransformerName:
        input: InputType
        output: OutputType
        mapping:
            target_field = expression
```

## 9. 表达式语法

表达式支持以下操作：
- 算术运算: `+`, `-`, `*`, `/`, `%`
- 比较运算: `==`, `!=`, `>`, `<`, `>=`, `<=`
- 逻辑运算: `and`, `or`, `not`
- 函数调用: `function_name(args)`
- 字段访问: `object.field`
- 数组操作:
  - 索引: `array[index]`
  - 映射: `map(array, item => expression)`
  - 过滤: `filter(array, item => condition)`
  - 聚合: `reduce(array, (acc, item) => expression, initial)`

## 10. 内置函数

基础函数：
- `len(value)`: 获取长度
- `sum(array)`: 求和
- `avg(array)`: 平均值
- `min(array)`: 最小值
- `max(array)`: 最大值
- `now()`: 当前时间
- `uuid()`: 生成 UUID

字符串函数：
- `concat(str1, str2)`: 字符串连接
- `upper(str)`: 转大写
- `lower(str)`: 转小写
- `trim(str)`: 去除空白

类型转换：
- `string(value)`: 转字符串
- `int(value)`: 转整数
- `float(value)`: 转浮点数
- `bool(value)`: 转布尔值

## 11. 注释

支持两种注释方式：
```
# 单行注释

/*
多行注释
*/
```

## 12. 导入和模块化

```
-import
    module_name = "path/to/module"
    types_only = "path/to/types"
```

引用导入的内容：
```
module_name.TypeName
module_name.function_name()
```
