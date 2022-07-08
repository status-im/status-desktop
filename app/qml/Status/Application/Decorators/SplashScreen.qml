import QtQuick

import Status.Assets
import Status.Core.Theme

Item {
    id: root

    signal animationFinished()
    function show() {
        splashLogo.playing = true
    }

    implicitWidth: splashLogo.implicitWidth
    implicitHeight: splashLogo.implicitHeight

    visible: (opacity > 0.0001)

    // TODO: consider bringing POC attempt to use lottie animations
    AnimatedImage {
        id: splashLogo
        anchors.centerIn: parent
        scale: 0.5
        source: Resources.gif("status_splash_" + Style.theme.name)

        readonly property real frameToStartAnimation: frameCount/2
        readonly property real animationRange: (frameCount - frameToStartAnimation)

        onCurrentFrameChanged: {
            if(currentFrame > frameToStartAnimation)
                root.opacity = 1 - (currentFrame - frameToStartAnimation)/animationRange
            if(currentFrame === (frameCount - 1))
                root.animationFinished()
        }
        playing: false
    }
}
