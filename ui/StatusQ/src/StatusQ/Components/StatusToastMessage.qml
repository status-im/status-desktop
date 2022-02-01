import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import QtGraphicalEffects 1.13
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

Control {
    id: root
    width: 343
    height: !!secondaryText ? 68 : 48
    anchors.right: parent.right

    property bool open: false
    property string primaryText: ""
    property string secondaryText: ""
    property bool loading: false
    property string iconName: ""
    property string linkUrl: ""

    property StatusIconSettings icon: StatusIconSettings {
        width: 23
        height: 23
    }

    property int type: StatusToastMessage.Type.Default
    enum Type {
        Default,
        Success
    }

    function open(title, subTitle, iconName, type, loading, url) {
        root.primaryText = title;
        root.secondaryText = subTitle;
        root.icon.name = iconName;
        root.type = type;
        root.loading = loading;
        root.linkUrl = url;
        root.open = true;
    }

    signal close()
    signal linkActivated(var link)

    states: [
        State {
            name: "opened"
            when: root.open
            PropertyChanges {
                target: root
                anchors.rightMargin: 0
                opacity: 1.0
            }
        },
        State {
            name: "closed"
            when: !root.open
            PropertyChanges {
                target: root
                anchors.rightMargin: -width
                opacity: 0.0
            }
            StateChangeScript {
                script: { root.close(); }
            }
        }
    ]

    transitions: [
        Transition {
            to: "*"
            NumberAnimation { properties: "anchors.rightMargin,opacity"; duration: 400 }
        }
    ]

    background: Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.palette.statusToastMessage.backgroundColor
        radius: 8
        border.color: Theme.palette.baseColor2
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: Theme.palette.dropShadow
        }
    }

    contentItem: Item {
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 4
        height: parent.height
        MouseArea {
            anchors.fill: parent
            onMouseXChanged: {
                root.open = (mouseX < (root.width/3));
            }
        }
        RowLayout {
            anchors.fill: parent
            spacing: 16
            Rectangle {
                implicitWidth: 32
                implicitHeight: 32
                Layout.alignment: Qt.AlignVCenter
                radius: (root.width/2)
                color: (root.type === StatusToastMessage.Type.Success) ?
                        Theme.palette.successColor2 : Theme.palette.primaryColor3
                Loader {
                    anchors.centerIn: parent
                    sourceComponent: root.loading ? loadingInd : statusIcon
                    Component {
                        id: loadingInd
                        StatusLoadingIndicator {
                            color: (root.type === StatusToastMessage.Type.Success) ?
                                   Theme.palette.successColor1 : Theme.palette.primaryColor1
                        }
                    }
                    Component {
                        id: statusIcon
                        StatusIcon {
                            anchors.centerIn: parent
                            width: root.icon.width
                            height: root.icon.height
                            color: (root.type === StatusToastMessage.Type.Success) ?
                                   Theme.palette.successColor1 : Theme.palette.primaryColor1
                            icon: root.icon.name
                        }
                    }
                }
            }
            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                StatusBaseText {
                    width: parent.width
                    font.pixelSize: 13
                    color: Theme.palette.directColor1
                    elide: Text.ElideRight
                    text: root.primaryText
                }
                StatusBaseText {
                    width: parent.width
                    visible: (!root.linkUrl && !!root.secondaryText)
                    height: visible ? contentHeight : 0
                    font.pixelSize: 13
                    color: Theme.palette.baseColor1
                    text: root.secondaryText
                    elide: Text.ElideRight
                }
                StatusSelectableText {
                    visible: (!!root.linkUrl)
                    height: visible ? implicitHeight : 0
                    font.pixelSize: 13
                    hoveredLinkColor: Theme.palette.primaryColor1
                    text: "<p><a style=\"text-decoration:none\" href=\'" + root.linkUrl + " \'>" + root.secondaryText + "</a></p>"
                    onLinkActivated: {
                        root.linkActivated(root.linkUrl);
                    }
                }
            }
            StatusFlatRoundButton {
                type: StatusFlatRoundButton.Type.Secondary
                icon.name: "close"
                icon.color: Theme.palette.directColor1
                implicitWidth: 30
                implicitHeight: 30
                onClicked: {
                    root.open = false;
                }
            }
        }
    }
}
