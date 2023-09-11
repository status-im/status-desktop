import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared.panels 1.0
import utils 1.0

import "collectibles"

Item {
    id: root
    property var collectiblesModel
    width: parent.width

    signal collectibleClicked(int chainId, string contractAddress, string tokenId, string uid)

    Loader {
        id: contentLoader
        width: parent.width
        height: parent.height

        sourceComponent: {
            /* TODO: Issue #11635
            if (!root.collectiblesModel.hasMore && root.collectiblesModel.count === 0)
                return empty;
            */
            return loaded;
        }
    }

    Component {
        id: empty
        Item {
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: Style.current.secondaryText
                text: qsTr("Collectibles will appear here")
                font.pixelSize: 15
            }
        }
    }

    Component {
        id: loaded
        StatusGridView {
            id: gridView
            anchors.fill: parent
            model: root.collectiblesModel
            cellHeight: 229
            cellWidth: 176
            delegate: CollectibleView {
                height: gridView.cellHeight
                width: gridView.cellWidth
                title: model.name ? model.name : "..."
                subTitle: model.collectionName ?? ""
                mediaUrl: model.mediaUrl ?? ""
                mediaType: model.mediaType ?? ""
                fallbackImageUrl: model.imageUrl ?? ""
                backgroundColor: model.backgroundColor ? model.backgroundColor : "transparent"
                isLoading: !!model.isLoading

                onClicked: root.collectibleClicked(model.chainId, model.contractAddress, model.tokenId, model.uid)
            }

            ScrollBar.vertical: StatusScrollBar {}

            // For some reason fetchMore is not working properly.
            // Adding some logic here as a workaround.
            visibleArea.onYPositionChanged: checkLoadMore()
            visibleArea.onHeightRatioChanged: checkLoadMore()

            Connections {
                target: gridView
                function onVisibleChanged() {
                    checkLoadMore()
                }
            }

            Connections {
                target: root.collectiblesModel
                function onHasMoreChanged() {
                    checkLoadMore()
                }
                function onIsFetchingChanged() {
                    checkLoadMore()
                }
            }

            function checkLoadMore() {
                // If there is no more items to load or we're already fetching, return
                if (!gridView.visible || !root.collectiblesModel.hasMore || root.collectiblesModel.isFetching)
                    return
                // Only trigger if close to the bottom of the list
                if (visibleArea.yPosition + visibleArea.heightRatio > 0.9)
                    root.collectiblesModel.loadMore()
            }
        }
    }
}
