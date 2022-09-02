import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root
    width: layout.width + layout.anchors.margins
    height: 30
    color: Theme.palette.primaryColor3
    radius: 15

    property alias titleText: titleText

    property string title: ""
    property bool closeButtonVisible: true
    signal clicked()

    property StatusAssetSettings asset: StatusAssetSettings {
        height: 20
        width: 20
        rotation: 0
        isLetterIdenticon: false
        letterSize: 10
        color: Theme.palette.primaryColor1
        bgWidth: 15
        bgHeight: 15
        bgColor: Theme.palette.primaryColor3
        imgIsIdenticon: false
    }

    RowLayout {
        id: layout
        height: parent.height
        anchors.margins: 6

        StatusSmartIdenticon {
            id: iconOrImage
            Layout.leftMargin: 4
            asset: root.asset
            name: root.title
            active: root.asset.isLetterIdenticon ||
                    !!root.asset.name
        }

        StatusBaseText {
            id: titleText
            color: Theme.palette.primaryColor1
            text: root.title
            Layout.rightMargin: closeButtonVisible ? 0 : 5
        }

        StatusIcon {
            id: closeIcon
            color: Theme.palette.primaryColor1
            icon: "close-circle"
            visible: closeButtonVisible
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.clicked()
                }
            }
        }
    }
}
