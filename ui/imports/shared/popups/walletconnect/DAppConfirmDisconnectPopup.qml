import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtQml.Models 2.15

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    objectName: "dappConfirmDisconnectPopup"

    property string dappName
    property url dappIcon
    property string dappUrl

    implicitWidth: 640

    contentItem: StatusBaseText {
        text: qsTr("Are you sure you want to disconnect %1 from all accounts?").arg(StringUtils.extractDomainFromLink(dappUrl))

        wrapMode: Text.WrapAnywhere
    }

    header: StatusDialogHeader {
        leftComponent: StatusRoundedImage {
            height: 40
            width: height

            image.source: root.dappIcon
        }
        headline.title: qsTr("Disconnect %1").arg(root.dappName)
        headline.subtitle: StringUtils.extractDomainFromLink(root.dappUrl)
        actions.closeButton.visible: true
        actions.closeButton.onClicked: root.close()
    }

    footer: StatusDialogFooter {
        spacing: 16
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")
                onClicked: root.reject();
            }
            StatusButton {
                type: StatusButton.Danger
                text: qsTr("Disconnect dApp")
                icon.name: "disconnect"
                onClicked: {
                    root.accepted();
                    root.close();
                }
            }
        }
    }
}
