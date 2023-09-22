import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Components 0.1

import utils 1.0

StatusDialog {
    id: root

    property int mode: TransferOwnershipAlertPopup.Mode.TransferOwnership

    // Community related props:
    required property string communityName
    required property string communityLogo

    signal mintClicked
    signal cancelClicked

    enum Mode {
        TransferOwnership,
        MoveControlNode
    }

    QtObject {
        id: d

        readonly property string headerTitle: (root.mode === TransferOwnershipAlertPopup.Mode.TransferOwnership) ?
                                                  qsTr("Transfer ownership of %1").arg(root.communityName) :
                                                  qsTr("How to move the %1 control node to another device").arg(root.communityName)
        readonly property string alertText: (root.mode === TransferOwnershipAlertPopup.Mode.TransferOwnership) ?
                                                qsTr("<b>It looks like you haven’t minted the %1 Owner token yet.</b> Once you have minted this token, you can transfer ownership of %1 by sending the Owner token to the account of the person you want to be the new Community owner.").arg(root.communityName) :
                                                qsTr("<b>It looks like you haven’t minted the %1 Owner token yet.</b> Once you have minted this token, you can make one of your other synced desktop devices the control node for the %1 Community.").arg(root.communityName)
    }

    width: 640 // by design
    padding: Style.current.padding
    contentItem: StatusBaseText {
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: d.alertText
        lineHeight: 1.2
    }

    header: StatusDialogHeader {
        headline.title: d.headerTitle
        actions.closeButton.onClicked: root.close()
        leftComponent: StatusSmartIdenticon {
            asset.name: root.communityLogo
            asset.isImage: !!asset.name
        }
    }

    footer: StatusDialogFooter {
        spacing: Style.current.padding
        rightButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")

                onClicked: {
                    root.cancelClicked()
                    close()
                }
            }

            StatusButton {
                text: qsTr("Mint %1 Owner token").arg(root.communityName)
                type: StatusBaseButton.Type.Normal

                onClicked: {
                    root.mintClicked()
                    close()
                }
            }
        }
    }
}
