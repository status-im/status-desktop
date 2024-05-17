import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet 1.0

import utils 1.0
import shared.controls 1.0

StatusDialog {
    id: root

    property string name
    property string address
    property string ens
    property string colorId
    property string chainShortNames

    signal removeSavedAddress(string address)

    width: 521
    focus: visible
    padding: Style.current.padding

    QtObject {
        id: d

        readonly property real lineHeight: 1.2

        function confirm() {
            root.removeSavedAddress(root.address)
        }
    }

     header: StatusDialogHeader {
        headline.title: qsTr("Remove %1").arg(root.name)
        headline.subtitle: {
            if (root.ens.length > 0)
                return root.ens

            return WalletUtils.colorizedChainPrefix(root.chainShortNames) + Utils.richColorText(StatusQUtils.Utils.elideText(root.address, 6, 4), Theme.palette.directColor1)
        }
        actions.closeButton.onClicked: root.close()

        leftComponent: StatusSmartIdenticon {
            name: root.name
            asset {
                color: Utils.getColorForId(root.colorId)
                isLetterIdenticon: true
                useAcronymForLetterIdenticon: true
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: Style.current.halfPadding

        StatusBaseText {
            objectName: "RemoveSavedAddressPopup-Notification"
            Layout.preferredWidth: parent.width
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            font.pixelSize: Style.current.primaryTextFontSize
            lineHeight: d.lineHeight
            text: qsTr("Are you sure you want to remove %1 from your saved addresses? Transaction history relating to this address will no longer be labelled %1.").arg("<b>%1</b>".arg(root.name))
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                objectName: "RemoveSavedAddressPopup-CancelButton"
                text: qsTr("Cancel")
                type: StatusBaseButton.Type.Normal
                onClicked: {
                    root.close()
                }
            }
            StatusButton {
                objectName: "RemoveSavedAddressPopup-ConfirmButton"
                text: qsTr("Remove saved address")
                type: StatusBaseButton.Type.Danger
                focus: true
                Keys.onReturnPressed: function(event) {
                    d.confirm()
                }
                onClicked: {
                    d.confirm()
                }
            }
        }
    }
}
