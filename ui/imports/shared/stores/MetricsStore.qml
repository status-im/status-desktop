import QtQml

QtObject {
    id: root

    function toggleCentralizedMetrics(enabled) {
        metrics.toggleCentralizedMetrics(enabled)
    }

    function addCentralizedMetricIfEnabled(eventName, eventValue = null) {
        let eventValueJsonStr = !!eventValue ? JSON.stringify(eventValue) : ""
        metrics.addCentralizedMetricIfEnabled(eventName, eventValueJsonStr)
    }

    readonly property bool isCentralizedMetricsEnabled : metrics.isCentralizedMetricsEnabled
}
