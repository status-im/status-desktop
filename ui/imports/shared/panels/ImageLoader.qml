import QtQuick 2.15
import QtGraphicalEffects 1.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.stores 1.0

Rectangle {
    id: root
    property bool noHover: false
    property bool noMouseArea: false
    property bool showLoadingIndicator: true

    property alias source: image.source
    property alias fillMode: image.fillMode

    signal loaded
    signal clicked

    color: Theme.palette.backgroundHover
    radius: width / 2
    states: [
        State {
            name: "loading"
            when: image.status === Image.Loading
            PropertyChanges {
                target: loader
                sourceComponent: loadingIndicator
            }
        },
        State {
            name: "error"
            when: image.status === Image.Error
            PropertyChanges {
                target: loader
                sourceComponent: reload
            }
        },
        State {
            name: "ready"
            when: image.status === Image.Ready
            PropertyChanges {
                target: root
                color: Theme.palette.transparent
            }
            PropertyChanges {
                target: loader
                sourceComponent: undefined
            }
        }
    ]

    Connections {
        enabled: !!mainModule
        target: enabled ? mainModule : undefined
        function onOnlineStatusChanged(connected) {
            if (connected && root.state !== "ready" &&
                root.visible &&
                root.source &&
                root.source.startsWith("http")) {
                root.reload()
            }
        }
    }

    function reload() {
        // From the documentation (https://doc.qt.io/qt-5/qml-qtquick-image.html#sourceSize-prop)
        // Note: Changing this property dynamically causes the image source to
        // be reloaded, potentially even from the network, if it is not in the
        // disk cache.
        const oldSource = image.source
        image.cache = false
        image.sourceSize.width += 1
        image.sourceSize.width -= 1
        image.cache = true

    }

    Component {
        id: loadingIndicator
        StatusLoadingIndicator {
            width: 23
            height: 23
            color: Theme.palette.secondaryText
        }
    }

    Component {
        id: reload
        SVGImage {
            source: Theme.svg("reload")
            mipmap: false
            width: 15.5
            height: 19.5
            fillMode: Image.PreserveAspectFit
            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: Theme.palette.textColor
                antialiasing: true
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    root.reload()
                }
            }
        }
    }

    Loader {
        id: loader
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Image {
        id: image
        anchors.fill: parent
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        cache: true
        onStatusChanged: {
            if (status === Image.Ready) {
                loaded()
            }
        }
        MouseArea {
            enabled: !noMouseArea
            cursorShape: noHover ? Qt.ArrowCursor : Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                root.clicked()
            }
        }
    }
}
