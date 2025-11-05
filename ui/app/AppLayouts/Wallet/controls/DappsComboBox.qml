import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import utils
import shared.controls
import shared.popups.walletconnect
import shared.popups.walletconnect.controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Components.private as SQP

ComboBox {
    id: root

    signal dappListRequested()
    signal connectDapp()
    signal disconnectDapp(string dappUrl)
    signal dappClicked(string dappUrl)

    property bool showConnectButton: true
    property bool dappClickable: true

    implicitHeight: 38
    implicitWidth: 38

    background: SQP.StatusComboboxBackground {
        objectName: "dappsBackground"
        active: root.down || root.hovered
        Binding on color {
            when: !root.enabled
            value: Theme.palette.baseColor2
        }
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
            visible: root.delegateModel && root.delegateModel.count > 0
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
        clickable: root.dappClickable

        onDisconnectDapp: (dappUrl) => {
            root.disconnectDapp(dappUrl)
        }
        
        onDappClicked: (dappUrl) => {
            root.dappClicked(dappUrl)
        }
    }

    popup: DAppsListPopup {
        objectName: "dappsListPopup"

        directParent: root
        relativeX: {
            const globalX = root.mapToGlobal(root.width / 2, 0).x
            if (globalX < root.Window.width / 2)
               return 0

            return root.width - width
        }
        relativeY: root.height + 4

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        delegateModel: root.delegateModel
        showConnectButton: root.showConnectButton

        onConnectDapp: {
            root.connectDapp()
            this.close()
        }

        onOpened: {
            root.dappListRequested()
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
