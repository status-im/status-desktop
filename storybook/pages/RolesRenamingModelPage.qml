import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

Item {
    id: root

    RolesRenamingModel {
        id: renamedModel

        sourceModel: sourceModel

        mapping: [
            RoleRename {
                from: "tokenId"
                to: "id"
            },
            RoleRename {
                from: "title"
                to: "name"
            }
        ]
    }

    ListModel {
        id: sourceModel

        ListElement {
            tokenId: "1"
            title: "Token 1"
            communityId: "1"
        }
        ListElement {
            tokenId: "2"
            title: "Token 2"
            communityId: "1"
        }
        ListElement {
            tokenId: "3"
            title: "Token 3"
            communityId: "2"
        }
        ListElement {
            tokenId: "4"
            title: "Token 4"
            communityId: "3"
        }
        ListElement {
            tokenId: "5"
            title: "Token 5"
            communityId: ""
        }
        ListElement {
            tokenId: "6"
            title: "Token 6"
            communityId: "1"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                border.color: "gray"

                ListView {
                    anchors.fill: parent

                    model: sourceModel

                    header: Label {
                        height: implicitHeight * 2
                        text: `Left model (${sourceModel.count})`

                        font.bold: true

                        verticalAlignment: Text.AlignVCenter
                    }

                    ScrollBar.vertical: ScrollBar {}

                    delegate: Label {
                        width: ListView.view.width

                        text: `token id: ${model.tokenId}, ${model.title}, community id: ${model.communityId || "-"}`
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                border.color: "gray"

                ListView {
                    id: renamedListView

                    anchors.fill: parent

                    model: renamedModel

                    header: Label {
                        height: implicitHeight * 2
                        text: `Renamed model (${renamedListView.count})`

                        font.bold: true

                        verticalAlignment: Text.AlignVCenter
                    }

                    ScrollBar.vertical: ScrollBar {}

                    delegate: Label {
                        width: ListView.view.width

                        text: `id: ${model.id}, ${model.name}, community id: ${model.communityId || "-"}`
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "shuffle"

                onClicked: {
                    const count = sourceModel.count
                    const iterations = count / 2

                    for (let i = 0; i < iterations; i++) {
                        sourceModel.move(Math.floor(Math.random() * (count - 1)),
                                         Math.floor(Math.random() * (count - 1)),
                                         Math.floor(Math.random() * 2) + 1)
                    }
                }
            }
        }
    }
}

// category: Models
