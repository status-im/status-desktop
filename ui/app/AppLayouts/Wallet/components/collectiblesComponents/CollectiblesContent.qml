import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

ScrollView {
    property var collectibles: [{
            name: "Kitty cat1",
            image: "../../../../img/collectibles/placeholders/kitty.png",
            collectibleId: "1337"
        },
        {
            name: "Kitty cat2",
            image: "../../../../img/collectibles/placeholders/kitty.png",
            collectibleId: "1338"
        },
        {
            name: "Kitty cat3",
            image: "../../../../img/collectibles/placeholders/kitty.png",
            collectibleId: "1339"
        }]
    readonly property int imageSize: 164

    id: root
    height: contentRow.height
    width: parent.width
    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
    ScrollBar.horizontal.policy: ScrollBar.AsNeeded
    clip: true

    Row {
        id: contentRow
        bottomPadding: Style.current.padding
        spacing: Style.current.padding

        Repeater {
            model: collectibles

            Rectangle {
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
                    source: modelData.image
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
    }
}
