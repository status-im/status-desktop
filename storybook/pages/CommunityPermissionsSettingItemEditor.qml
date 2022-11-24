import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0
import Models 1.0

ColumnLayout {
    id: root

    property string panelText
    property string name
    property url icon
    property double amount
    property bool isAmountVisible: false
    property bool isENS
    property bool isENSVisible: false
    property bool isExpression: false
    property bool isAnd: true

    Label {
        Layout.fillWidth: true
        text: root.panelText
        font.weight: Font.Bold
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 50

        Rectangle {
            border.color: 'gray'
            Layout.fillWidth: true
            Layout.fillHeight: true

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
                    width: parent.width * 0.8
                    height: parent.height * 0.8

                    model: IconModel {}

                    onSelected: {
                        root.icon = icon
                        close()
                    }
                }
            }
        }
    }

    ColumnLayout {
        Label {
            Layout.fillWidth: true
            text: "Type"
        }
        TextField {
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
            Layout.fillWidth: true
            text: root.amount
            onTextChanged: root.amount = text
        }
    }

    CheckBox {
        visible: root.isENSVisible
        text: "Is ENS name"
        checked: root.isENS
        onToggled: root.isENS = checked
    }

    Switch {
        visible: root.isExpression
        text: "OR -- AND"
        checked: root.isAnd
        onToggled: root.isAnd = checked
    }

    Button {
        Layout.fillWidth: true
        text: "Add"
    }
}
