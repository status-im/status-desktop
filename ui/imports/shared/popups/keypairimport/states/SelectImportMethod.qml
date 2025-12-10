import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Components

import utils

import SortFilterProxyModel

import "../stores"

Item {
    id: root

    property KeypairImportStore store

    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("Import method")
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.baseColor1
        }

        StatusListItem {
            title: qsTr("Import via scanning encrypted QR")

            asset {
                width: 24
                height: 24
                name: "qr"
            }

            components: [
                StatusIcon {
                    icon: "next"
                    color: Theme.palette.baseColor1
                    StatusMouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.store.currentState.doPrimaryAction()
                        }
                    }
                }
            ]

            onClicked: {
                root.store.currentState.doPrimaryAction()
            }
        }

        StatusListItem {
            title: root.store.selectedKeypair.pairType === Constants.keypair.type.seedImport?
                       qsTr("Import via entering recovery phrase") :
                       qsTr("Import via entering private key")

            asset {
                width: 24
                height: 24
                name: root.store.selectedKeypair.pairType === Constants.keypair.type.seedImport?
                          "key_pair_seed_phrase" :
                          "objects"
            }

            components: [
                StatusIcon {
                    icon: "next"
                    color: Theme.palette.baseColor1
                    StatusMouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.store.currentState.doSecondaryAction()
                        }
                    }
                }
            ]

            onClicked: {
                root.store.currentState.doSecondaryAction()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
