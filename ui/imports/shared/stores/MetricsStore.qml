import QtQml 2.15

QtObject {
    id: root

    function toggleCentralizedMetrics(enabled) {
        metrics.toggleCentralizedMetrics(enabled)
    }

    function addCentralizedMetric(eventName, eventValue = null) {
        let eventValueJsonStr = !!eventValue ? JSON.stringify(eventValue) : ""
        metrics.addCentralizedMetric(eventName, eventValueJsonStr)
    }

    readonly property bool isCentralizedMetricsEnabled : metrics.isCentralizedMetricsEnabled
}
