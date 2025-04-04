pragma Singleton
pragma Singleton
import QtQuick 2.15
import QtQuick.Controls.Material 2.15

QtObject {
    id: utils
    
    // 象限颜色
    readonly property var quadrantColors: ["#ef5350", "#66bb6a", "#42a5f5", "#ab47bc"]
    
    // 象限标题
    readonly property var quadrantTitles: ["重要且紧急", "重要不紧急", "不重要但紧急", "不重要不紧急"]
    
    // 获取象限颜色函数
    function getQuadrantColor(quadrant) {
        return quadrant >= 1 && quadrant <= 4 ? quadrantColors[quadrant - 1] : "#e0e0e0";
    }
    
    // 获取象限标题函数
    function getQuadrantTitle(quadrant) {
        return quadrant >= 1 && quadrant <= 4 ? quadrantTitles[quadrant - 1] : "未分类";
    }
    
    // 格式化日期函数
    function formatDate(dateString) {
        if (!dateString) return "";
        var date = new Date(dateString);
        return date.toLocaleDateString(Qt.locale(), "yyyy-MM-dd");
    }
    
    // 格式化时间函数
    function formatTime(dateString) {
        if (!dateString) return "";
        var date = new Date(dateString);
        return date.toLocaleTimeString(Qt.locale(), "hh:mm");
    }
    
    // 截断文本函数
    function truncateText(text, maxLength) {
        if (!text) return "";
        return text.length > maxLength ? text.substring(0, maxLength) + "..." : text;
    }
}