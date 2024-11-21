import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.controls 1.0

import StatusQ.Core.Theme 0.1

SplitView {
    id: root
    Pane {
        id: leftPane
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        BannerCard {
            anchors.centerIn: parent
            title: titleField.text
            subTitle: subTitleField.text
            image: Theme.png("wallet/wallet-green")
            closeEnabled: closeEnabled.checked
            onClicked: {
                print("BannerCard clicked")
            }
            onClose: {
                print("BannerCard closed")
            }
        }
    }
    Pane {
        id: rightPane
        SplitView.fillHeight: true
        SplitView.preferredWidth: 300
        ColumnLayout {
            anchors.fill: parent
            CheckBox {
                id: closeEnabled
                text: "Show close button"
                checked: true
            }
            Label {
                text: "Title"
            }
            TextField {
                id: titleField
                text: "Ways to buy crypto"
            }
            Label {
                text: "Sub title"
            }
            TextField {
                id: subTitleField
                text: "Via card or bank transfer"
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
