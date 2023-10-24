import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1

Item {
    id: root

    readonly property var colors: [
        "red", "green", "purple", "orange","gray", "ping", "brown", "blue"
    ]

    ListModel {
        id: leftModel

        ListElement {
            title: "Token 1"
            communityId: "1"
        }
        ListElement {
            title: "Token 2"
            communityId: "1"
        }
        ListElement {
            title: "Token 3"
            communityId: "2"
        }
        ListElement {
            title: "Token 4"
            communityId: "3"
        }
        ListElement {
            title: "Token 5"
            communityId: ""
        }
        ListElement {
            title: "Token 6"
            communityId: "1"
        }
    }

    ListModel {
        id: rightModel

        ListElement {
            communityId: "1"
            name: "Community 1"
            color: "red"

        }
        ListElement {
            communityId: "2"
            name: "Community 2"
            color: "green"
        }
        ListElement {
            communityId: "3"
            name: "Community 3"
            color: "blue"
        }
    }

    LeftJoinModel {
        id: leftJoinModel

        leftModel: leftModel
        rightModel: rightModel

        joinRole: "communityId"
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

                    model: leftModel

                    header: Label {
                        height: implicitHeight * 2
                        text: `Left model (${leftModel.count})`

                        font.bold: true

                        verticalAlignment: Text.AlignVCenter
                    }

                    ScrollBar.vertical: ScrollBar {}

                    delegate: Label {
                        width: ListView.view.width

                        text: `${model.title}, community id: ${model.communityId || "-"}`
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                border.color: "gray"

                ListView {
                    anchors.fill: parent

                    model: rightModel

                    header: Label {
                        height: implicitHeight * 2
                        text: `Right model (${rightModel.count})`

                        font.bold: true

                        verticalAlignment: Text.AlignVCenter
                    }

                    ScrollBar.vertical: ScrollBar {}

                    delegate: RowLayout {
                        width: ListView.view.width - 10

                        Label {
                            Layout.fillWidth: true

                            text: `${model.name}, community id: ${model.communityId}`
                        }

                        Rectangle {
                            Layout.preferredWidth: parent.height
                            Layout.preferredHeight: parent.height

                            color: model.color

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    const colorIndex = root.colors.indexOf(
                                                         model.color)
                                    const nextIndex = (colorIndex + 1)
                                                    % root.colors.length

                                    rightModel.setProperty(index, "color",
                                                           root.colors[nextIndex])
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                border.color: "gray"

                ListView {
                    id: leftJoinListView

                    anchors.fill: parent

                    model: leftJoinModel

                    header: Label {
                        height: implicitHeight * 2
                        text: `Left Join model (${leftJoinListView.count})`

                        font.bold: true

                        verticalAlignment: Text.AlignVCenter
                    }

                    ScrollBar.vertical: ScrollBar {}

                    delegate: RowLayout {
                        id: row

                        width: ListView.view.width - 10

                        readonly property bool hasCommunity: model.communityId.length

                        Label {
                            Layout.fillWidth: true

                            text: model.title + (row.hasCommunity
                                  ? `, community id: ${model.communityId}, name: ${model.name}`
                                  : "")
                        }

                        Rectangle {
                            Layout.preferredWidth: parent.height
                            Layout.preferredHeight: parent.height

                            color: model.color || "transparent"
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                text: "Left model count: " + leftModel.count
            }

            Label {
                text: "Right model count: " + rightModel.count
            }

            Button {
                text: "add 100 left model items"

                onClicked: {
                    for (let i = 0; i < 100; i++) {

                        const count = leftModel.count

                        const entry = {
                            title: "Token " + (count + 1),
                            communityId: (Math.floor(Math.random() * rightModel.count) + 1).toString()
                        }

                        leftModel.append(entry)
                    }
                }
            }

            Button {
                text: "add 10 right model items"

                onClicked: {
                    for (let i = 0; i < 10; i++) {
                        const count = rightModel.count

                        const entry = {
                            communityId: count.toString(),
                            name: "Community " + count,
                            color: root.colors[Math.floor(Math.random() * colors.length)]
                        }

                        rightModel.append(entry)
                    }
                }
            }

            Button {
                text: "shuffle"

                onClicked: {
                    const count = leftModel.count
                    const iterations = count / 2

                    for (let i = 0; i < iterations; i++) {
                        leftModel.move(Math.floor(Math.random() * (count - 1)),
                                       Math.floor(Math.random() * (count - 1)),
                                       Math.floor(Math.random() * 2) + 1)
                    }
                }
            }
        }
    }
}

// category: Models
