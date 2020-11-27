import QtQuick 2.13
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import "./components"
import "./data"
import "../../../imports"
import "../../../shared"
import "../../../shared/status"

Item {
    property var tokens: {
        const count = walletModel.defaultTokenList.rowCount()
        const toks = []
        for (var i = 0; i < count; i++) {
            toks.push({
                          "address": walletModel.defaultTokenList.rowData(i, 'address'),
                          "symbol": walletModel.defaultTokenList.rowData(i, 'symbol')
                      })
        }
        return toks
    }

    function checkIfHistoryIsBeingFetched() {
        loadMoreButton.loadedMore = false;

        // prevent history from being fetched everytime you click on
        // the history tab
        if (walletModel.isHistoryFetched(walletModel.currentAccount.account))
            return;

        fetchHistory();
    }

    function fetchHistory() {
        if (walletModel.isFetchingHistory(walletModel.currentAccount.address)) {
            loadingImg.active = true
        } else {
            walletModel.loadTransactionsForAccount(
                        walletModel.currentAccount.address)
        }
    }

    id: root

    Loader {
        id: loadingImg
        active: false
        sourceComponent: loadingImageComponent
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.currentPadding
    }

    Component {
        id: loadingImageComponent
        LoadingImage {}
    }

    Connections {
        target: walletModel
        onHistoryWasFetched: checkIfHistoryIsBeingFetched()
        onLoadingTrxHistoryChanged: {
            loadingImg.active = isLoading
        }
    }

    Component {
        id: transactionListItemCmp

        Rectangle {
            id: transactionListItem
            property bool isHovered: false
            property string symbol: ""
            anchors.right: parent.right
            anchors.left: parent.left
            height: 64
            color: isHovered ? Style.current.secondaryBackground : Style.current.transparent
            radius: 8

            Component.onCompleted: {
                const count = root.tokens.length
                for (var i = 0; i < count; i++) {
                    let token = root.tokens[i]
                    if (token.address === contract) {
                        transactionListItem.symbol = token.symbol
                        break
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: transactionModal.open()
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    transactionListItem.isHovered = true
                }
                onExited: {
                    transactionListItem.isHovered = false
                }
            }

            TransactionModal {
                id: transactionModal
            }

            Item {
                Image {
                    id: assetIcon
                    width: 40
                    height: 40
                    source: "../../img/tokens/"
                            + (transactionListItem.symbol
                               != "" ? transactionListItem.symbol : "ETH") + ".png"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    onStatusChanged: {
                        if (assetIcon.status == Image.Error) {
                            assetIcon.source = "../../img/tokens/0-native.png"
                        }
                    }

                    anchors.leftMargin: Style.current.padding
                }

                StyledText {
                    id: transferIcon
                    anchors.topMargin: 25
                    anchors.top: parent.top
                    anchors.left: assetIcon.right
                    anchors.leftMargin: 22
                    height: 15
                    width: 15
                    color: to !== walletModel.currentAccount.address ? "#4360DF" : "green"
                    text: to !== walletModel.currentAccount.address ? "↑" : "↓"
                }

                StyledText {
                    id: transactionValue
                    anchors.left: transferIcon.right
                    anchors.leftMargin: Style.current.smallPadding
                    anchors.top: parent.top
                    anchors.topMargin: Style.current.bigPadding
                    font.pixelSize: 15
                    text: utilsModel.hex2Eth(value) + " " + transactionListItem.symbol
                }
            }

            Item {
                anchors.right: timeInfo.left
                anchors.top: parent.top
                anchors.topMargin: Style.current.bigPadding
                width: children[0].width + children[1].width

                StyledText {
                    text: to !== walletModel.currentAccount.address ?
                              //% "To "
                              qsTrId("to-") :
                              //% "From "
                              qsTrId("from-")
                    anchors.right: addressValue.left
                    color: Style.current.darkGrey
                    anchors.top: parent.top
                    font.pixelSize: 15
                    font.strikeout: false
                }

                StyledText {
                    id: addressValue
                    font.family: Style.current.fontHexRegular.name
                    text: to
                    width: 100
                    elide: Text.ElideMiddle
                    anchors.right: parent.right
                    anchors.top: parent.top
                    font.pixelSize: 15
                }
            }

            Item {
                id: timeInfo
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: Style.current.bigPadding
                width: children[0].width + children[1].width + children[2].width

                StyledText {
                    text: "• "
                    font.weight: Font.Bold
                    anchors.right: timeIndicator.left
                    color: Style.current.darkGrey
                    anchors.top: parent.top
                    font.pixelSize: 15
                }

                StyledText {
                    id: timeIndicator
                    text: "At "
                    anchors.right: timeValue.left
                    color: Style.current.darkGrey
                    anchors.top: parent.top
                    font.pixelSize: 15
                    font.strikeout: false
                }

                StyledText {
                    id: timeValue
                    text: timestamp
                    anchors.right: parent.right
                    anchors.top: parent.top
                    font.pixelSize: 15
                    anchors.rightMargin: Style.current.smallPadding
                }
            }
        }
    }

    ListView {
        id: transactionListRoot
        anchors.topMargin: 20
        height: parent.height - extraButtons.height
        width: parent.width
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: walletModel.transactions
        delegate: transactionListItemCmp
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
        }

        onCountChanged: {
            if (loadMoreButton.loadedMore)
                transactionListRoot.positionViewAtEnd();
        }
    }

    RowLayout {
        id: extraButtons
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: loadMoreButton.height

        StatusButton {
            id: loadMoreButton
            //% "Load More"
            text: qsTrId("load-more")
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            property bool loadedMore: false

            Connections {
                onClicked: {
                    fetchHistory()
                    loadMoreButton.loadedMore = true
                }
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/

