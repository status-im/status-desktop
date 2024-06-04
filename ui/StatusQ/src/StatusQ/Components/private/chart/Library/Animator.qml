import QtQuick 2.15

QtObject {
    id: root
    property double chartAnimationProgress: 0.1
    property int chartAnimationDuration: 500
    property var animationEasingType: Easing.InOutExpo

    property var _requests: []

    signal animationFinished()

    readonly property PropertyAnimation animator : PropertyAnimation {
        id: chartAnimator
        target: root
        property: "chartAnimationProgress"
        alwaysRunToEnd: true
        to: 1
        duration: root.chartAnimationDuration
        easing.type: root.animationEasingType
        onFinished: {
            root.chartAnimationProgress = 0.1
            root.animationFinished()
        }
    }

    onChartAnimationProgressChanged: {
        root.animate();
    }

    function requestAnimation(callback) {
        _requests.push({
            callback: callback,
            scope: this
        })

        if (!chartAnimator.running) {
            root.chartAnimationProgress = 0.1
            chartAnimator.restart();
        }

        return -1
    }

    function animate() {
        var requests = _requests
        var ilen = requests.length
        
        var requestItem = null
        var i = 0

        _requests = []
        for (; i < ilen; ++i) {
            requestItem = requests[i]
            requestItem.callback.call(requestItem.scope)
        }
    }
}
