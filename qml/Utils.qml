pragma Singleton
import QtQuick 2.15
import QtQuick.Controls.Material 2.15
import "." as App

QtObject {
    id: utils
    
    // 获取象限颜色函数 - 使用CommonStyles中的函数
    function getQuadrantColor(quadrant) {
        return CommonStyles.colors.getQuadrantColor(quadrant);
    }
    
    // 获取象限标题函数 - 使用CommonStyles中的函数
    function getQuadrantTitle(quadrant) {
        return CommonStyles.colors.getQuadrantTitle(quadrant);
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