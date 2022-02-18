import QtQuick 2.14
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    implicitWidth: 448
    implicitHeight: 44

    property alias textEdit: edit
    property alias text: edit.text
    property string warningText: ""
    property string toLabelText: ""
    property int nameCountLimit: 5
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

    signal addMember(string memberId)
    signal removeMember(string memberId)

    Rectangle {
        anchors.fill: parent
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
                Layout.fillWidth: true
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
                    onContentWidthChanged: {
                        positionViewAtEnd();
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
}
