import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Rectangle {
    id: statusExpandableItem

    property alias primaryText: primaryText.text
    property alias secondaryText: secondaryText.text
    property alias additionalText: additionalText.text
    property alias button: button
    property alias expandableComponent: expandableRegion.sourceComponent
    property alias expandableItem: expandableRegion.item

    property int type: StatusExpandableItem.Type.Primary
    property bool expandable: true
    property bool expanded: false

    property StatusIconSettings icon: StatusIconSettings {
        width: !!statusExpandableItem.icon.name.toString() ? 24 : 40
        height: !!statusExpandableItem.icon.name.toString() ? 24 : 40
        color: Theme.palette.directColor1
        background: StatusIconBackgroundSettings {
            width: 32
            height: 32
            color: Theme.palette.primaryColor2
        }
    }
    property StatusImageSettings image: StatusImageSettings {
        width: 40
        height: 40
    }

    enum Type {
        Primary, // 0
        Secondary, // 1
        Tertiary // 2
    }

    implicitWidth: 718

    radius: (statusExpandableItem.type === StatusExpandableItem.Type.Primary) ? 8 : 0
    color: "transparent"
    border.color: (statusExpandableItem.type === StatusExpandableItem.Type.Primary) ? Theme.palette.baseColor2 : "transparent"
    state: "COLLAPSED"
    clip: true

    Rectangle {
        id:  separatorRect
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: 1

        color: Theme.palette.baseColor2
        visible: (statusExpandableItem.type === StatusExpandableItem.Type.Tertiary)
    }


    Rectangle {
        id: header
        anchors.top: parent.top
        width: parent.width
        height: 64
        radius: (statusExpandableItem.type === StatusExpandableItem.Type.Secondary) ? 8 : 0
        color: statusExpandableItem.type === StatusExpandableItem.Type.Secondary && sensor.containsMouse ? Theme.palette.baseColor2 : "transparent"

        StatusSmartIdenticon {
            id: identicon
            anchors.top: parent.top
            anchors.topMargin: (statusExpandableItem.type === StatusExpandableItem.Type.Secondary) ? 12.5 : 25
            anchors.left: parent.left
            anchors.leftMargin: (statusExpandableItem.type === StatusExpandableItem.Type.Secondary) ? 16 : 11
            image: statusExpandableItem.image
            icon: statusExpandableItem.icon
            name: primaryText.text
            active: (statusExpandableItem.type !== StatusExpandableItem.Type.Tertiary)
        }

        StatusBaseText {
            id: primaryText
            anchors.top: (statusExpandableItem.type === StatusExpandableItem.Type.Primary)  ||
                        (statusExpandableItem.type === StatusExpandableItem.Type.Tertiary) ? parent.top : undefined
            anchors.topMargin: (statusExpandableItem.type === StatusExpandableItem.Type.Tertiary) ? 29 : 17
            anchors.left: identicon.active ? identicon.right : parent.left
            anchors.leftMargin: (statusExpandableItem.type === StatusExpandableItem.Type.Primary) ?  10 : 16

            anchors.verticalCenter: (statusExpandableItem.type === StatusExpandableItem.Type.Secondary) ? identicon.verticalCenter : undefined

            width: !!additionalText.text ? (button.visible ? parent.width - icon.background.width - button.width - additionalText.contentWidth - 110 :
                                                          parent.width - icon.background.width - additionalText.contentWidth - 110) :
                                        (button.visible ? parent.width - icon.background.width - button.width - 70 :
                                                          parent.width - icon.background.width - 70)

            font.weight: (statusExpandableItem.type === StatusExpandableItem.Type.Primary) ? Font.Medium : Font.Normal
            font.pixelSize: (statusExpandableItem.type === StatusExpandableItem.Type.Primary) ? 15 : 17
            lineHeight: (statusExpandableItem.type === StatusExpandableItem.Type.Primary) ? 22 : 24
            lineHeightMode: Text.FixedHeight
            elide: Text.ElideRight
            color: (statusExpandableItem.type === StatusExpandableItem.Type.Tertiary) ? Theme.palette.baseColor1 : Theme.palette.directColor1
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

        StatusBaseText {
            id: additionalText
            anchors.verticalCenter: primaryText.verticalCenter
            anchors.verticalCenterOffset: 2
            anchors.right: expandImage.left
            anchors.rightMargin: 16

            font.pixelSize: 15
            lineHeight: 24
            lineHeightMode: Text.FixedHeight
            elide: Text.ElideRight
            color: Theme.palette.baseColor1
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
            anchors.verticalCenter: (statusExpandableItem.type === StatusExpandableItem.Type.Tertiary) ?
                                    primaryText.verticalCenter : identicon.verticalCenter
            anchors.verticalCenterOffset:(statusExpandableItem.type === StatusExpandableItem.Type.Tertiary) ?  -3 : -1
            anchors.right: parent.right
            anchors.rightMargin: {
                switch (statusExpandableItem.type) {
                    case StatusExpandableItem.Type.Primary:
                      return 23
                      break;
                    case StatusExpandableItem.Type.Secondary:
                      return 16
                      break;
                    default:
                      return 6

                }
            }
            visible: expandable && !button.visible
            color: (statusExpandableItem.type === StatusExpandableItem.Type.Tertiary) ?
                      Theme.palette.baseColor1 :
                      Theme.palette.directColor1
        }

        MouseArea {
            id: sensor
            anchors.fill: parent
            onClicked: {
                if(expandable) {
                    expanded = !expanded
                }
            }
            cursorShape: Qt.PointingHandCursor
            visible: !button.visible && expandable
            hoverEnabled: true
        }
    }

    Loader {
        id: expandableRegion
        anchors.top: header.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: (statusExpandableItem.type === StatusExpandableItem.Type.Primary) ? 48 : 0
        anchors.right: parent.right
        anchors.rightMargin: (statusExpandableItem.type === StatusExpandableItem.Type.Primary) ? 16 : 0
        visible: false
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
            PropertyChanges {target: statusExpandableItem; height: 82 + expandableRegion.height + 22}
            PropertyChanges {target: expandableRegion; visible: true}
        },
        State {
            name: "COLLAPSED"
            PropertyChanges {target: expandImage; icon: "chevron-down"}
            PropertyChanges {target: statusExpandableItem; height: 82}
            PropertyChanges {target: expandableRegion; visible: false}
        }
    ]

    transitions: [
        Transition {
            from: "COLLAPSED"
            to: "EXPANDED"
            NumberAnimation { properties: "height"; duration: 200;}
        },
        Transition {
            from: "EXPANDED"
            to: "COLLAPSED"
            NumberAnimation { properties: "height"; duration: 200;}
        }
    ]
}
