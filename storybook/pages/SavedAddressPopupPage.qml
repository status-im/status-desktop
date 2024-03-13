import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import SortFilterProxyModel 0.2

import Storybook 1.0
import Models 1.0
import AppLayouts.Wallet.popups 1.0

import utils 1.0

SplitView {
    orientation: Qt.Horizontal

    PopupBackground {
        id: popupBg

        property var popupIntance: null

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"
            enabled: !dialog.visible

            onClicked: dialog.open()
        }

        AddEditSavedAddressPopup {
            id: dialog

            visible: true
            flatNetworks: SortFilterProxyModel {
                sourceModel: NetworksModel.flatNetworks
                filters: ValueFilter { roleName: "isTest"; value: false }
            }

            store: QtObject {
                property var savedAddressNameExists: function() { return false }
            }

            // Emulate resoling ENS by simple validation
            QtObject {
                id: mainModule

                function resolveENS(name, uuid) {
                    if (Utils.isValidEns(name)) {
                        resolvedENS("", "0x1234567890123456789012345678901234567890", uuid)
                    }
                    else {
                        resolvedENS("", "", uuid)
                    }
                }

                signal resolvedENS(string pubkey, string address, string uuid)
            }

            Component.onCompleted: initWithParams()
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300
    }
}

// category: Popups

// https://www.figma.com/file/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?type=design&node-id=23256-263282&mode=design&t=0DRwQJKDGYJPHkq1-4
