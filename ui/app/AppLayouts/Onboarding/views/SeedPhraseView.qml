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

    ColumnLayout {
        anchors.centerIn: parent
        height: Constants.onboarding.loginHeight
        spacing: Style.current.bigPadding

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
            font.pixelSize: Constants.keycard.general.fontSize2
            color: Theme.palette.dangerColor1
            horizontalAlignment: Qt.AlignHCenter
            text: qsTr("You will need this to recover your Keycard if you lose\nyour PIN or if the wrong PIN is entered five times in a row.")
        }

        GridLayout {
            id: grid
            Layout.alignment: Qt.AlignHCenter
            columns: d.numOfColumns
            rowSpacing: d.rowSpacing
            columnSpacing: d.columnSpacing
            height: Constants.keycard.general.seedPhraseHeight
            width: Constants.keycard.general.seedPhraseWidth

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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        StatusButton {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Next")
            focus: true
            onClicked: {
                root.startupStore.doPrimaryAction()
            }
        }
    }
}
