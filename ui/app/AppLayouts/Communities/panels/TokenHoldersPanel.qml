import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls 1.0

Control {
    id: root
    property var model
    property string tokenName
    property bool isSelectorMode: false

    signal selfDestructAmountChanged(string walletAddress, int amount)
    signal selfDestructRemoved(string walletAddress)
    bottomPadding: 16

    TokenHoldersProxyModel {
        id: filteredModel
        sourceModel: root.model
        searchText: searcher.text

        sortBy: holdersList.sortBy
        sortOrder: holdersList.sortOrder ? Qt.DescendingOrder : Qt.AscendingOrder
    }

    contentItem: ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.topMargin: Style.current.padding
        spacing: 0
        StatusBaseText {
            id: txtLabel
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            wrapMode: Text.Wrap
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.baseColor1

            text: qsTr("%1 token holders").arg(root.tokenName)
        }

        SearchBox {
            id: searcher
            Layout.fillWidth: true
            Layout.topMargin: 12
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            visible: !root.empty
            topPadding: 0
            bottomPadding: 0
            minimumHeight: 36 // by design
            maximumHeight: minimumHeight
            placeholderText: qsTr("Search hodlers")
        }
        StatusBaseText {
            id: anotherLabel
            Layout.fillWidth: true
            Layout.topMargin: 12
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding

            wrapMode: Text.Wrap
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.baseColor1
            visible: (searcher.text.length > 0 && filteredModel.count === 0)
            text: visible ? qsTr("No hodlers found") : ""
        }
        TokenHoldersList {
            id: holdersList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 12
            isSelectorMode: root.isSelectorMode
            model: filteredModel
            onSelfDestructRemoved: root.selfDestructRemoved(walletAddress)
            onSelfDestructAmountChanged: root.selfDestructAmountChanged(
                                             walletAddress, amount)
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            Layout.alignment: Qt.AlignBottom
            color: Theme.palette.baseColor2
            opacity: holdersList.bottomSeparatorVisible ? 1.0 : 0.0
        }
    }
}
