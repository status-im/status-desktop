import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

Item {
    property url collectibleIconSource: "../../../../img/collectibles/CryptoKitties.png"
    property string collectibleName: "CryptoKitties"
    property bool isLoading: true

    id: root

    CollectiblesHeader {
        collectibleName: root.collectibleName
        collectibleIconSource: root.collectibleIconSource
        isLoading: root.isLoading
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
