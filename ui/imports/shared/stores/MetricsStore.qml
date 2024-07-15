import QtQml 2.15

QtObject {
    id: root

    function toggleCentralizedMetrics(enabled) {
        metrics.toggleCentralizedMetrics(enabled)
    }

    function isCentralizedMetricsEnabled() {
        return metrics.isCentralizedMetricsEnabled()
    }
}
