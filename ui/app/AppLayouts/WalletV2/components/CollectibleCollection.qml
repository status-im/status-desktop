import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property string slug: ""
    property bool assetsLoaded: false
    property string collectionImageUrl: ""
    property int collectionIndex: -1

    signal clicked()

    width: parent.width
    height: contentLoader.height

    Connections {
        target: walletV2Model.collectiblesView.getAssetsList(root.slug)
        onAssetsChanged: {
            root.assetsLoaded = true
        }
    }

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
                model: walletV2Model.collectiblesView.getAssetsList(root.slug)
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
                            openCollectibleDetailView({collectibleImageUrl:collectionImageUrl,
                                                          name: model.name,
                                                          collectibleId: model.id,
                                                          description: model.description,
                                                          permalink: model.permalink,
                                                          imageUrl: model.imageUrl,
                                                          backgroundColor: model.backgroundColor,
                                                          properties: model.properties,
                                                          rankings: model.rankings,
                                                          stats: model.stats,
                                                          collectionIndex: root.collectionIndex
                                                      })
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        walletV2Model.collectiblesView.loadAssets(walletV2Model.accountsView.currentAccount.address, root.slug)
    }
}
