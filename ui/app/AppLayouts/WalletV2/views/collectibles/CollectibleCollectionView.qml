import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root
    width: parent.width
    height: contentLoader.height

    property string slug: ""
    property bool assetsLoaded: false
    property string collectionImageUrl: ""
    property int collectionIndex: -1
    property var store
    signal collectibleClicked()

    // Not Refactored Yet
//    Connections {
//        target: root.store.walletV2ModelInst.collectiblesView.getAssetsList(root.slug)
//        onAssetsChanged: {
//            root.assetsLoaded = true;
//        }
//    }

    Loader {
        id: contentLoader
        width: parent.width
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: root.assetsLoaded ? loaded : loading
    }

    Component {
        id: loading

        Item {
            id: loadingIndicator
            height: 164
            StatusLoadingIndicator {
                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Component {
        id: loaded

        Flow {
            width: parent.width

            bottomPadding: 16
            spacing: 24

            Repeater {
                // Not Refactored Yet
//                model: root.store.walletV2ModelInst.collectiblesView.getAssetsList(root.slug)
                StatusRoundedImage {
                    id: image
                    width: 146
                    height: 146
                    radius: 16
                    image.source: model.imageUrl
                    border.color: Theme.palette.baseColor2
                    border.width: 1
                    showLoadingIndicator: true
                    color: model.backgroundColor
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.store.collectiblesStore.collectibleImageUrl = collectionImageUrl;
                            root.store.collectiblesStore.name =  model.name;
                            root.store.collectiblesStore.collectibleId = model.id;
                            root.store.collectiblesStore.description = model.description;
                            root.store.collectiblesStore.permalink = model.permalink;
                            root.store.collectiblesStore.imageUrl = model.imageUrl;
                            root.store.collectiblesStore.backgroundColor = model.backgroundColor;
                            root.store.collectiblesStore.properties = model.properties;
                            root.store.collectiblesStore.rankings = model.rankings;
                            root.store.collectiblesStore.stats = model.stats;
                            root.store.collectiblesStore.collectionIndex = root.collectionIndex;
                            root.collectibleClicked();
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // Not Refactored Yet
//        root.store.walletV2ModelInst.collectiblesView.loadAssets(root.store.walletV2ModelInst.accountsView.currentAccount.address, root.slug);
    }
}
