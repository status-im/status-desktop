import QtQuick 2.3
import QtGraphicalEffects 1.13
import "../imports"

Rectangle {
    id: root
    property url source
    signal clicked
    color: Style.current.backgroundHover
    state: "loading"
    radius: width / 2
    states: [
        State {
            name: "loading"
            when: image.status === Image.Loading
            PropertyChanges {
                target: loading
                visible: true
            }
            PropertyChanges {
                target: reload
                visible: false
            }
            PropertyChanges {
                target: image
                visible: false
            }
        },
        State {
            name: "error"
            when: image.status === Image.Error
            PropertyChanges {
                target: loading
                visible: false
            }
            PropertyChanges {
                target: reload
                visible: true
            }
            PropertyChanges {
                target: image
                visible: false
            }
        },
        State {
            name: "ready"
            when: image.status === Image.Ready
            PropertyChanges {
                target: root
                color: Style.current.transparent
            }
            PropertyChanges {
                target: loading
                visible: false
            }
            PropertyChanges {
                target: reload
                visible: false
            }
            PropertyChanges {
                target: image
                visible: true
                height: root.height
                width: root.width
            }
        }
    ]

    function reload() {
        // From the documentation (https://doc.qt.io/qt-5/qml-qtquick-image.html#sourceSize-prop)
        // Note: Changing this property dynamically causes the image source to 
        // be reloaded, potentially even from the network, if it is not in the 
        // disk cache.
        image.sourceSize.width += 1
        image.sourceSize.width -= 1
    }

    LoadingImage {
        id: loading
        width: 23
        height: 23
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Style.current.secondaryText
            antialiasing: true
        }
    }

    SVGImage {
        id: reload
        source: "../app/img/reload.svg"
        width: 15.5
        height: 19.5
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Style.current.textColor
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

    Image {
        id: image
        width: 0
        height: 0
        sourceSize.width: root.width  * 2
        sourceSize.height: root.height * 2
        source: root.source
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
        cache: true
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                root.clicked()
            }
        }
    }
}
