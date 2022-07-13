import QtQuick 2.13
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import StatusQ.Core 0.1

import utils 1.0

import shared 1.0
import "../stores"
import "../controls"

Item {
    property var account

    height: assetListView.height

    StatusScrollView {
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: assetListView.contentHeight > assetListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            id: assetListView
            anchors.fill: parent
            model: account.assets
            delegate: AssetDelegate {
                locale: RootStore.locale
                currency: RootStore.currentCurrency
            }
            boundsBehavior: Flickable.StopAtBounds
        }
    }
}
