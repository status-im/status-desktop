import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import shared.popups.keycard.helpers 1.0
import shared.status 1.0

import utils 1.0

import SortFilterProxyModel 0.2

import "../stores"

Item {
    id: root

    property KeypairImportStore store

    implicitHeight: layout.implicitHeight

    QtObject {
        id: d

        readonly property string fullyOperableValue: Constants.keypair.operability.fullyOperable
        readonly property string partiallyOperableValue: Constants.keypair.operability.partiallyOperable
        readonly property string profileTypeValue: Constants.keypair.type.profile
        readonly property int margin: 16

        function importKeypairs() {
            root.store.currentState.doSecondaryAction()
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: d.margin
            Layout.rightMargin: d.margin
            text: qsTr("To use the associated accounts on this device, you need to import their keypairs.")
            wrapMode: Text.WordWrap
        }

        StatusSectionHeadline {
            Layout.fillWidth: true
            Layout.leftMargin: d.margin
            Layout.rightMargin: d.margin
            text: qsTr("Import keypairs from your other device")
        }

        StatusListItem {
            title: qsTr("Import via scanning encrypted QR")
            asset {
                width: 24
                height: 24
                name: "qr"
            }

            onClicked: {
                d.importKeypairs()
            }

            components: [
                StatusIcon {
                    icon: "next"
                    color: Theme.palette.baseColor1
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            d.importKeypairs()
                        }
                    }
                }
            ]

        }

        StatusSectionHeadline {
            Layout.fillWidth: true
            Layout.leftMargin: d.margin
            Layout.rightMargin: d.margin
            text: qsTr("Import individual keys")
        }

        KeyPairList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft

            disableSelectionForKeypairsWithNonDefaultDerivationPath: false
            displayRadioButtonForSelection: false
            useTransparentItemBackgroundColor: true

            modelFilters: ExpressionFilter {
                expression: model.keyPair.migratedToKeycard ||
                            model.keyPair.pairType == d.profileTypeValue  ||
                            model.keyPair.operability == d.fullyOperableValue ||
                            model.keyPair.operability == d.partiallyOperableValue
                inverted: true
            }
            keyPairModel: root.store.keypairImportModule.keypairModel

            onKeyPairSelected: {
                root.store.keypairImportModule.setSelectedKeyPair(keyUid)
                root.store.currentState.doPrimaryAction()
            }
        }
    }
}
