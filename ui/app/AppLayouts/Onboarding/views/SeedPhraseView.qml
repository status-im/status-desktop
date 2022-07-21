import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        let seedPhrase = root.startupStore.getSeedPhrase()
        if(seedPhrase.length === 0)
            return

        d.seedPhraseModel = seedPhrase.split(" ")
    }

    QtObject {
        id: d

        property var seedPhraseModel: []
        readonly property int numOfColumns: 4
        readonly property int rowSpacing: Style.current.bigPadding
        readonly property int columnSpacing: Style.current.bigPadding
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true
            root.startupStore.doPrimaryAction()
        }
    }

    Item {
        anchors.top: parent.top
        anchors.bottom: footerWrapper.top
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Style.current.padding

            StatusBaseText {
                id: title
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.fontSize1
                font.weight: Font.Bold
                color: Theme.palette.directColor1
                text: qsTr("Write down your seed phrase")
            }

            StatusBaseText {
                id: info
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.fontSize3
                color: Theme.palette.dangerColor1
                horizontalAlignment: Qt.AlignHCenter
                text: qsTr("You will need this to recover your Keycard if you loose\nyour PIN of if the wrong PIN is entered five times in a row.")
            }

            GridLayout {
                id: grid
                Layout.alignment: Qt.AlignHCenter
                columns: d.numOfColumns
                rowSpacing: d.rowSpacing
                columnSpacing: d.columnSpacing

                Repeater {
                    model: d.seedPhraseModel
                    delegate: Item {
                        Layout.preferredWidth: Constants.keycard.general.seedPhraseCellWidth
                        Layout.preferredHeight: Constants.keycard.general.seedPhraseCellHeight
                        StatusBaseText {
                            id: wordNumber
                            width: Constants.keycard.general.seedPhraseCellNumberWidth
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Qt.AlignRight
                            font.pixelSize: Constants.keycard.general.seedPhraseCellFontSize
                            color: Theme.palette.directColor1
                            text: "%1.".arg(model.index + 1)
                        }

                        StatusBaseText {
                            id: word
                            anchors.left: wordNumber.right
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: Style.current.xlPadding
                            horizontalAlignment: Qt.AlignLeft
                            font.pixelSize: Constants.keycard.general.seedPhraseCellFontSize
                            color: Theme.palette.directColor1
                            text: model.modelData
                        }
                    }
                }
            }
        }
    }

    Item {
        id: footerWrapper
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Constants.keycard.general.footerWrapperHeight

        StatusButton {
            anchors.top: parent.top
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Next")
            focus: true
            onClicked: {
                root.startupStore.doPrimaryAction()
            }
        }
    }
}
