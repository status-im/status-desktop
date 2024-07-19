import QtQml 2.15

QtObject {
    id: root

    function toggleCentralizedMetrics(enabled) {
        metrics.toggleCentralizedMetrics(enabled)
    }

    readonly property bool isCentralizedMetricsEnabled : metrics.isCentralizedMetricsEnabled
}
