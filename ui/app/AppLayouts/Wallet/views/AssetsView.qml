import QtQuick 2.13
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import utils 1.0

import "../../../../shared"
import "../stores"
import "../controls"

Item {
    height: assetListView.height

    ScrollView {
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: assetListView.contentHeight > assetListView.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            id: assetListView
            spacing: Style.current.padding * 2
            anchors.fill: parent
            // model: RootStore.exampleAssetModel
            model: RootStore.assets
            delegate: AssetDelegate {
                currency: RootStore.currentCurrency
            }
            boundsBehavior: Flickable.StopAtBounds
        }
    }
}
