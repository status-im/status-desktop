import QtQuick 2.14

import utils 1.0

Item {
    id: root
    implicitHeight: 240
    implicitWidth: 240

    states: [
        State {
            name: Constants.startupState.profileFetching
            PropertyChanges { target: loadingAnimation; opacity: 1; }
            PropertyChanges { target: completedImage; opacity: 0 }
            PropertyChanges { target: errorImage; opacity: 0 }

        },
        State {
            name: Constants.startupState.profileFetchingCompleted
            PropertyChanges { target: loadingAnimation; opacity: 0;}
            PropertyChanges { target: completedImage; opacity: 1 }
            PropertyChanges { target: errorImage; opacity: 0 }
        },
        State {
            name: Constants.startupState.profileFetchingError
            PropertyChanges { target: loadingAnimation; opacity: 0;}
            PropertyChanges { target: completedImage; opacity: 0 }
            PropertyChanges { target: errorImage; opacity: 1 }
        }
    ]

    transitions: [
        Transition {
            from: Constants.startupState.profileFetching
            to: Constants.startupState.profileFetchingCompleted
            ParallelAnimation {
                NumberAnimation { target: completedImage; property: "opacity"; duration: 100 }
                NumberAnimation { target: loadingAnimation; property: "opacity"; duration: 100 }
            }
        },
        Transition {
            from: Constants.startupState.profileFetching
            to: Constants.startupState.profileFetchingError
            ParallelAnimation {
                NumberAnimation { target: errorImage; property: "opacity"; duration: 100 }
                NumberAnimation { target: loadingAnimation; property: "opacity"; duration: 100 }
            }
        }
    ]

    SpriteSequence {
        id: loadingAnimation
        anchors.fill: root
        running: visible
        visible: opacity > 0

        Sprite {
            id: sprite
            frameCount: 94
            frameWidth: 240
            frameHeight: 240
            frameRate: 30
            source: Style.png(Constants.onboarding.profileFetching.imgInProgress)
        }
    }

    Image {
        id: completedImage
        anchors.fill: loadingAnimation
        visible: opacity > 0
        opacity: 0
        source: Style.png(Constants.onboarding.profileFetching.imgCompleted)
    }

    Image {
        id: errorImage
        anchors.fill: loadingAnimation
        visible: opacity > 0
        opacity: 0
        source: Style.png(Constants.onboarding.profileFetching.imgError)
    }
}
