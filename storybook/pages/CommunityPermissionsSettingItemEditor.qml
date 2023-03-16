import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

ColumnLayout {
    id: root

    property string panelText
    property string name
    property string icon
    property string amountText
    property string emoji
    property bool isAmountVisible: false
    property bool isImageSelectorVisible: true
    property bool isEmojiSelectorVisible: false
    property var iconsModel

    Label {
        Layout.fillWidth: true
        text: root.panelText
        font.weight: Font.Bold
    }

    RowLayout {
        Rectangle {
            id: image
            visible: root.isImageSelectorVisible
            border.color: 'lightgrey'
            radius: 16
            Layout.preferredHeight: 50
            Layout.preferredWidth: 50

            Image {
                anchors.fill: parent
                anchors.margins: 1
                fillMode: Image.PreserveAspectFit
                source: root.icon
            }

            MouseArea {
                anchors.fill: parent
                onClicked: iconSelector.open()

                ImageSelectPopup {
                    id: iconSelector

                    parent: root
                    anchors.centerIn: parent
                    width: 200
                    height: 250

                    model: root.iconsModel

                    onSelected: {
                        root.icon = icon
                        close()
                    }
                }
            }
        }

        ColumnLayout {
            Label {
                Layout.fillWidth: true
                text: "Name"
            }
            TextField {
                background: Rectangle {
                    radius: 16
                    border.color: 'lightgrey'
                }
                Layout.fillWidth: true
                text: root.name
                onTextChanged: root.name = text
            }
        }

        ColumnLayout {
            visible: root.isAmountVisible
            Label {
                Layout.fillWidth: true
                text: "Amount"
            }
            TextField {
                background: Rectangle {
                    radius: 16
                    border.color: 'lightgrey'
                }
                Layout.fillWidth: true
                text: root.amountText
                onTextChanged: root.amountText = text
            }
        }

        ColumnLayout {
            visible: root.isEmojiSelectorVisible
            Label {
                Layout.fillWidth: true
                text: "Emoji"
            }
            TextField {
                background: Rectangle {
                    radius: 16
                    border.color: 'lightgrey'
                }
                Layout.fillWidth: true
                text: root.emoji
                onTextChanged: root.emoji = text
            }
        }
    }
}
