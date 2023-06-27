import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1

import utils 1.0
import shared.controls 1.0

import "../stores"

GridLayout {
    id: root

    property AddAccountStore store

    columns: 2
    columnSpacing: Style.current.padding
    rowSpacing: Style.current.halfPadding

    QtObject {
        id: d

        readonly property int oneHalfWidth: (root.width - root.columnSpacing) * 0.5
    }

    component ReadonlyInputWithCopyButton: StatusInput {
        id: comp
        required property string textToCopy

        input.edit.enabled: false
        input.edit.color: Theme.palette.baseColor1
        input.background.color: "transparent"
        input.background.border.color: Theme.palette.baseColor2
        input.rightComponent: CopyButton {
            textToCopy: comp.textToCopy
        }
    }

    StatusBaseText {
        Layout.fillWidth: true
        font.pixelSize: Constants.addAccountPopup.labelFontSize1
        text: qsTr("Derivation Path")
    }

    StatusBaseText {
        Layout.preferredWidth: d.oneHalfWidth
        font.pixelSize: Constants.addAccountPopup.labelFontSize1
        text: qsTr("Account")
    }

    ReadonlyInputWithCopyButton {
        Layout.preferredWidth: d.oneHalfWidth
        text: root.store.addAccountModule.derivationPath
        textToCopy: root.store.addAccountModule.derivationPath
    }

    ReadonlyInputWithCopyButton {
        Layout.preferredWidth: d.oneHalfWidth
        text: StatusQUtils.Utils.elideText(root.store.selectedDerivedAddress.address, 6, 8)
        textToCopy: root.store.selectedDerivedAddress.address
    }

    StatusBaseText {
        Layout.preferredWidth: d.oneHalfWidth
        font.pixelSize: Constants.addAccountPopup.labelFontSize2
        color: Theme.palette.baseColor1
        text: {
            if (root.store.addAccountModule.derivationPath.startsWith(Constants.addAccountPopup.predefinedPaths.ethereum)) {
                root.store.selectedRootPath = Constants.addAccountPopup.predefinedPaths.ethereum
            }
            else if (root.store.addAccountModule.derivationPath.startsWith(Constants.addAccountPopup.predefinedPaths.ethereumRopsten)) {
                root.store.selectedRootPath = Constants.addAccountPopup.predefinedPaths.ethereumRopsten
            }
            else if (root.store.addAccountModule.derivationPath.startsWith(Constants.addAccountPopup.predefinedPaths.ethereumLedger)) {
                root.store.selectedRootPath = Constants.addAccountPopup.predefinedPaths.ethereumLedger
            }
            else if (root.store.addAccountModule.derivationPath.startsWith(Constants.addAccountPopup.predefinedPaths.ethereumLedgerLive)) {
                root.store.selectedRootPath = Constants.addAccountPopup.predefinedPaths.ethereumLedgerLive
            }
            else {
                root.store.selectedRootPath = Constants.addAccountPopup.predefinedPaths.custom
            }

            return root.store.translation(root.store.selectedRootPath, true)
        }
    }
}
