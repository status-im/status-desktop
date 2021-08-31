import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Rectangle {
    id: statusExpandableSettingsItem

    property alias primaryText: primaryText.text
    property alias secondaryText: secondaryText.text
    property alias button: button
    property alias expandableComponent: expandableRegion.sourceComponent

    property bool expandable: true
    property  bool expanded: false
    property StatusIconSettings icon: StatusIconSettings {
        color: Theme.palette.directColor1
        background: StatusIconBackgroundSettings {
            width: 32
            height: 32
            color: Theme.palette.primaryColor2
        }
    }

    implicitWidth: 718

    radius: 8
    color: "transparent"
    border.color: Theme.palette.baseColor2
    state: "COLLAPSED"
    clip: true

    StatusRoundIcon {
        id: roundIcon
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.left: parent.left
        anchors.leftMargin: 11

        icon.background.width: statusExpandableSettingsItem.icon.background.width
        icon.background.height: statusExpandableSettingsItem.icon.background.height
        icon.background.color: statusExpandableSettingsItem.icon.background.color
        icon.color: statusExpandableSettingsItem.icon.color
        icon.name: statusExpandableSettingsItem.icon.name
    }

    StatusBaseText {
        id: primaryText
        anchors.top: parent.top
        anchors.topMargin: 17
        anchors.left: roundIcon.right
        anchors.leftMargin: 10

        width: button.visible ? parent.width - icon.background.width - button.width - 70 :
                                parent.width - icon.background.width - 70

        font.weight: Font.Medium
        font.pixelSize: 15
        lineHeight: 22
        lineHeightMode: Text.FixedHeight
        elide: Text.ElideRight
        color: Theme.palette.directColor1
    }

    StatusBaseText {
        id: secondaryText
        anchors.top: primaryText.bottom
        anchors.topMargin: 4
        anchors.left: primaryText.left
        anchors.right: primaryText.right

        font.pixelSize: 15
        lineHeight: 22
        lineHeightMode: Text.FixedHeight
        elide: Text.ElideRight
        color: Theme.palette.directColor3
    }

    StatusButton {
        id: button
        anchors.top: parent.top
        anchors.topMargin: 19
        anchors.right: parent.right
        anchors.rightMargin: 16
        visible: !!text
    }

    StatusIcon {
        id: expandImage
        anchors.top: parent.top
        anchors.topMargin: 36
        anchors.right: parent.right
        anchors.rightMargin: 23
        visible: expandable && !button.visible
        color: Theme.palette.directColor1
    }

    Loader {
        id: expandableRegion
        anchors.top: secondaryText.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 48
        width: parent.width - 64
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if(expandable) {
                expanded = !expanded
            }
        }
        cursorShape: Qt.PointingHandCursor
        visible: !button.visible && expandable
    }

    onExpandedChanged: {
        if(expanded) {
            state = "EXPANDED"
        }
        else {
            state = "COLLAPSED"
        }
    }

    states: [
        State {
            name: "EXPANDED"
            PropertyChanges {target: expandImage; icon: "chevron-up"}
            PropertyChanges {target: statusExpandableSettingsItem; height: 82 + expandableRegion.height + 22}
            PropertyChanges {target: expandableRegion; active: true}
        },
        State {
            name: "COLLAPSED"
            PropertyChanges {target: expandImage; icon: "chevron-down"}
            PropertyChanges {target: statusExpandableSettingsItem; height: 82}
            PropertyChanges {target: expandableRegion; active: false}
        }
    ]

    transitions: [
        Transition {
            from: "COLLAPSED"
            to: "EXPANDED"
            NumberAnimation { properties: "height"; duration: 200 }
        },
        Transition {
            from: "EXPANDED"
            to: "COLLAPSED"
            NumberAnimation { properties: "height"; duration: 200 }
        }
    ]
}
