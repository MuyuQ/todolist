#!/usr/bin/env python3
"""
测试清空已完成任务功能的脚本
"""
import sqlite3
import os
import time
import requests
import sys

def get_database_path():
    """获取数据库文件路径"""
    return os.path.join(os.path.dirname(__file__), "data", "tasks.db")

def check_database_tasks():
    """检查数据库中的任务状态"""
    db_path = get_database_path()
    print(f"检查数据库: {db_path}")
    
    if not os.path.exists(db_path):
        print("❌ 数据库文件不存在")
        return
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # 获取所有任务
        cursor.execute("SELECT id, title, is_completed, quadrant FROM tasks ORDER BY created_at DESC")
        all_tasks = cursor.fetchall()
        
        print(f"\n📊 数据库中的所有任务总数: {len(all_tasks)}")
        
        # 获取已完成任务
        cursor.execute("SELECT id, title, is_completed, quadrant FROM tasks WHERE is_completed = 1 ORDER BY created_at DESC")
        completed_tasks = cursor.fetchall()
        
        print(f"✅ 已完成任务数量: {len(completed_tasks)}")
        if completed_tasks:
            for task in completed_tasks:
                print(f"  - ID: {task[0]}, 标题: '{task[1]}', 完成: {task[2]}, 象限: {task[3]}")
        
        # 获取未完成任务
        cursor.execute("SELECT id, title, is_completed, quadrant FROM tasks WHERE is_completed = 0 ORDER BY created_at DESC")
        pending_tasks = cursor.fetchall()
        
        print(f"⏳ 未完成任务数量: {len(pending_tasks)}")
        if pending_tasks:
            for task in pending_tasks:
                print(f"  - ID: {task[0]}, 标题: '{task[1]}', 完成: {task[2]}, 象限: {task[3]}")
        
        conn.close()
        
    except Exception as e:
        print(f"❌ 数据库查询错误: {e}")

def test_web_server():
    """测试Web服务器是否运行"""
    try:
        response = requests.get("http://localhost:8080", timeout=5)
        if response.status_code == 200:
            print("✅ Web服务器运行正常")
            return True
        else:
            print(f"❌ Web服务器返回状态码: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ 无法连接到Web服务器: {e}")
        return False

def add_test_tasks():
    """添加一些测试任务"""
    print("\n🧪 添加测试任务...")
    
    try:
        from models.task_model_optimized import TaskModel
        model = TaskModel()
        
        # 添加一些任务并标记为已完成
        ok1 = model.addTask("测试任务1", "这是一个测试任务", 1)
        ok2 = model.addTask("测试任务2", "这是另一个测试任务", 2)
        if ok1 and ok2:
            import sqlite3
            db_path = get_database_path()
            conn = sqlite3.connect(db_path)
            cur = conn.cursor()
            cur.execute("SELECT id FROM tasks WHERE title = ? ORDER BY id DESC LIMIT 1", ("测试任务1",))
            row1 = cur.fetchone()
            cur.execute("SELECT id FROM tasks WHERE title = ? ORDER BY id DESC LIMIT 1", ("测试任务2",))
            row2 = cur.fetchone()
            conn.close()
            if row1 and row2:
                model.setTaskCompleted(row1[0], True)
                model.setTaskCompleted(row2[0], True)
                print("✅ 已添加2个已完成任务的测试数据")
        
    except Exception as e:
        print(f"❌ 添加测试任务失败: {e}")

def test_clear_completed_functionality():
    """测试清空已完成任务功能"""
    print("\n🔄 测试清空已完成任务功能...")
    
    try:
        from models.task_model_optimized import TaskModel
        from controllers.task_controller_optimized import TaskController
        
        model = TaskModel()
        controller = TaskController(model)
        
        # 检查清空前的状态
        completed_before = controller.getCompletedTasks()
        print(f"清空前已完成任务数量: {len(completed_before)}")
        for task in completed_before:
            print(f"  - 任务ID: {task['taskId']}, 标题: '{task['taskTitle']}'")
        
        # 执行清空操作
        print("\n🧹 执行清空操作...")
        controller.clearCompletedTasks()
        
        # 检查清空后的状态
        completed_after = controller.getCompletedTasks()
        print(f"清空后已完成任务数量: {len(completed_after)}")
        
        if len(completed_after) == 0:
            print("✅ 清空功能正常工作")
            return True
        else:
            print("❌ 清空功能未正常工作，仍有已完成任务:")
            for task in completed_after:
                print(f"  - 任务ID: {task['taskId']}, 标题: '{task['taskTitle']}'")
            return False
        
    except Exception as e:
        print(f"❌ 测试清空功能时发生错误: {e}")
        return False

def main():
    """主函数"""
    print("=" * 60)
    print("🧪 清空已完成任务功能测试")
    print("=" * 60)
    
    # 1. 检查数据库当前状态
    check_database_tasks()
    
    # 2. 测试Web服务器
    print("\n🌐 检查Web服务器状态...")
    if not test_web_server():
        print("请确保应用正在运行: python main.py")
        return
    
    # 3. 添加测试数据
    add_test_tasks()
    
    # 4. 检查添加测试数据后的状态
    print("\n📊 添加测试数据后检查...")
    check_database_tasks()
    
    # 5. 测试清空功能
    success = test_clear_completed_functionality()
    
    # 6. 最终检查
    print("\n📊 最终数据库状态检查...")
    check_database_tasks()
    
    print("\n" + "=" * 60)
    if success:
        print("🎉 清空功能测试成功！")
    else:
        print("❌ 清空功能测试失败！")
    print("=" * 60)

if __name__ == "__main__":
    main()