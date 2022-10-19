import QtQuick 2.14
import QtWebEngine 1.10
import shared.status 1.0
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import utils 1.0

import "../../stores"

Column {
    id: root

    property var dappList: ListModel {}
    signal disconnect(string dappName)
    signal disconnectAddress(string dappName, string address)

    Repeater {
        id: permissionsList
        model: root.dappList
        delegate: Item {
            width: parent.width
            height: listItem.height + spacer.height
            WebEngineView {
                id: webView
                url: model.name.startsWith("http")? model.name : "http://%1".arg(model.name)
                visible: false
            }
            StatusListItem {
                id: listItem
                title: webView.title !== ""? webView.title : model.name
                subTitle: model.name
                asset.name: webView.icon != ""? webView.icon : Style.svg("compassActive")
                asset.isImage: true
                width: parent.width
                highlighted: true
                sensor.enabled: false
                components: [
                    StatusButton {
                        text: model.accounts.count > 1 ? qsTr("Disconnect All") : qsTr("Disconnect")
                        size: StatusBaseButton.Size.Small
                        type: StatusBaseButton.Type.Danger
                        onClicked: root.disconnect(model.name)
                    }
                ]
                bottomModel: model.accounts
                bottomDelegate: StatusListItemTag {
                    property int outerIndex: listItem.index

                    title: model.name

                    asset.emoji: !!model.emoji ? model.emoji: ""
                    asset.color: model.color
                    asset.name: !model.emoji ? "filled-account": ""
                    asset.letterSize: 14
                    asset.isLetterIdenticon: !!model.emoji
                    asset.bgColor: Theme.palette.indirectColor1
                    onClicked: root.disconnectAddress(model.name, model.address)
                }
            }

            Item {
                id: spacer
                height: Style.current.bigPadding
                width: parent.width
            }
        } // Item
    } // Repeater
} // Column
