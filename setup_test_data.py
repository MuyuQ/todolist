#!/usr/bin/env python3
"""
设置测试数据的脚本
"""
import sys
import os

# 添加项目根目录到Python路径
sys.path.insert(0, os.path.dirname(__file__))

from models.task_model_optimized import TaskModel
from controllers.task_controller_optimized import TaskController

def main():
    print("🧪 设置测试数据...")
    
    # 创建模型和控制器
    model = TaskModel()
    controller = TaskController(model)
    
    # 清空所有已完成任务
    controller.clearCompletedTasks()
    
    # 添加一些测试任务
    print("📝 添加测试任务...")
    ok1 = model.addTask("Test Task 1", "This is first test task", 1)
    ok2 = model.addTask("Test Task 2", "This is second test task", 2)
    ok3 = model.addTask("Test Task 3", "This is third test task", 3)
    ok4 = model.addTask("Active Task 1", "This is an active task", 4)
    print(f"添加任务完成: {ok1}, {ok2}, {ok3}, {ok4}")
    
    # 标记前三个任务为已完成
    if ok1 and ok2 and ok3:
        print("🏁 标记任务为已完成...")
        import sqlite3
        db_path = os.path.join(os.path.dirname(__file__), "data", "tasks.db")
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        cur.execute("SELECT id FROM tasks WHERE title = ? ORDER BY id DESC LIMIT 1", ("Test Task 1",))
        r1 = cur.fetchone()
        cur.execute("SELECT id FROM tasks WHERE title = ? ORDER BY id DESC LIMIT 1", ("Test Task 2",))
        r2 = cur.fetchone()
        cur.execute("SELECT id FROM tasks WHERE title = ? ORDER BY id DESC LIMIT 1", ("Test Task 3",))
        r3 = cur.fetchone()
        conn.close()
        if r1 and r2 and r3:
            model.setTaskCompleted(r1[0], True)
            model.setTaskCompleted(r2[0], True)
            model.setTaskCompleted(r3[0], True)
        
        print("✅ 测试数据设置完成")
        
        # 验证结果
        completed = controller.getCompletedTasks()
        print(f"📊 已完成任务数量: {len(completed)}")
        for task in completed:
            print(f"  - {task['taskTitle']} (ID: {task['taskId']})")
        
        active = model.getAllTasks()
        print(f"📊 未完成任务数量: {len(active)}")
        for task in active:
            print(f"  - {task['title']} (ID: {task['id']})")
            
        return True
    else:
        print("❌ 添加任务失败")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)