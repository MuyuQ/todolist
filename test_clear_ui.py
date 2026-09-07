#!/usr/bin/env python3
"""
测试清空功能的脚本
"""

import sys
import os
import time

# 添加项目根目录到Python路径
sys.path.insert(0, os.path.dirname(__file__))

from models.task_model_optimized import TaskModel
from controllers.task_controller_optimized import TaskController


def test_clear_functionality():
    """test_clear_functionality 功能说明。"""
    print("🔍 测试清空功能...")

    # 创建模型和控制器
    model = TaskModel()
    controller = TaskController(model)

    # 检查初始状态
    print("\n📊 初始状态:")
    completed_before = controller.getCompletedTasks()
    print(f"已完成任务数量: {len(completed_before)}")
    for task in completed_before:
        print(f"  - {task['taskTitle']} (ID: {task['taskId']})")

    # 执行清空操作
    print("\n🧹 执行清空操作...")
    controller.clearCompletedTasks()

    # 模拟QML中的刷新
    print("🔄 模拟QML刷新...")
    completed_after = controller.getCompletedTasks()

    print(f"\n📊 清空后状态:")
    print(f"已完成任务数量: {len(completed_after)}")
    for task in completed_after:
        print(f"  - {task['taskTitle']} (ID: {task['taskId']})")

    # 检查数据库状态
    print("\n🗄️  数据库状态:")
    db_path = os.path.join(os.path.dirname(__file__), "data", "tasks.db")
    import sqlite3

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*) FROM tasks WHERE is_completed = 1")
    db_completed_count = cursor.fetchone()[0]

    cursor.execute("SELECT id, title, is_completed FROM tasks WHERE is_completed = 1")
    db_completed = cursor.fetchall()

    print(f"数据库中已完成任务数量: {db_completed_count}")
    for row in db_completed:
        print(f"  - {row[1]} (ID: {row[0]})")

    conn.close()

    # 结果判断
    success = len(completed_after) == 0 and db_completed_count == 0
    print(f"\n✅ 测试结果: {'成功' if success else '失败'}")

    if not success:
        print("❌ 清空功能未正常工作")
    else:
        print("✅ 清空功能正常工作")

    return success


def main():
    """main 功能说明。"""
    print("=" * 60)
    print("🧪 清空功能测试")
    print("=" * 60)

    success = test_clear_functionality()

    print("\n" + "=" * 60)
    print(f"总体结果: {'✅ 通过' if success else '❌ 失败'}")
    print("=" * 60)

    return success


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
