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

    property KeycardStore keycardStore

    Item {
        anchors.top: parent.top
        anchors.bottom: footerWrapper.top
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Style.current.padding

            Image {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: sourceSize.height
                Layout.preferredWidth: sourceSize.width
                fillMode: Image.PreserveAspectFit
                antialiasing: true
                source: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLocked?
                            Style.svg("keycard/card-error3@2x") :
                            Style.svg("keycard/card3@2x")
                mipmap: true
            }

            StatusBaseText {
                id: title
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.titleFontSize1
                font.weight: Font.Bold
            }

            StatusBaseText {
                id: info
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Constants.keycard.general.infoFontSize
                wrapMode: Text.WordWrap
            }
        }
    }

    Item {
        id: footerWrapper
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Constants.keycard.general.footerWrapperHeight

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Style.current.bigPadding

            StatusButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Factory reset")
                focus: true
                onClicked: {
                    keycardStore.factoryReset()
                }
            }

            StatusBaseText {
                id: keycardLink
                Layout.alignment: Qt.AlignHCenter
                color: Theme.palette.primaryColor1
                font.pixelSize: Constants.keycard.general.buttonFontSize
                text: qsTr("Insert another Keycard")
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.font.underline = false
                    }
                    onClicked: {
                        keycardStore.switchCard();
                    }
                }
            }
        }
    }

    states: [
        State {
            name: Constants.keycard.state.keycardNotEmpty
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardNotEmpty
            PropertyChanges {
                target: title
                text: qsTrId("This Keycard already stores keys")

            }
            PropertyChanges {
                target: info
                text: qsTr("To generate new keys, you will need to perform a factory reset first")
            }
        },
        State {
            name: Constants.keycard.state.keycardLocked
            when: keycardStore.keycardModule.flowState === Constants.keycard.state.keycardLocked
            PropertyChanges {
                target: title
                text: qsTr("Keycard locked and already stores keys")
            }
            PropertyChanges {
                target: info
                text: qsTr("The Keycard you have inserted is locked, you will need to factory reset it before proceeding")
            }
        }
    ]
}
