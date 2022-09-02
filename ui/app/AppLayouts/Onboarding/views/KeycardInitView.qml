import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    QtObject {
        id: d

        property int index: 0
        property variant images : [
            Style.svg("keycard/card0@2x"),
            Style.svg("keycard/card1@2x"),
            Style.svg("keycard/card2@2x"),
            Style.svg("keycard/card3@2x")
        ]
    }

    Timer {
        interval: 400
        running: true
        repeat: true
        onTriggered: {
            d.index++
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.current.padding

        Image {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: sourceSize.height
            Layout.preferredWidth: sourceSize.width
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            source: d.images[d.index % d.images.length]
            mipmap: true
        }

        StatusBaseText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            font.weight: Font.Bold
            wrapMode: Text.WordWrap
        }

        StatusBaseText {
            id: info
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    states: [
        State {
            name: Constants.startupState.keycardPluginReader
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardPluginReader
            PropertyChanges {
                target: title
                text: qsTr("Plug in Keycard reader...")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: info
                visible: false
            }
        },
        State {
            name: Constants.startupState.keycardInsertKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardInsertKeycard
            PropertyChanges {
                target: title
                text: qsTr("Insert your Keycard...")
                font.pixelSize: Constants.keycard.general.fontSize1
                color: Theme.palette.directColor1
            }
            PropertyChanges {
                target: info
                visible: root.startupStore.startupModuleInst.keycardData !== ""
                text: qsTr("Check the card, it might be wrongly inserted")
                font.pixelSize: Constants.keycard.general.fontSize3
                color: Theme.palette.baseColor1
            }
        },
        State {
            name: Constants.startupState.keycardReadingKeycard
            when: root.startupStore.currentStartupState.stateType === Constants.startupState.keycardReadingKeycard
            PropertyChanges {
                target: title
                text: qsTr("Reading Keycard...")
                font.pixelSize: Constants.keycard.general.fontSize2
                color: Theme.palette.baseColor1
            }
            PropertyChanges {
                target: info
                visible: false
            }
        }
    ]
}
