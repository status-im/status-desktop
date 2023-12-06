import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../panels"
import "../popups"
import "../stores"

ActivityNotificationBase {
    id: root

    required property string communityName
    required property string communityColor
    required property int type // Possible values [OwnershipState]

    signal finaliseOwnershipClicked
    signal navigateToCommunityClicked

    function setType(notification) {
        if(notification)
            switch(notification.notificationType){

            case ActivityCenterStore.ActivityCenterNotificationType.OwnerTokenReceived:
                return ActivityNotificationTransferOwnership.OwnershipState.Pending

            case ActivityCenterStore.ActivityCenterNotificationType.OwnershipDeclined:
                return ActivityNotificationTransferOwnership.OwnershipState.Declined

            case ActivityCenterStore.ActivityCenterNotificationType.OwnershipReceived:
                return ActivityNotificationTransferOwnership.OwnershipState.Succeeded

            case ActivityCenterStore.ActivityCenterNotificationType.OwnershipFailed:
                return ActivityNotificationTransferOwnership.OwnershipState.Failed

            case ActivityCenterStore.ActivityCenterNotificationType.OwnershipLost:
                return ActivityNotificationTransferOwnership.OwnershipState.NoLongerControlNode

            }
        return ActivityNotificationTransferOwnership.OwnershipState.Failed
    }

    enum OwnershipState {
        Pending,
        Declined,
        Succeeded,
        Failed,
        NoLongerControlNode
    }

    QtObject {
        id: d

        property string title: ""
        property string info: ""
        property string assetColor: ""
        property string assetName: ""
        property string assetBgColor: ""
        property string ctaText: ""
        property var actionSourceComponent: undefined

        readonly property string crownAssetName: "crown"
    }

    bodyComponent: RowLayout {
        spacing: 8

        StatusSmartIdenticon {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            Layout.leftMargin: Style.current.padding
            Layout.topMargin: 2

            asset {
                width: 24
                height: width
                name: d.assetName
                color: d.assetColor
                bgWidth: 40
                bgHeight: 40
                bgColor: d.assetBgColor
            }
        }

        ColumnLayout {
            spacing: 2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            StatusMessageHeader {
                Layout.fillWidth: true
                displayNameLabel.text: d.title
                timestamp: root.notification.timestamp
            }

            RowLayout {
                spacing: Style.current.padding

                StatusBaseText {
                    Layout.fillWidth: true
                    text: d.info
                    font.italic: true
                    wrapMode: Text.WordWrap
                    color: Theme.palette.baseColor1
                }

                Loader { sourceComponent: d.actionSourceComponent }

            }
        }
    }

    ctaComponent: undefined

    states: [
        State {
            when: root.type === ActivityNotificationTransferOwnership.OwnershipState.Pending
            PropertyChanges {
                target: d
                title: qsTr("You received the owner token from %1").arg(root.communityName)
                info: qsTr("To finalise your ownership of the %1 Community, make your device the control node").arg(root.communityName)
                ctaText: qsTr("Finalise ownership")
                assetColor: root.communityColor
                assetBgColor: Theme.palette.getColor(d.assetColor, 0.1)
                assetName: d.crownAssetName
                actionSourceComponent: ctaFlatBtnComponent
            }
        },
        State {
            when: root.type === ActivityNotificationTransferOwnership.OwnershipState.Declined
            PropertyChanges {
                target: d
                title: qsTr("You received the owner token from %1").arg(root.communityName)
                info: qsTr("To finalise your ownership of the %1 Community, make your device the control node").arg(root.communityName)
                ctaText: qsTr("Ownership Declined")
                assetColor: root.communityColor
                assetBgColor: Theme.palette.getColor(d.assetColor, 0.1)
                assetName: d.crownAssetName
                actionSourceComponent: ctaTextComponent
            }
        },
        State {
            when: root.type === ActivityNotificationTransferOwnership.OwnershipState.Succeeded
            PropertyChanges {
                target: d
                title: qsTr("Your device is now the control node for %1").arg(root.communityName)
                info: qsTr("Congratulations, you are now the official owner of the %1 Community with full admin rights").arg(root.communityName)
                ctaText: qsTr("Community admin")
                assetColor: root.communityColor
                assetBgColor: Theme.palette.getColor(d.assetColor, 0.1)
                assetName: d.crownAssetName
                actionSourceComponent: ctaFlatBtnComponent
            }
        },
        State {
            when: root.type === ActivityNotificationTransferOwnership.OwnershipState.Failed
            PropertyChanges {
                target: d
                title: qsTr("%1 smart contract update failed").arg(root.communityName)
                info: qsTr("You will need to retry the transaction in order to finalise your ownership of the %1 community").arg(root.communityName)
                ctaText: qsTr("Finalise ownership")
                assetColor: Theme.palette.dangerColor1
                assetBgColor: Theme.palette.dangerColor3
                assetName: "warning"
                actionSourceComponent: ctaFlatBtnComponent
            }
        },
        State {
            when: root.type === ActivityNotificationTransferOwnership.OwnershipState.NoLongerControlNode
            PropertyChanges {
                target: d
                title: qsTr("Your device is no longer the control node for %1").arg(root.communityName)
                info: qsTr("Your ownership and admin rights for %1 have been removed and transferred to the new owner").arg(root.communityName)
                ctaText: ""
                assetColor: Theme.palette.dangerColor1
                assetBgColor: Theme.palette.dangerColor3
                assetName: "crown-off"
                actionSourceComponent: undefined
            }
        }
    ]

    Component {
        id: ctaFlatBtnComponent

        StatusFlatButton {
            size: StatusBaseButton.Size.Small
            text: d.ctaText
            onClicked: {
                if((root.type === ActivityNotificationTransferOwnership.OwnershipState.Pending) ||
                   (root.type === ActivityNotificationTransferOwnership.OwnershipState.Failed))
                    root.finaliseOwnershipClicked()
                else if(root.type === ActivityNotificationTransferOwnership.OwnershipState.Succeeded)
                    root.navigateToCommunityClicked()
            }
        }
    }

    Component {
        id: ctaTextComponent

        StatusBaseText {
            text: d.ctaText
            font.pixelSize: Style.current.additionalTextSize
            color: Theme.palette.dangerColor1
            padding: 10
        }
    }
}
