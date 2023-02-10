import QtQuick

import Status.Assets
import Status.Core.Theme

Item {
    id: root

    signal animationFinished()
    function show() {
        animator.start()
    }

    implicitWidth: splashLogo.implicitWidth
    implicitHeight: splashLogo.implicitHeight

    Image {
        id: splashLogo
        anchors.centerIn: parent
        sourceSize.width: width || undefined
        sourceSize.height: height || undefined
        mipmap: true
        antialiasing: true
        source: Resources.svg("status-logo-circle")
        width: 60
        height: 60
        fillMode: Image.Stretch

        RotationAnimator {
            id: animator
            target: splashLogo
            from: 0
            to: 360
            duration: 2000
            loops: Animation.Infinite
            onStopped: root.animationFinished()
        }
    }
}
