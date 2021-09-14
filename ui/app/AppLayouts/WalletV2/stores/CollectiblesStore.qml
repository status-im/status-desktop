import QtQuick 2.13
import QtQuick.Dialogs 1.3
import "../../../../imports"

QtObject {
    id: root

    property string name
    property string collectibleId
    property string description: qsTr("Collectibles")
    property color backgroundColor: "transparent"
    property url collectibleImageUrl
    property url permalink
    property url imageUrl
    property var properties
    property var rankings
    property var stats
    property int collectionIndex
}
