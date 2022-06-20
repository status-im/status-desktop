import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import shared.panels 1.0

import utils 1.0

import "../../stores"

Item {
    id: root
    width: parent.width
    height: contentLoader.height

    property string slug: ""
    property bool collectiblesLoaded: false
    property string collectionImageUrl: ""
    property int collectionIndex: -1
    signal collectibleClicked()

    Connections {
        target: walletSectionCollectiblesCollectibles
        onItemsLoaded: function(collectionSlug) {
            if (collectionSlug !== slug) {
                return
            }
            root.collectiblesLoaded = true;
        }
    }

    Loader {
        id: contentLoader
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: {
            if (!root.collectiblesLoaded) {
                return loading
            }
            if (RootStore.getCollectionCollectiblesList(root.slug).count == 0) {
                return empty
            }
            return loaded
        }
    }

    Component {
        id: loading

        Item {
            id: loadingIndicator
            height: Style.dp(164)
            StatusLoadingIndicator {
                width: Style.dp(20)
                height: Style.dp(20)
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Component {
        id: empty

        Item {
            id: emptyContainer
            height: Style.dp(164)
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: Style.current.secondaryText
                text: qsTr("No collectibles available")
                font.pixelSize: Style.current.primaryTextFontSize
            }
        }
    }

    Component {
        id: loaded

        Flow {
            width: parent.width

            bottomPadding: Style.current.padding
            spacing: Style.current.bigPadding

            Repeater {
                model: RootStore.getCollectionCollectiblesList(root.slug)
                StatusRoundedImage {
                    id: image
                    width: Style.dp(146)
                    height: Style.dp(146)
                    radius: Style.dp(16)
                    image.source: model.imageUrl
                    border.color: Theme.palette.baseColor2
                    border.width: Style.dp(1)
                    showLoadingIndicator: true
                    color: model.backgroundColor
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            RootStore.collectiblesStore.collectibleImageUrl = collectionImageUrl;
                            RootStore.collectiblesStore.name =  model.name;
                            RootStore.collectiblesStore.collectibleId = model.id;
                            RootStore.collectiblesStore.description = model.description;
                            RootStore.collectiblesStore.permalink = model.permalink;
                            RootStore.collectiblesStore.imageUrl = model.imageUrl;
                            RootStore.collectiblesStore.backgroundColor = model.backgroundColor;
                            RootStore.collectiblesStore.properties = model.properties;
                            RootStore.collectiblesStore.rankings = model.rankings;
                            RootStore.collectiblesStore.stats = model.stats;
                            RootStore.collectiblesStore.collectionIndex = root.collectionIndex;
                            root.collectibleClicked();
                        }
                    }
                }
            }
        }
    }
}
