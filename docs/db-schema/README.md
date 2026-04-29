# 数据库表结构

> 记录所有表的字段定义、约束、枚举、迁移历史。

---

## 约定

- 主键：`id`，类型 `String(36)`，内容 UUID4
- 时间戳：`created_at` / `updated_at`，类型 `DateTime(timezone=True)`，`server_default=CURRENT_TIMESTAMP`
- 枚举：值用全大写存储（`ADMIN`），SQLAlchemy `SAEnum` 自动映射

## users

| 字段 | 类型 | 约束 | 说明 |
|---|---|---|---|
| id | String(36) | PK | UUID4 |
| phone | String(20) | NOT NULL, UNIQUE, INDEX | 手机号 |
| name | String(100) | NOT NULL | 显示名 |
| password_hash | String(255) | NOT NULL | bcrypt 哈希 |
| role | Enum(userrole) | NOT NULL | `ADMIN` / `USER` |
| created_at | DateTime | DEFAULT CURRENT_TIMESTAMP | |
| updated_at | DateTime | DEFAULT CURRENT_TIMESTAMP | |

**索引**：`ix_users_id`（id）、`ix_users_phone`（phone, UNIQUE）。

## 迁移历史

| Revision | 说明 | 文件 |
|---|---|---|
| 20260101000000 | 初始 users 表 | `alembic/versions/20260101000000_initial_users.py` |

### 新增迁移

```bash
cd back_end && source venv/bin/activate
alembic revision --autogenerate -m "描述"
# 人工审查生成的文件
alembic upgrade head
```
