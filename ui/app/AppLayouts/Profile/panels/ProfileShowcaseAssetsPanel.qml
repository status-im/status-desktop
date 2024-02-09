import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Profile.controls 1.0

ProfileShowcasePanel {
    id: root

    required property bool addAccountsButtonVisible

    property var formatCurrencyAmount: function(amount, symbol){}

    signal navigateToAccountsTab()

    keyRole: "symbol"
    roleNames: ["symbol", "name", "address", "communityId", "enabledNetworkBalance", "decimals"].concat(showcaseRoles)
    filterFunc: (modelData) => modelData.symbol !== "" && !showcaseModel.hasItemInShowcase(modelData.symbol)
    hiddenPlaceholderBanner: qsTr("Assets here will show on your profile")
    showcasePlaceholderBanner: qsTr("Assets here will be hidden from your profile")

    draggableDelegateComponent: AssetShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item-hidden"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        formatCurrencyAmount: function(amount, symbol) {
            return root.formatCurrencyAmount(amount, symbol)
        }
        onShowcaseVisibilityRequested: {
            var tmpObj = Object()
            root.roleNames.forEach(role => tmpObj[role] = showcaseObj[role])
            tmpObj.showcaseVisibility = value
            showcaseModel.upsertItemJson(JSON.stringify(tmpObj))
            root.showcaseEntryChanged()
        }
    }
    showcaseDraggableDelegateComponent: AssetShowcaseDelegate {
        Drag.keys: ["x-status-draggable-showcase-item"]
        showcaseObj: modelData
        dragParent: dragParentData
        visualIndex: visualIndexData
        dragAxis: Drag.YAxis
        showcaseVisibility: !!modelData ? modelData.showcaseVisibility : Constants.ShowcaseVisibility.NoOne
        onShowcaseVisibilityRequested: {
            showcaseModel.setVisibility(showcaseObj.symbol, value)
            root.showcaseEntryChanged()
        }
    }
    additionalComponent: root.addAccountsButtonVisible ? addMoreAccountsComponent : null

    Component {
        id: addMoreAccountsComponent

        ColumnLayout {
            spacing: Style.current.halfPadding
            visible: root.addAccountsButtonVisible

            Separator {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.padding
                Layout.bottomMargin: Style.current.padding
            }

            StatusBaseText {
                Layout.alignment: Qt.AlignHCenter

                font.pixelSize: Style.current.additionalTextSize
                text: qsTr("Don’t see some of your assets?")
            }

            StatusFlatButton {
                Layout.alignment: Qt.AlignHCenter

                font.pixelSize: Style.current.additionalTextSize
                text: qsTr("Add accounts to showcase")

                onClicked: root.navigateToAccountsTab()
            }
        }
    }
}
