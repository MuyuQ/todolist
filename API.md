# Todo API 文档

## 概述

本文档描述了四象限 Todo 应用的 RESTful API 接口。该 API 提供任务的增删改查、状态管理和四象限分类功能。

**基础 URL**: `http://localhost:8080`

**数据格式**: JSON

**认证**: 当前版本无需认证

**CORS**: 允许所有来源的跨域请求

---

## 数据模型

### Task 对象

```json
{
  "id": 1,
  "title": "完成项目文档",
  "description": "编写详细的项目说明文档",
  "quadrant": 1,
  "isCompleted": false,
  "createdAt": "2026-02-26T10:30:00",
  "orderIndex": 0
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 任务唯一标识符（只读） |
| title | string | 任务标题（必填） |
| description | string | 任务描述（可选） |
| quadrant | integer | 象限编号：1-重要紧急，2-重要不紧急，3-不重要紧急，4-不重要不紧急 |
| isCompleted | boolean | 是否已完成（只读） |
| createdAt | string | 创建时间（ISO 8601 格式，只读） |
| orderIndex | integer | 排序索引（只读） |

### 请求模型

#### TaskCreate（创建任务）

```json
{
  "title": "任务标题",
  "description": "任务描述",
  "quadrant": 4
}
```

**验证规则**:
- `title`: 必填，最小长度 1
- `description`: 可选，默认空字符串
- `quadrant`: 可选，默认 4

#### TaskUpdate（更新任务）

```json
{
  "title": "新标题",
  "description": "新描述"
}
```

**验证规则**:
- `title`: 可选
- `description`: 可选
- 至少提供一个字段

#### TaskQuadrant（移动任务）

```json
{
  "quadrant": 2
}
```

**验证规则**:
- `quadrant`: 必填，范围 1-4

#### TaskComplete（完成任务）

```json
{
  "completed": true
}
```

**验证规则**:
- `completed`: 可选，默认 true

---

## API 端点

### 1. 获取所有未完成任务

获取所有未完成的任务列表，按象限和创建时间排序。

**端点**: `GET /api/tasks`

**认证**: 不需要

**查询参数**: 无

**响应**:

**状态码**: `200 OK`

**响应体**:

```json
[
  {
    "id": 1,
    "title": "重要紧急任务",
    "description": "需要立即处理",
    "quadrant": 1,
    "isCompleted": false,
    "createdAt": "2026-02-26T10:00:00",
    "orderIndex": 0
  },
  {
    "id": 2,
    "title": "重要不紧急任务",
    "description": "计划任务",
    "quadrant": 2,
    "isCompleted": false,
    "createdAt": "2026-02-26T09:00:00",
    "orderIndex": 0
  }
]
```

**排序规则**: 
1. 按 quadrant 升序（1 → 2 → 3 → 4）
2. 同象限按 order_index 升序
3. 同索引按 created_at 降序

---

### 2. 获取已完成任务

获取所有已完成的任务列表。

**端点**: `GET /api/tasks/completed`

**认证**: 不需要

**查询参数**: 无

**响应**:

**状态码**: `200 OK`

**响应体**:

```json
[
  {
    "id": 10,
    "title": "已完成的任务",
    "description": "任务说明",
    "quadrant": 1,
    "isCompleted": true,
    "createdAt": "2026-02-25T15:30:00",
    "orderIndex": 0
  }
]
```

**排序规则**: 按 created_at 降序（最新的在前）

---

### 3. 创建新任务

创建一个新的任务。

**端点**: `POST /api/tasks`

**认证**: 不需要

**请求体**:

```json
{
  "title": "新任务标题",
  "description": "任务详细描述",
  "quadrant": 1
}
```

**响应**:

**成功状态码**: `201 Created`

**响应体**:

```json
{
  "id": 11,
  "title": "新任务标题",
  "description": "任务详细描述",
  "quadrant": 1,
  "isCompleted": false,
  "createdAt": "2026-02-26T11:30:00",
  "orderIndex": 0
}
```

**错误状态码**:

| 状态码 | 说明 |
|--------|------|
| 400 | 请求参数无效（例如 title 为空） |

---

### 4. 更新任务信息

更新任务的标题和/或描述。

**端点**: `PATCH /api/tasks/{task_id}`

**认证**: 不需要

**路径参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| task_id | integer | 任务 ID |

**请求体**:

```json
{
  "title": "更新后的标题",
  "description": "更新后的描述"
}
```

**响应**:

**成功状态码**: `200 OK`

**响应体**:

```json
{
  "id": 5,
  "title": "更新后的标题",
  "description": "更新后的描述",
  "quadrant": 2,
  "isCompleted": false,
  "createdAt": "2026-02-26T09:00:00",
  "orderIndex": 0
}
```

**错误状态码**:

| 状态码 | 说明 |
|--------|------|
| 404 | 任务不存在 |

---

### 5. 移动任务到其他象限

将任务移动到指定的象限。

**端点**: `PATCH /api/tasks/{task_id}/quadrant`

**认证**: 不需要

**路径参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| task_id | integer | 任务 ID |

**请求体**:

```json
{
  "quadrant": 3
}
```

**响应**:

**成功状态码**: `200 OK`

**响应体**:

```json
{
  "id": 5,
  "title": "任务标题",
  "description": "任务描述",
  "quadrant": 3,
  "isCompleted": false,
  "createdAt": "2026-02-26T09:00:00",
  "orderIndex": 0
}
```

**错误状态码**:

| 状态码 | 说明 |
|--------|------|
| 404 | 任务不存在 |

---

### 6. 标记任务完成状态

标记任务为已完成或未完成。

**端点**: `PATCH /api/tasks/{task_id}/complete`

**认证**: 不需要

**路径参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| task_id | integer | 任务 ID |

**请求体**:

```json
{
  "completed": true
}
```

**响应**:

**成功状态码**: `200 OK`

**响应体**:

```json
{
  "id": 5,
  "title": "任务标题",
  "description": "任务描述",
  "quadrant": 1,
  "isCompleted": true,
  "createdAt": "2026-02-26T09:00:00",
  "orderIndex": 0
}
```

**错误状态码**:

| 状态码 | 说明 |
|--------|------|
| 404 | 任务不存在 |

---

### 7. 删除任务

永久删除指定的任务。

**端点**: `DELETE /api/tasks/{task_id}`

**认证**: 不需要

**路径参数**:

| 参数 | 类型 | 说明 |
|------|------|------|
| task_id | integer | 任务 ID |

**响应**:

**成功状态码**: `200 OK`

**响应体**:

```json
{
  "ok": true
}
```

---

### 8. 清除所有已完成任务

批量删除所有已完成的任务。

**端点**: `DELETE /api/tasks/completed`

**认证**: 不需要

**查询参数**: 无

**响应**:

**成功状态码**: `200 OK`

**响应体**:

```json
{
  "ok": true
}
```

---

## 错误处理

### HTTP 状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

### 错误响应格式

```json
{
  "detail": "错误详情信息"
}
```

**FastAPI 实现示例**:

```json
{
  "detail": "Task not found"
}
```

**内置 HTTP 服务器示例**:

```json
{
  "error": "not found"
}
```

---

## 使用示例

### 示例 1: 创建并完成任务

```bash
# 1. 创建一个重要紧急的任务
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "完成项目报告",
    "description": "需要在今天下午5点前提交",
    "quadrant": 1
  }'

# 响应:
# {
#   "id": 1,
#   "title": "完成项目报告",
#   "description": "需要在今天下午5点前提交",
#   "quadrant": 1,
#   "isCompleted": false,
#   "createdAt": "2026-02-26T10:00:00",
#   "orderIndex": 0
# }

# 2. 获取所有未完成任务
curl http://localhost:8080/api/tasks

# 3. 标记任务为已完成
curl -X PATCH http://localhost:8080/api/tasks/1/complete \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'

# 4. 获取已完成任务
curl http://localhost:8080/api/tasks/completed
```

### 示例 2: 管理四象限任务

```bash
# 1. 在不同象限创建任务
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "学习新技术", "quadrant": 2}'

curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "回复紧急邮件", "quadrant": 1}'

curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "整理文件", "quadrant": 4}'

# 2. 将任务从第4象限移动到第2象限
curl -X PATCH http://localhost:8080/api/tasks/3/quadrant \
  -H "Content-Type: application/json" \
  -d '{"quadrant": 2}'

# 3. 更新任务信息
curl -X PATCH http://localhost:8080/api/tasks/3 \
  -H "Content-Type: application/json" \
  -d '{"description": "学习和实践新框架"}'
```

### 示例 3: 批量清理

```bash
# 1. 完成多个任务
curl -X PATCH http://localhost:8080/api/tasks/1/complete -H "Content-Type: application/json" -d '{}'
curl -X PATCH http://localhost:8080/api/tasks/2/complete -H "Content-Type: application/json" -d '{}'

# 2. 查看已完成任务
curl http://localhost:8080/api/tasks/completed

# 3. 清除所有已完成任务
curl -X DELETE http://localhost:8080/api/tasks/completed
```

### 示例 4: JavaScript/Fetch 示例

```javascript
// 获取所有未完成任务
async function getTasks() {
  const response = await fetch('http://localhost:8080/api/tasks');
  const tasks = await response.json();
  return tasks;
}

// 创建新任务
async function createTask(title, description, quadrant) {
  const response = await fetch('http://localhost:8080/api/tasks', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ title, description, quadrant }),
  });
  return await response.json();
}

// 标记任务完成
async function completeTask(taskId) {
  const response = await fetch(`http://localhost:8080/api/tasks/${taskId}/complete`, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ completed: true }),
  });
  return await response.json();
}

// 使用示例
(async () => {
  // 创建任务
  const task = await createTask('学习 API', '掌握 RESTful API 设计', 2);
  console.log('创建的任务:', task);

  // 获取所有任务
  const tasks = await getTasks();
  console.log('所有任务:', tasks);

  // 完成任务
  await completeTask(task.id);
  console.log('任务已完成');
})();
```

### 示例 5: Python/Requests 示例

```python
import requests

BASE_URL = "http://localhost:8080"

# 获取所有未完成任务
def get_tasks():
    response = requests.get(f"{BASE_URL}/api/tasks")
    return response.json()

# 创建新任务
def create_task(title, description="", quadrant=4):
    data = {"title": title, "description": description, "quadrant": quadrant}
    response = requests.post(f"{BASE_URL}/api/tasks", json=data)
    return response.json()

# 更新任务
def update_task(task_id, title=None, description=None):
    data = {}
    if title is not None:
        data["title"] = title
    if description is not None:
        data["description"] = description
    response = requests.patch(f"{BASE_URL}/api/tasks/{task_id}", json=data)
    return response.json()

# 移动任务到其他象限
def move_task(task_id, quadrant):
    data = {"quadrant": quadrant}
    response = requests.patch(f"{BASE_URL}/api/tasks/{task_id}/quadrant", json=data)
    return response.json()

# 完成任务
def complete_task(task_id, completed=True):
    data = {"completed": completed}
    response = requests.patch(f"{BASE_URL}/api/tasks/{task_id}/complete", json=data)
    return response.json()

# 删除任务
def delete_task(task_id):
    response = requests.delete(f"{BASE_URL}/api/tasks/{task_id}")
    return response.json()

# 清除已完成任务
def clear_completed():
    response = requests.delete(f"{BASE_URL}/api/tasks/completed")
    return response.json()

# 使用示例
if __name__ == "__main__":
    # 创建任务
    task = create_task("学习 Python", "掌握基础知识", 2)
    print(f"创建任务: {task}")

    # 获取所有任务
    tasks = get_tasks()
    print(f"所有任务: {tasks}")

    # 完成任务
    completed = complete_task(task["id"])
    print(f"完成任务: {completed}")

    # 清除已完成
    result = clear_completed()
    print(f"清除结果: {result}")
```

---

## 注意事项

1. **四象限含义**:
   - 象限 1: 重要且紧急（立即处理）
   - 象限 2: 重要但不紧急（计划处理）
   - 象限 3: 不重要但紧急（委托或快速处理）
   - 象限 4: 不重要且不紧急（尽量不做）

2. **时间格式**: 所有时间字段使用 ISO 8601 格式

3. **ID 自增**: 任务 ID 由数据库自动生成，创建后不可修改

4. **批量操作**: 当前仅支持批量清除已完成任务

5. **服务器实现**:
   - FastAPI 实现 (`server/app.py`): 推荐用于生产环境
   - 内置 HTTP 服务器 (`main.py`): 适用于开发和测试

6. **数据库**: 使用 SQLite，数据存储在 `data/tasks.db`

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| 1.0 | 2026-02-26 | 初始版本，支持完整的 CRUD 操作和四象限管理 |

---

## 联系信息

如有问题或建议，请联系项目维护者。