import QtQuick
import QtQuick.Controls

import AppLayouts.Profile.popups.networkSettings

import Storybook
import Models

import StatusQ.Core
import StatusQ.Core.Utils

SplitView {
    orientation: Qt.Vertical

    QtObject {
        id: d

        property var networksModel: NetworksModel.flatNetworks
        property var network: ModelUtils.get(d.networksModel, 0)
    }

    Item {

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: popup.open()
        }
    }

    DeactivateNetworkPopup {
        id: popup
        anchors.centerIn: parent
        width: 556
        modal: false
        visible: true
        destroyOnClose: false

        chainId: d.network.chainId
        iconUrl: d.network.iconUrl
        chainName: d.network.chainName
    }
}

// category: Popups

// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/%E2%9A%99%EF%B8%8F-Settings-%7C-Desktop?node-id=25465-99580&m=dev
