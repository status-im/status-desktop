import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1

import shared.popups.keycard.helpers 1.0

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
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        StatusBaseText {
            Layout.fillWidth: true
            text: qsTr("To use the associated accounts on this device, you need to import their keypairs.")
            font.pixelSize: Constants.keypairImportPopup.labelFontSize1
            wrapMode: Text.WordWrap
        }

        KeyPairList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft

            optionLabel: qsTr("import")
            disableSelectionForKeypairsWithNonDefaultDerivationPath: false
            displayRadioButtonForSelection: false
            modelFilters: ExpressionFilter {
                expression: model.keyPair.migratedToKeycard ||
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
