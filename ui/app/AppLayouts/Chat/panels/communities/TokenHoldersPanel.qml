import QtQuick 2.14
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import SortFilterProxyModel 0.2

import utils 1.0
import shared.controls 1.0

Control {
    id: root

    // Expected roles: ensName, walletAddress, imageSource and amount
    property var model

    property string tokenName

    QtObject {
        id: d

        readonly property int red2Color: 4
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        spacing: Style.current.padding

        StatusBaseText {
            visible: !root.preview
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: Style.current.primaryTextFontSize
            color: Theme.palette.baseColor1
            text: qsTr("All %1 token holders").arg(root.tokenName)
        }

        SortFilterProxyModel {
            id: filteredModel

            sourceModel: root.model
            filters: ExpressionFilter {
                enabled: searcher.enabled
                expression: {
                    searcher.text
                    return model.ensName.toLowerCase().includes(searcher.text.toLowerCase()) ||
                            model.walletAddress.toLowerCase().includes(searcher.text.toLowerCase())
                }
            }
        }

        SearchBox {
            id: searcher
            Layout.fillWidth: true
            topPadding: 0
            bottomPadding: 0
            minimumHeight: 36 // by design
            maximumHeight: minimumHeight
            enabled: root.model.count > 0
            placeholderText: enabled ? qsTr("Search") : qsTr("No placeholders to search")
        }

        StatusListView {
            id: holders

            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height
            leftMargin: -Style.current.padding
            model: filteredModel
            delegate: StatusListItem {
                readonly property bool unknownHolder: model.ensName === ""
                readonly property string formattedTitle: unknownHolder ? "?" : model.ensName

                sensor.enabled: false
                width: ListView.view.width
                title: formattedTitle
                statusListItemTitle.visible: !unknownHolder
                subTitle: model.walletAddress
                asset.name: model.imageSource
                asset.isImage: true
                asset.isLetterIdenticon: unknownHolder
                asset.color: Theme.palette.userCustomizationColors[d.red2Color]
            }
        }
    }
}
