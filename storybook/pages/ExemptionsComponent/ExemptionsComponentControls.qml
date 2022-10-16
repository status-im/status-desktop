import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

ListView {
    anchors.fill: parent

    // model: modelData

    delegate: Rectangle {
        width: parent.width
        height: column.implicitHeight

        ColumnLayout {
            id: column

            width: parent.width
            spacing: 2

            Label {
                text: "itemId"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: model.itemId
                onTextChanged: model.itemId = text
            }

            Label {
                text: "name"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: model.name
                onTextChanged: model.name = text
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                        Rectangle {
                            Image {
                                // anchors.fill: parent
                                anchors.margins: 1
                                fillMode: Image.PreserveAspectFit
                                source: model.image
                            }
                            MouseArea {
                                // anchors.fill: parent
                                onClicked: {
                                    imageSelector.open()
                                    StorybookUtils.singleShotConnection(imageSelector.selected, image => {
                                        model.image = image
                                        imageSelector.close()
                                    })
                                }
                            }
                        }
            }

            Label {
                text: "color"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: model.color
                onTextChanged: model.color = text
            }

            Label {
                text: "type"
                font.weight: Font.Bold
            }

            Flow {
                Layout.fillWidth: true

                CheckBox {
                    text: "community"
                    checked: model.type == 0
                    onToggled: model.type = 0
                }
                CheckBox {
                    text: "user"
                    checked: model.type == 1
                    onToggled: model.type = 1
                }
                CheckBox {
                    text: "group chat"
                    checked: model.type == 2
                    onToggled: model.type = 2
                }
            }

            Label {
                text: "customized"
                font.weight: Font.Bold
            }

            Flow {
                Layout.fillWidth: true

                CheckBox {
                    text: "customized"
                    checked: model.customized
                    onToggled: model.customized = !model.customized
                }
            }

            Label {
                text: "muteAllMessages"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: (model.muteAllMessages || "")
                onTextChanged: {
                    if (model.muteAllMessages == "") {
                        model.muteAllMessages = false
                        return
                    }
                    model.muteAllMessages = text
                }
            }

            Label {
                text: "personalMentions"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: (model.personalMentions || "")
                onTextChanged: {
                    if (model.personalMentions == "") {
                        model.personalMentions = false
                        return
                    }
                    model.personalMentions = text
                }
            }

            Label {
                text: "otherMessages"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: (model.otherMessages || "")
                onTextChanged: {
                    if (model.otherMessages == "") {
                        model.otherMessages = false
                        return
                    }
                    model.otherMessages = text
                }
            }

            Label {
                text: "ring"
                font.weight: Font.Bold
            }

            TextField {
                Layout.fillWidth: true
                text: (model.ring || "")
                onTextChanged: {
                    if (model.ring == "") {
                        model.ring = false
                        return
                    }
                    model.ring = text
                }
            }
        }
    }
}