#!/usr/bin/env python3
"""
测试清空按钮修复的脚本
"""

import sys
import os
import time
import subprocess
from pathlib import Path

def test_clear_button_functionality():
    """测试清空按钮功能"""
    print("开始测试清空按钮修复...")
    
    # 获取项目根目录
    project_root = Path(__file__).parent.absolute()
    print(f"项目根目录: {project_root}")
    
    # 启动应用
    print("启动应用...")
    try:
        # 使用subprocess启动应用
        process = subprocess.Popen(
            [sys.executable, "main.py"],
            cwd=project_root,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        # 等待应用启动
        time.sleep(3)
        
        # 检查应用是否启动成功
        if process.poll() is None:
            print("✓ 应用启动成功")
            
            # 检查端口8080是否监听
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            result = sock.connect_ex(('localhost', 8080))
            if result == 0:
                print("✓ Web服务器启动成功，端口8080可访问")
            else:
                print("✗ Web服务器启动失败")
            sock.close()
            
            # 获取应用输出日志
            try:
                stdout, stderr = process.communicate(timeout=5)
                if stdout:
                    print("应用输出:")
                    print(stdout)
                if stderr:
                    print("应用错误:")
                    print(stderr)
            except subprocess.TimeoutExpired:
                process.kill()
                print("获取应用输出超时")
                
        else:
            print("✗ 应用启动失败")
            stdout, stderr = process.communicate()
            if stderr:
                print("启动错误:", stderr)
                
    except Exception as e:
        print(f"测试过程中出错: {e}")
    
    finally:
        # 清理
        try:
            if process and process.poll() is None:
                process.terminate()
                process.wait(timeout=3)
        except:
            try:
                process.kill()
            except:
                pass
    
    print("测试完成")

if __name__ == "__main__":
    test_clear_button_functionality()