import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQml.Models 2.15
import SortFilterProxyModel 0.2

import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Wallet.controls 1.0

ColumnLayout {
    id: root

    // required properties
    required property bool providersLoading
    // expected model structure:
    // id, name, description, fees, logoUrl, hostname, supportsSinglePurchase, supportsRecurrentPurchase, supportedAssets, urlsNeedParameters
    required property var providersModel
    required property bool isUrlBeingFetched
    required property string selectedProviderId

    // exposed api
    property alias currentTabIndex: tabBar.currentIndex
    signal providerSelected(string id)

    QtObject {
        id: d
        readonly property int loadingItemsCount: 5
    }

    spacing: 20

    StatusSwitchTabBar {
        id: tabBar
        objectName: "tabBar"
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        StatusSwitchTabButton {
            text: qsTr("One time")
        }
        StatusSwitchTabButton {
            text: qsTr("Recurrent")
        }
    }

    StatusListView {
        objectName: "providersList"
        Layout.fillWidth: true
        Layout.fillHeight: true

        DelegateModel {
            id: regularModel
            model: SortFilterProxyModel {
                sourceModel: root.providersModel
                filters: ValueFilter {
                    enabled: tabBar.currentIndex
                    roleName: "supportsRecurrentPurchase"
                    value: true
                }
            }
            delegate: BuyCryptoProvidersDelegate {
                required property var model

                width: ListView.view.width
                name: model.name
                logoUrl: model.logoUrl
                fees: model.fees
                urlsNeedParameters: model.urlsNeedParameters
                isUrlLoading: root.isUrlBeingFetched && root.selectedProviderId === model.id
                onClicked: root.providerSelected(model.id)
            }
        }

        DelegateModel {
            id: loadingModel
            model: d.loadingItemsCount
            delegate: BuyCryptoProvidersLoadingDelegate {
                required property var model
                width: ListView.view.width
            }
        }

        model: root.providersLoading ? loadingModel : regularModel
    }
}
