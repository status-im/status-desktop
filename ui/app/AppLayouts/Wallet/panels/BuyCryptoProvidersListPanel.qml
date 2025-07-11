import QtQuick
import QtQuick.Layouts
import QtQml.Models
import SortFilterProxyModel

import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Utils

import AppLayouts.Wallet.controls

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
