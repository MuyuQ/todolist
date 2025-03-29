// utils.js - 工具函数库

// 日志函数，替代console.log，确保中文字符正确显示
function log(message) {
    if (typeof consoleLogger !== 'undefined') {
        consoleLogger.log(message);
    } else {
        // 如果consoleLogger不可用，回退到标准console.log
        console.log(message);
    }
}

// 获取象限颜色函数
function getQuadrantColor(quadrant) {
    switch(quadrant) {
        case 1: return "#4CAF50"; // 重要且紧急 - 绿色
        case 2: return "#2196F3"; // 重要不紧急 - 蓝色
        case 3: return "#FF9800"; // 紧急不重要 - 橙色
        case 4: return "#9E9E9E"; // 不重要不紧急 - 灰色
        default: return "#9E9E9E";
    }
}