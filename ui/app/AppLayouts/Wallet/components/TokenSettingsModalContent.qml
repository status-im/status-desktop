import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../Chat/ContactsColumn"
import "../data/"

Item {
    id: modalBody
    anchors.fill: parent

    SearchBox {
        id: searchBox
        customHeight: 36
        fontPixelSize: 12
        anchors.top: modalBody.top
    }

    ListView {
        id: tokenListView
        spacing: 0
        clip: true
        anchors.top: searchBox.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: walletModel.defaultTokenList
        ScrollBar.vertical: ScrollBar { active: true }

        delegate: Component {
            id: component
            Item {
                id: tokenContainer
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.leftMargin: Style.current.smallPadding
                width: parent.width
                property bool isVisible: symbol && (searchBox.text == "" || name.toLowerCase().includes(searchBox.text.toLowerCase()) || symbol.toLowerCase().includes(searchBox.text.toLowerCase()))

                visible: isVisible
                height: isVisible ? 40 + Style.current.smallPadding : 0

                Image {
                    id: assetInfoImage
                    width: 36
                    height: tokenContainer.isVisible !== "" ? 36 : 0
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    source: hasIcon ? "../../../img/tokens/" + symbol + ".png" : "../../../img/tokens/0-native.png"
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                }
                StyledText {
                    id: assetSymbol
                    text: symbol
                    anchors.left: assetInfoImage.right
                    anchors.leftMargin: Style.current.smallPadding
                    anchors.top: assetInfoImage.top
                    anchors.topMargin: 0
                    font.pixelSize: 15
                }
                StyledText {
                    id: assetFullTokenName
                    text: name || ""
                    anchors.bottom: assetInfoImage.bottom
                    anchors.bottomMargin: 0
                    anchors.left: assetInfoImage.right
                    anchors.leftMargin: Style.current.smallPadding
                    color: Style.current.darkGrey
                    font.pixelSize: 15
                }
                CheckBox  {
                    id: assetCheck
                    checked: walletModel.hasAsset("0x123", symbol)
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.smallPadding
                    onClicked: walletModel.toggleAsset(symbol)
                }
            }
        }
        highlightFollowsCurrentItem: true
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
