import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import shared.controls 1.0
import shared.popups.walletconnect 1.0
import shared.popups.walletconnect.controls 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Components.private 0.1 as SQP


ComboBox {
    id: root

    signal dappsListReady
    signal pairDapp

    implicitHeight: 38
    implicitWidth: 38

    background: SQP.StatusComboboxBackground {
        objectName: "dappsBackground"
        active: root.down || root.hovered
    }

    indicator: null

    contentItem: Item {
        objectName: "dappsContentItem"
        StatusBadge {
            objectName: "dappBadge"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 5
            width: 6
            height: 6
            visible: root.delegateModel.count > 0
        }

        StatusIcon {
            objectName: "dappIcon"
            anchors.centerIn: parent
            width: 16
            height: 16
            icon: "dapp"
            color: Theme.palette.baseColor1
        }
    }

    delegate: DAppDelegate {
        width: ListView.view.width
    }

    popup: DAppsListPopup {
        objectName: "dappsListPopup"
        
        x: root.width - width
        y: root.height + 4

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        delegateModel: root.delegateModel

        onPairWCDapp: {
            root.pairDapp()
            this.close()
        }

        onOpened: {
            root.dappsListReady()
        }
    }

    StatusToolTip {
        id: tooltip
        objectName: "dappTooltip"
        visible: root.hovered && !root.down
        text: qsTr("dApp connections")
        orientation: StatusToolTip.Orientation.Bottom
        y: root.height + 14
    }
}
