import QtQuick 2.14

import utils 1.0

Item {
    id: root
    implicitHeight: 240
    implicitWidth: 240


    SpriteSequence {
        id: loadingAnimation
        anchors.fill: root
        running: true

        Sprite {
            id: sprite
            frameCount: 94
            frameWidth: 240
            frameHeight: 240
            frameRate: 30
            source: Style.png(Constants.onboarding.profileFetching.imgInProgress)
        }
    }
}
