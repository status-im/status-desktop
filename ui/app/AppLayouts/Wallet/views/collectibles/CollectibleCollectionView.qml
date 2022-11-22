import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import shared.panels 1.0

import "../../stores"
import utils 1.0

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
        anchors.topMargin: 16
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
        id: empty

        Item {
            id: emptyContainer
            height: 164
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                color: Style.current.secondaryText
                text: qsTr("No collectibles available")
                font.pixelSize: 15
            }
        }
    }

    Component {
        id: loaded

        Flow {
            width: parent.width

            bottomPadding: 16
            spacing: 24

            Component {
                id: collectibleDelegate

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
                    Rectangle {
                        anchors.centerIn: parent
                        width: image.width
                        height: image.height
                        radius: image.radius
                        border.width: 1
                        border.color: Theme.palette.primaryColor1
                        color: Theme.palette.indirectColor3
                        visible: mouse.containsMouse
                    }
                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            RootStore.selectCollectible(root.slug, model.id)
                            root.collectibleClicked();
                        }
                    }
                }
            }

            Repeater {
                objectName: "collectiblesRepeater"
                model: RootStore.getCollectionCollectiblesList(root.slug)
                delegate: collectibleDelegate
            }
        }
    }
}
