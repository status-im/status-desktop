import QtQuick 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

StatusAction {
    id: root

    property string value: ""

    assetSettings.isImage: assetSettings.name.toString() !== ""
    assetSettings.isLetterIdenticon: assetSettings.name.toString() === ""
    assetSettings.color: assetSettings.name === "channel" ? Theme.palette.directColor1 : icon.color
    assetSettings.letterSize: assetSettings.charactersLen > 1 ? 8 : 11
    assetSettings.imgIsIdenticon: false
}
