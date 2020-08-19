import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQml.Models 2.13
import "../../../../../imports"
import "../../../../../shared"

ScrollView {
    property var collectibles: [{
            name: "Kitty cat1",
            image: "../../../../img/collectibles/placeholders/kitty.png",
            collectibleId: "1337",
            description: "Avast ye! I'm the dread pirate Furbeard, and I'll most likely sleep"
        },
        {
            name: "Kitty cat2",
            image: "../../../../img/collectibles/placeholders/kitty.png",
            collectibleId: "1338",
            description: "Avast ye! I'm the dread pirate Furbeard, and I'll most likely sleep"
        },
        {
            name: "Kitty cat3",
            image: "../../../../img/collectibles/placeholders/kitty.png",
            collectibleId: "1339",
            description: "Avast ye! I'm the dread pirate Furbeard, and I'll most likely sleep"
        }]
    readonly property int imageSize: 164
    property string collectibleType: "cryptokitty"
    property var collectiblesModal
    property string buttonText: "View in Cryptokitties"
    property var getLink: function () {}
    property alias collectiblesQty: collectibleModel.count

    id: root
    height: visible ? contentRow.height : 0
    width: parent.width
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
    clip: true

    Row {
        id: contentRow
        bottomPadding: Style.current.padding
        spacing: Style.current.padding

        Repeater {
            model: collectibleModel
        }

        DelegateModel {
            id: collectibleModel
            model: walletModel.collectibles
            items.includeByDefault: false

            groups: [
                DelegateModelGroup {
                    id: uncheckedItems
                    name: "unchecked"
                    includeByDefault: true
                    onChanged: {
                        while (uncheckedItems.count > 0) {
                            var currentItem = uncheckedItems.get(0)
                            if (currentItem.model.collectibleType === root.collectibleType) {
                               currentItem.groups = "items"
                            } else {
                                currentItem.groups = "bad"
                            }
                        }

                    }
                },
                DelegateModelGroup {
                    id: badCollectibleGroup
                    name: "bad"
                    includeByDefault: true
                }

            ]

            delegate: Rectangle {
                radius: 16
                border.width: 1
                border.color: Style.current.border
                color: Style.current.background
                width: collectibleImage.width
                height: collectibleImage.height

                Image {
                    id: collectibleImage
                    width: root.imageSize
                    height: root.imageSize
                    source: image
                    fillMode: Image.PreserveAspectCrop
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: {
                        collectiblesModal.openModal({
                                                   name: name,
                                                   id: collectibleId,
                                                   // TODO do we even have a description?
                                                   description: "",
                                                   buttonText: root.buttonText,
                                                   link: root.getLink(collectibleId),
                                                   image: image
                                               })
                    }
                }
            }
        }
    }
}
