#!/usr/bin/env python3
"""
精确测试清空已完成任务功能的脚本
专注于验证UI刷新问题
"""
import sqlite3
import os
import time
import requests
import sys

def get_database_path():
    """获取数据库文件路径"""
    return os.path.join(os.path.dirname(__file__), "data", "tasks.db")

def create_test_data():
    """创建测试数据"""
    print("🧪 创建测试数据...")
    
    try:
        from models.task_model_optimized import TaskModel
        from controllers.task_controller_optimized import TaskController
        
        model = TaskModel()
        controller = TaskController(model)
        
        # 先清理数据库
        controller.clearCompletedTasks()
        
        # 添加任务并标记为已完成
        ok1 = model.addTask("测试任务A", "这是第一个测试任务", 1)
        ok2 = model.addTask("测试任务B", "这是第二个测试任务", 2) 
        ok3 = model.addTask("测试任务C", "这是第三个测试任务", 3)
        if ok1 and ok2 and ok3:
            import sqlite3
            db_path = get_database_path()
            conn = sqlite3.connect(db_path)
            cur = conn.cursor()
            cur.execute("SELECT id FROM tasks WHERE title = ? ORDER BY id DESC LIMIT 1", ("测试任务A",))
            r1 = cur.fetchone()
            cur.execute("SELECT id FROM tasks WHERE title = ? ORDER BY id DESC LIMIT 1", ("测试任务B",))
            r2 = cur.fetchone()
            conn.close()
            if r1 and r2:
                model.setTaskCompleted(r1[0], True)
                model.setTaskCompleted(r2[0], True)
                print("✅ 已创建测试数据：2个已完成任务，1个未完成任务")
                return True
        else:
            print("❌ 添加任务失败")
            return False
        
    except Exception as e:
        print(f"❌ 创建测试数据失败: {e}")
        return False

def check_database_state():
    """检查数据库状态"""
    db_path = get_database_path()
    
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # 获取所有任务
        cursor.execute("SELECT id, title, is_completed, quadrant FROM tasks ORDER BY id")
        all_tasks = cursor.fetchall()
        
        print(f"\n📊 数据库状态检查:")
        print(f"任务总数: {len(all_tasks)}")
        
        for task in all_tasks:
            status = "✅已完成" if task[2] == 1 else "⏳未完成"
            print(f"  ID: {task[0]}, 标题: '{task[1]}', 状态: {status}, 象限: {task[3]}")
        
        # 特别检查已完成任务
        cursor.execute("SELECT COUNT(*) FROM tasks WHERE is_completed = 1")
        completed_count = cursor.fetchone()[0]
        
        print(f"✅ 已完成任务数量: {completed_count}")
        
        conn.close()
        return completed_count
        
    except Exception as e:
        print(f"❌ 数据库检查失败: {e}")
        return -1

def test_completed_tasks_api():
    """测试已完成任务API"""
    print("\n🔍 测试已完成任务API...")
    
    try:
        from models.task_model_optimized import TaskModel
        from controllers.task_controller_optimized import TaskController
        
        model = TaskModel()
        controller = TaskController(model)
        
        # 获取已完成任务
        completed_tasks = controller.getCompletedTasks()
        print(f"getCompletedTasks()返回的任务数量: {len(completed_tasks)}")
        
        for task in completed_tasks:
            print(f"  API返回 - ID: {task['taskId']}, 标题: '{task['taskTitle']}', 完成状态: {task['isCompleted']}")
        
        return completed_tasks
        
    except Exception as e:
        print(f"❌ API测试失败: {e}")
        return []

def test_clear_function():
    """测试清空功能"""
    print("\n🧹 测试清空功能...")
    
    try:
        from models.task_model_optimized import TaskModel
        from controllers.task_controller_optimized import TaskController
        
        model = TaskModel()
        controller = TaskController(model)
        
        # 执行清空操作
        print("执行 taskController.clearCompletedTasks()...")
        controller.clearCompletedTasks()
        
        # 检查清空后的状态
        completed_after = controller.getCompletedTasks()
        db_count = check_database_state()
        
        print(f"\n清空后结果:")
        print(f"API返回已完成任务数量: {len(completed_after)}")
        print(f"数据库中已完成任务数量: {db_count}")
        
        if len(completed_after) == 0 and db_count == 0:
            print("✅ 清空功能正常工作")
            return True
        else:
            print("❌ 清空功能存在问题")
            return False
        
    except Exception as e:
        print(f"❌ 清空测试失败: {e}")
        return False

def simulate_ui_refresh():
    """模拟UI刷新测试"""
    print("\n🖥️  模拟UI刷新流程...")
    
    try:
        from models.task_model_optimized import TaskModel
        from controllers.task_controller_optimized import TaskController
        
        model = TaskModel()
        controller = TaskController(model)
        
        print("1. 初始状态 - 获取已完成任务")
        initial_tasks = controller.getCompletedTasks()
        print(f"   初始已完成任务数量: {len(initial_tasks)}")
        
        print("2. 模拟清空按钮点击事件")
        # 清空按钮的点击事件会调用这两个函数
        controller.clearCompletedTasks()  # 调用1
        # 在真实UI中，这里会调用 refreshCompletedTasksList()
        # 模拟刷新函数
        refreshed_tasks = controller.getCompletedTasks()  # 调用2
        print(f"   刷新后已完成任务数量: {len(refreshed_tasks)}")
        
        if len(initial_tasks) > 0 and len(refreshed_tasks) == 0:
            print("✅ UI刷新模拟成功")
            return True
        else:
            print("❌ UI刷新模拟失败")
            return False
        
    except Exception as e:
        print(f"❌ UI刷新模拟失败: {e}")
        return False

def main():
    """主函数"""
    print("=" * 60)
    print("🔍 精确测试清空已完成任务功能")
    print("=" * 60)
    
    # 1. 创建测试数据
    if not create_test_data():
        print("❌ 测试数据创建失败，退出测试")
        return
    
    # 2. 检查初始数据库状态
    initial_db_count = check_database_state()
    initial_api_result = test_completed_tasks_api()
    
    # 3. 测试清空功能
    clear_success = test_clear_function()
    
    # 4. 模拟UI刷新流程
    ui_refresh_success = simulate_ui_refresh()
    
    # 5. 最终总结
    print("\n" + "=" * 60)
    print("📋 测试总结:")
    print(f"  数据库初始状态: {initial_db_count} 个已完成任务")
    print(f"  API初始结果: {len(initial_api_result)} 个已完成任务")
    print(f"  清空功能测试: {'✅ 通过' if clear_success else '❌ 失败'}")
    print(f"  UI刷新模拟: {'✅ 通过' if ui_refresh_success else '❌ 失败'}")
    
    if clear_success and ui_refresh_success:
        print("\n🎉 所有测试通过！清空功能正常工作。")
        print("如果UI中仍显示任务，可能是前端缓存或绑定问题。")
    else:
        print("\n❌ 测试发现问题，需要进一步调试。")
    print("=" * 60)

if __name__ == "__main__":
    main()