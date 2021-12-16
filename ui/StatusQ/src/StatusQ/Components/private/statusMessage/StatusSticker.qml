import QtQuick 2.3
import QtGraphicalEffects 1.13

import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Loader {
    id: statusSticker

    property bool noHover: false
    property bool noMouseArea: false
    property StatusImageSettings image: StatusImageSettings {
        width: 140
        height: 140
    }

    signal loaded()
    signal clicked()

    active: visible

    sourceComponent: Rectangle {
        id: root

        color: Theme.palette.baseColor2
        radius: 16

        width: image.width
        height: image.height

        function reload() {
            // From the documentation (https://doc.qt.io/qt-5/qml-qtquick-image.html#sourceSize-prop)
            // Note: Changing this property dynamically causes the image source to
            // be reloaded, potentially even from the network, if it is not in the
            // disk cache.
            const oldSource = sticker.source
            sticker.cache = false
            sticker.sourceSize.width += 1
            sticker.sourceSize.width -= 1
            sticker.cache = true
        }

        Loader {
            id: loader
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Image {
            id: sticker
            anchors.fill: parent
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            cache: true
            source: image.source

            onStatusChanged: {
                if (status === Image.Ready) {
                    statusSticker.loaded()
                }
            }
            MouseArea {
                enabled: !noMouseArea && (sticker.status === Image.Ready)
                cursorShape: noHover ? Qt.ArrowCursor : Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: statusSticker.clicked()
            }
        }

        Component {
            id: loadingIndicator
            StatusLoadingIndicator {
                width: 24
                height: 24
                color: Theme.palette.baseColor1
            }
        }

        Component {
            id: reload
            StatusIcon {
                icon: "refresh"
                color: Theme.palette.directColor1
                mipmap: false
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.reload()
                }
            }
        }

        states: [
            State {
                name: "loading"
                when: sticker.status === Image.Loading
                PropertyChanges {
                    target: loader
                    sourceComponent: loadingIndicator
                }
            },
            State {
                name: "error"
                when: sticker.status === Image.Error
                PropertyChanges {
                    target: loader
                    sourceComponent: reload
                }
            },
            State {
                name: "ready"
                when: sticker.status === Image.Ready
                PropertyChanges {
                    target: root
                    color: "transparent"
                }
                PropertyChanges {
                    target: loader
                    sourceComponent: undefined
                }
            }
        ]
    }
}
