import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2
import QtGraphicalEffects 1.0

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Page {
    id: root
    anchors.fill: parent
    anchors.margins: 16
    property ListModel contactsModel: null
    background: null

    header: RowLayout {
        id: headerRow
        width: parent.width
        height: tagSelector.height
        anchors.right: parent.right
        anchors.rightMargin: 8

        StatusTagSelector {
            id: tagSelector
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 17
            implicitHeight: 44
            toLabelText: qsTr("To: ")
            warningText: qsTr("5 USER LIMIT REACHED")
            //simulate model filtering, TODO this
            //makes more sense to be provided by the backend
            //figure how real implementation should look like
            property ListModel sortedList: ListModel { }
            onTextChanged: {
                sortedList.clear();
                if (text !== "") {
                    for (var i = 0; i < contactsModel.count; i++ ) {
                        var entry = contactsModel.get(i);
                        if (entry.name.toLowerCase().includes(text.toLowerCase())) {
                            sortedList.insert(sortedList.count, {"publicId": entry.publicId, "name": entry.name,
                                                  "icon": entry.icon, "isIdenticon": entry.isIdenticon,
                                                  "onlineStatus": entry.onlineStatus});
                            userListView.model = sortedList;
                        }
                    }
                } else {
                    userListView.model = contactsModel;
                }
            }
        }

        StatusButton {
            implicitHeight: 44
            enabled: (tagSelector.namesModel.count > 0)
            text: "Confirm"
        }
    }

    contentItem: Item {
        anchors.fill: parent
        anchors.topMargin: headerRow.height + 16

        Item {
            anchors.fill: parent
            visible: (contactsModel.count > 0)

            StatusBaseText {
                id: contactsLabel
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: "Contacts"
            }
            Control {
                width: 360
                anchors {
                    top: contactsLabel.bottom
                    topMargin: 8//Style.current.padding
                    bottom: parent.bottom
                    bottomMargin: 20//Style.current.bigPadding
                }
                background: Rectangle {
                    id: statusPopupMenuBackgroundContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: (userListView.height + 8)
                    visible: (tagSelector.sortedList.count > 0)
                    color: Theme.palette.statusPopupMenu.backgroundColor
                    radius: 8
                    layer.enabled: true
                    layer.effect: DropShadow {
                        width: statusPopupMenuBackgroundContent.width
                        height: statusPopupMenuBackgroundContent.height
                        x: statusPopupMenuBackgroundContent.x
                        visible: statusPopupMenuBackgroundContent.visible
                        source: statusPopupMenuBackgroundContent
                        horizontalOffset: 0
                        verticalOffset: 4
                        radius: 12
                        samples: 25
                        spread: 0.2
                        color: Theme.palette.dropShadow
                    }
                }
                contentItem: ListView {
                    id: userListView
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: (count * 64) > parent.height ? parent.height : (count * 64)
                    clip: true
                    model: contactsModel
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: Item {
                        id: wrapper
                        anchors.right: parent.right
                        anchors.left: parent.left
                        height: 64
                        property bool hovered: false
                        Rectangle {
                            id: rectangle
                            anchors.fill: parent
                            anchors.topMargin: 8
                            anchors.rightMargin: 8
                            anchors.leftMargin: 8
                            radius: 8
                            visible: (tagSelector.sortedList.count > 0)
                            color: (wrapper.hovered) ? Theme.palette.baseColor2 : "transparent"
                        }

                        StatusSmartIdenticon {
                            id: contactImage
                            anchors.left: parent.left
                            anchors.leftMargin: 16//Style.current.padding
                            anchors.verticalCenter: parent.verticalCenter
                            name: model.name
                            icon: StatusIconSettings {
                                width: 28
                                height: 28
                                letterSize: 15
                            }
                            image: StatusImageSettings {
                                width: 28
                                height: 28
                                source: model.icon
                                isIdenticon: model.isIdenticon
                            }
                        }

                        StatusBaseText {
                            id: contactInfo
                            text: model.name
                            anchors.right: parent.right
                            anchors.rightMargin: 8
                            anchors.left: contactImage.right
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            color: Theme.palette.directColor1
                            font.weight: Font.Medium
                            font.pixelSize: 15
                        }

                        StatusBadge {
                            id: statusBadge
                            width: 15
                            height: 15
                            anchors.left: contactImage.right
                            anchors.leftMargin: -8
                            anchors.bottom: contactImage.bottom
                            border.width: 3
                            border.color: Theme.palette.statusAppNavBar.backgroundColor
                            color: {
                                if (model.onlineStatus === 1)
                                    return Theme.palette.successColor1;
                                else if (model.onlineStatus === 2)
                                    return Theme.palette.pinColor1;
                                else if (model.onlineStatus === 3)
                                    return Theme.palette.dangerColor1;

                                return "transparent"
                            }
                        }

                        MouseArea {
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                wrapper.hovered = true;
                            }
                            onExited: {
                                wrapper.hovered = false;
                            }
                            onClicked: {
                                tagSelector.insertTag(model.name, model.publicId);
                            }
                        }
                    }
                }
            }
            Component.onCompleted: {
                if (visible) {
                    tagSelector.textEdit.forceActiveFocus();
                }
            }
        }

        StatusBaseText {
            visible: (contactsModel.count === 0)
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 15
            color: Theme.palette.baseColor1
            text: qsTr("You can only send direct messages to your Contacts. \n\n
Send a contact request to the person you would like to chat with, you will be\n able to
chat with them once they have accepted your contact request.")
            Component.onCompleted: {
                if (visible) {
                    tagSelector.enabled = false;
                }
            }
        }
    }
}
