// utils.js - ���ߺ�����

// ��־���������console.log��ȷ�������ַ���ȷ��ʾ
function log(message) {
    if (typeof consoleLogger !== 'undefined') {
        consoleLogger.log(message);
    } else {
        // ���consoleLogger�����ã����˵���׼console.log
        console.log(message);
    }
}

// ��ȡ������ɫ����
function getQuadrantColor(quadrant) {
    switch(quadrant) {
        case 1: return "#4CAF50"; // ��Ҫ�ҽ��� - ��ɫ
        case 2: return "#2196F3"; // ��Ҫ������ - ��ɫ
        case 3: return "#FF9800"; // ��������Ҫ - ��ɫ
        case 4: return "#9E9E9E"; // ����Ҫ������ - ��ɫ
        default: return "#9E9E9E";
    }
}