import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    implicitWidth: 448
    implicitHeight: 44 + ((userListView.count > 0) ? 44 + ((((userListView.count * 64) > root.maxHeight)
                    ? root.maxHeight : (userListView.count * 64))) :0)

    property real maxHeight
    property alias textEdit: edit
    property alias text: edit.text
    property string warningText: ""
    property string toLabelText: ""
    property string listLabel: ""
    property int nameCountLimit: 5

    property ListModel sortedList: ListModel { }
    property ListModel namesModel: ListModel { }

    function find(model, criteria) {
        for (var i = 0; i < model.count; ++i) if (criteria(model.get(i))) return model.get(i);
        return null;
    }

    function insertTag(name, id) {
        if (!find(namesModel, function(item) { return item.publicId === id }) && namesModel.count < root.nameCountLimit) {
            namesModel.insert(namesModel.count, {"name": name, "publicId": id});
            addMember(id);
            edit.clear();
        }
    }

    function sortModel(inputModel) {
        sortedList.clear();
        if (text !== "") {
            for (var i = 0; i < inputModel.count; i++ ) {
                var entry = inputModel.get(i);
                if (entry.name.toLowerCase().includes(text.toLowerCase())) {
                    sortedList.insert(sortedList.count, {"publicId": entry.publicId, "name": entry.name,
                                          "icon": entry.icon, "isIdenticon": entry.isIdenticon,
                                          "onlineStatus": entry.onlineStatus});
                    userListView.model = sortedList;
                }
            }
        } else {
            userListView.model = inputModel;
        }
    }

    signal addMember(string memberId)
    signal removeMember(string memberId)

    Rectangle {
        id: tagSelectorRect
        width: parent.width
        height: 44
        radius: 8
        color: Theme.palette.baseColor2

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8
            StatusBaseText {
                Layout.preferredWidth: 22
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                color: Theme.palette.baseColor1
                text: root.toLabelText
            }

            ScrollView {
                Layout.preferredWidth: (namesList.contentWidth > (parent.width - 142)) ?
                                       (parent.width - 142) : namesList.contentWidth
                implicitHeight: 30
                Layout.alignment: Qt.AlignVCenter
                visible: (namesList.count > 0)
                contentWidth: namesList.contentWidth
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                clip: true
                ListView {
                    id: namesList
                    anchors.fill: parent
                    model: namesModel
                    orientation: ListView.Horizontal
                    spacing: 8
                    onCountChanged: {
                        contentX = contentWidth;
                    }
                    delegate: Rectangle {
                        id: nameDelegate
                        width: (nameText.contentWidth + 34)
                        height: 30
                        color: mouseArea.containsMouse ? Theme.palette.miscColor1 : Theme.palette.primaryColor1
                        radius: 8
                        StatusBaseText {
                            id: nameText
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.palette.indirectColor1
                            text: name
                        }
                        StatusIcon {
                            anchors.left: nameText.right
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.palette.indirectColor1
                            icon: "close"
                        }
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                removeMember(publicId);
                                namesModel.remove(index, 1);
                            }
                        }
                    }
                }
            }

            TextEdit {
                id: edit
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                verticalAlignment: Text.AlignVCenter
                visible: (namesModel.count < 5)
                enabled: visible
                focus: true
                font.pixelSize: 15
                font.family: Theme.palette.baseFont.name
                color: Theme.palette.directColor1
                Keys.onPressed: {
                    if ((event.key === Qt.Key_Backspace || event.key === Qt.Key_Escape)
                            && getText(cursorPosition, (cursorPosition-1)) === "") {
                        removeMember(namesModel.get(namesList.count-1).publicId);
                        namesModel.remove((namesList.count-1), 1);
                    }
                }
            }

            StatusBaseText {
                id: warningTextLabel
                visible: (namesModel.count === root.nameCountLimit)
                Layout.preferredWidth: 120
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                font.pixelSize: 10
                color: Theme.palette.dangerColor1
                text: root.nameCountLimit + " " + root.warningText
            }
        }
    }

    StatusBaseText {
        id: contactsLabel
        font.pixelSize: 15
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.top: tagSelectorRect.bottom
        anchors.topMargin: 32
        visible: (namesModel.count === 0)
        color: Theme.palette.baseColor1
        text: root.listLabel
    }

    Control {
        id: suggestionsContainer
        width: 360
        anchors {
            top: (root.sortedList.count > 0) ? tagSelectorRect.bottom : contactsLabel.bottom
            topMargin: 8//Style.current.padding
            bottom: parent.bottom
            bottomMargin: 20//Style.current.bigPadding
        }
        visible: ((root.namesModel.count === 0) || (root.sortedList.count > 0))
        x: ((root.namesModel.count > 0) && ((edit.x + 8) <= (root.width - suggestionsContainer.width)))
           ? (edit.x + 8) : 0
        background: Rectangle {
            id: bgRect
            anchors.fill: parent
            visible: (root.sortedList.count > 0)
            color: Theme.palette.statusPopupMenu.backgroundColor
            radius: 8
            layer.enabled: true
            layer.effect: DropShadow {
                width: bgRect.width
                height: bgRect.height
                x: bgRect.x
                source: bgRect
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
            anchors.fill: parent
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            clip: true
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
                    anchors.rightMargin: 8
                    anchors.leftMargin: 8
                    radius: 8
                    visible: (root.sortedList.count > 0)
                    color: (wrapper.hovered) ? Theme.palette.baseColor2 : "transparent"
                }

                StatusSmartIdenticon {
                    id: contactImage
                    anchors.left: parent.left
                    anchors.leftMargin: 16//Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    name: model.name
                    icon: StatusIconSettings {
                        width: 40
                        height: 40
                        letterSize: 15
                    }
                    image: StatusImageSettings {
                        width: 40
                        height: 40
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
                        root.insertTag(model.name, model.publicId);
                    }
                }
            }
        }
    }
}
