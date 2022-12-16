import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Control {
    id: root

    property alias titleText: titleText
    property string title: ""
    property bool tagClickable: false
    property bool closeButtonVisible: true
    property color bgColor: Theme.palette.primaryColor3
    property color bgBorderColor: "transparent"
    property int bgRadius: 15

    signal clicked(var mouse)
    signal tagClicked(var mouse)

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

    QtObject {
        id: d
        readonly property int commonMargin: 6
        readonly property int minHeight: 30
    }

    leftPadding: d.commonMargin
    rightPadding: d.commonMargin
    spacing: d.commonMargin
    implicitHeight: d.minHeight
    background: Rectangle {
        color: root.bgColor
        radius: root.bgRadius
        border.color: root.bgBorderColor

        MouseArea {
            anchors.fill: parent
            enabled: root.tagClickable
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.tagClicked(mouse)
        }
    }
    contentItem: RowLayout {
        id: layout
        spacing: root.spacing

        StatusSmartIdenticon {
            id: iconOrImage
            asset: root.asset
            name: root.title
            active: root.asset.isLetterIdenticon ||
                    !!root.asset.name
        }

        StatusBaseText {
            id: titleText
            Layout.fillWidth: true
            color: Theme.palette.primaryColor1
            text: root.title
            Layout.rightMargin: closeButtonVisible ? 0 : d.commonMargin
            elide: Text.ElideRight
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
                onClicked: root.clicked(mouse)
            }
        }
    }
}
