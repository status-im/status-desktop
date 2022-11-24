import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusMenuItem {
    id: root

    property string value: ""

    assetSettings.isImage: assetSettings.name.toString() !== ""
    assetSettings.isLetterIdenticon: assetSettings.name.toString() === ""
    assetSettings.color: assetSettings.name === "channel" ? Theme.palette.directColor1 : "transparent"
    assetSettings.letterSize: assetSettings.charactersLen > 1 ? 8 : 11
    assetSettings.imgIsIdenticon: false
}
