import sqlite3
import os

# 数据库路径
db_path = os.path.join(os.path.dirname(__file__), "data", "tasks.db")

print(f"检查数据库: {db_path}")
print("=" * 50)

try:
    # 连接数据库
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 查询任务表结构
    cursor.execute("PRAGMA table_info(tasks)")
    columns = cursor.fetchall()
    print("表结构:")
    for column in columns:
        print(f"  - {column[1]} ({column[2]})")
    
    print("\n任务数据:")
    # 查询前10条任务数据
    cursor.execute("SELECT id, title, quadrant, is_completed FROM tasks ORDER BY id DESC LIMIT 10")
    tasks = cursor.fetchall()
    
    if not tasks:
        print("  数据库中没有任务")
    else:
        for task in tasks:
            # 打印任务数据，包括标题字段的类型和内容
            title_value = task[1]
            print(f"  ID: {task[0]}, 标题: '{title_value}' (类型: {type(title_value).__name__}), 象限: {task[2]}, 完成: {bool(task[3])}")
            
            # 特别检查标题是否为空
            if title_value is None or title_value.strip() == "":
                print("    ⚠️  标题为空或None")
    
finally:
    conn.close()