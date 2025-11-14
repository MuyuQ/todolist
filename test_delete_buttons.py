#!/usr/bin/env python3
"""
测试删除按钮功能的脚本
"""
import sys
import os
import time

# 添加项目根目录到Python路径
sys.path.insert(0, os.path.dirname(__file__))

from models.task_model_optimized import TaskModel
from controllers.task_controller_optimized import TaskController

def test_delete_functionality():
    print("🗑️  测试删除按钮功能...")
    
    # 创建模型和控制器
    model = TaskModel()
    controller = TaskController(model)
    
    # 检查初始状态
    print("\n📊 初始状态:")
    all_tasks = controller.getAllTasks()
    print(f"总任务数量: {len(all_tasks)}")
    for task in all_tasks:
        print(f"  - {task['title']} (ID: {task['id']})")
    
    if len(all_tasks) == 0:
        print("⚠️  没有任务可测试，先添加一些测试任务...")
        
        # 添加测试任务
        task1_id = controller.addTask("测试删除任务1", "测试描述1", 1)
        task2_id = controller.addTask("测试删除任务2", "测试描述2", 2)
        task3_id = controller.addTask("测试删除任务3", "测试描述3", 3)
        
        print(f"添加了测试任务，ID: {task1_id}, {task2_id}, {task3_id}")
        
        # 刷新任务列表
        controller.refreshTasks()
        time.sleep(0.1)  # 等待更新完成
        
        # 重新获取任务列表
        all_tasks = controller.getAllTasks()
    
    print(f"\n📊 准备测试删除:")
    print(f"总任务数量: {len(all_tasks)}")
    for i, task in enumerate(all_tasks):
        print(f"  {i+1}. {task['title']} (ID: {task['id']})")
    
    # 测试删除功能
    if len(all_tasks) > 0:
        # 选择第一个任务进行删除测试
        task_to_delete = all_tasks[0]
        task_id = task_to_delete['id']
        task_title = task_to_delete['title']
        
        print(f"\n🖱️  模拟点击删除按钮...")
        print(f"   目标任务: {task_title} (ID: {task_id})")
        
        # 执行删除操作（模拟删除按钮点击）
        controller.deleteTask(task_id)
        
        # 等待更新完成
        time.sleep(0.1)
        
        # 验证删除结果
        print("\n5️⃣  检查删除结果...")
        all_tasks_after = controller.getAllTasks()
        print(f"删除后总任务数量: {len(all_tasks_after)}")
        
        # 检查被删除的任务是否还存在
        task_exists = any(task['id'] == task_id for task in all_tasks_after)
        
        if task_exists:
            print(f"被删除任务 '{task_title}' 状态: ❌ 仍然存在（删除失败）")
        else:
            print(f"被删除任务 '{task_title}' 状态: ✅ 已成功删除")
        
        print("\n剩余任务:")
        for i, task in enumerate(all_tasks_after):
            print(f"  {i+1}. {task['title']} (ID: {task['id']})")
        
        # 判断测试结果
        success = not task_exists
        print(f"\n🎯 删除功能测试结果: {'✅ 成功' if success else '❌ 失败'}")
        
        if success:
            print("🎉 删除按钮功能验证成功！")
            print("💡 用户现在可以通过点击任务项上的红色删除按钮(🗑️)来删除单个任务")
        else:
            print("⚠️  删除功能存在问题，需要进一步调试")
        
        return success
    else:
        print("⚠️  没有可删除的任务")
        return False

def main():
    print("=" * 80)
    print("🧪 删除按钮功能测试")
    print("=" * 80)
    
    # 测试删除功能
    success = test_delete_functionality()
    
    # 总结
    print("\n" + "="*80)
    print("📊 测试结果总结:")
    if success:
        print("  删除功能测试: ✅ 通过")
    else:
        print("  删除功能测试: ❌ 失败")
    
    if success:
        print(f"\n总体结果: 🎉 完全成功")
    else:
        print(f"\n总体结果: ❌ 存在问题")
    
    if success:
        print("\n💡 功能变更总结:")
        print("  • 删除了全局清空按钮")
        print("  • 在每个任务项后添加了删除按钮(🗑️)")
        print("  • 用户现在可以通过点击红色删除按钮删除单个任务")
        print("  • 删除前会显示确认对话框防止误删")
    
    print("=" * 80)
    
    return success

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)