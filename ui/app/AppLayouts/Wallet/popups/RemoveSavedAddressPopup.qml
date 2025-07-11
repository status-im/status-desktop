import QtQuick
import QtQuick.Controls
import QtQml.Models
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core.Utils as StatusQUtils
import StatusQ.Controls
import StatusQ.Popups.Dialog

import AppLayouts.Wallet

import utils
import shared.controls

StatusDialog {
    id: root

    property string name
    property string address
    property string ens
    property string colorId

    signal removeSavedAddress(string address)

    width: 521
    focus: visible
    padding: Theme.padding

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

            return Utils.richColorText(StatusQUtils.Utils.elideText(root.address, 6, 4), Theme.palette.directColor1)
        }
        actions.closeButton.onClicked: root.close()

        leftComponent: StatusSmartIdenticon {
            name: root.name
            asset {
                color: Utils.getColorForId(root.colorId)
                isLetterIdenticon: true
                letterIdenticonBgWithAlpha: true
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: Theme.halfPadding

        StatusBaseText {
            objectName: "RemoveSavedAddressPopup-Notification"
            Layout.preferredWidth: parent.width
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: d.lineHeight
            text: qsTr("Are you sure you want to remove %1 from your saved addresses? Transaction history relating to this address will no longer be labelled %1.").arg("<b>%1</b>".arg(root.name))
        }
    }

    footer: StatusDialogFooter {
        spacing: Theme.padding
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
