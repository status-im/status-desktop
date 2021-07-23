import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Control {
    id: root
    implicitWidth: contentItem.width
    implicitHeight: visible ? 22 : 0
    visible: !!root.primaryText

    property string primaryText: ""
    property string secondaryText: ""

    property StatusImageSettings image: StatusImageSettings {
        height: 16
        width: 16
        isIdenticon: false
    }
    property StatusIconSettings icon: StatusIconSettings {
        height: 16
        width: 16
        isLetterIdenticon: false
        background: StatusIconBackgroundSettings {}
        color: "transparent"
    }

    background: Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 11
        border.color: Theme.palette.directColor7
    }

    contentItem: Item {
        id: contentItem
        width: (contentItemRow.width + 10)
        height: parent.height
        RowLayout {
            id: contentItemRow
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -spacing
            spacing: 2
            StatusRoundedImage {
                implicitWidth: root.image.width
                implicitHeight: root.image.height
                visible: !root.icon.isLetterIdenticon
                image.source: root.image.source
                border.color: Theme.palette.baseColor1
                border.width: root.image.isIdenticon ? 1 : 0
            }
            StatusLetterIdenticon {
                implicitWidth: root.icon.width
                implicitHeight: root.icon.width
                letterSize: 11
                visible: root.icon.isLetterIdenticon
                color: root.icon.color
                name: root.primaryText
            }
            StatusBaseText {
                font.weight: Font.Medium
                color: Theme.palette.baseColor1
                text: root.primaryText
            }
            StatusIcon {
                Layout.alignment: Qt.AlignVCenter
                visible: !!root.secondaryText
                color: Theme.palette.baseColor1
                icon: "next"
            }
            StatusBaseText {
                font.weight: Font.Medium
                color: Theme.palette.baseColor1
                visible: !!root.secondaryText
                text: root.secondaryText
            }
        }
    }
}
