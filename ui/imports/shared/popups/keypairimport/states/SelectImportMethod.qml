import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

import SortFilterProxyModel 0.2

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
            font.pixelSize: Constants.keypairImportPopup.labelFontSize1
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
                    MouseArea {
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
                       qsTr("Import via entering seed phrase") :
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
                    MouseArea {
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
