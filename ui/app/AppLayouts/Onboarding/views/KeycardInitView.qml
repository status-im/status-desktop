import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../stores"

Item {
    id: root

    property KeycardStore keycardStore

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
        }
    }

    states: [
        State {
            name: Constants.keycard.state.pluginKeycardState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.pluginKeycardState
            PropertyChanges {
                target: title
                text: qsTrId("Plug in Keycard reader...")
                font.pixelSize: Constants.keycard.general.titleFontSize1
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycard.state.insertKeycardState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.insertKeycardState
            PropertyChanges {
                target: title
                text: qsTrId("Insert your Keycard...")
                font.pixelSize: Constants.keycard.general.titleFontSize1
                color: Theme.palette.directColor1
            }
        },
        State {
            name: Constants.keycard.state.readingKeycardState
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.readingKeycardState
            PropertyChanges {
                target: title
                text: qsTr("Reading Keycard...")
                font.pixelSize: Constants.keycard.general.titleFontSize2
                color: Theme.palette.baseColor1
            }
        }
    ]
}
