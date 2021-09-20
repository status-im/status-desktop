import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import "../components" as WalletComponents
import "../../../../imports"
import "../../../../shared"

Item {
    id: activityItemRoot

    property string tokenName: ""
    property string tokenIcon: ""
    property string timestamp: ""
    property string transactionHash: ""
    property string blockNumber: ""
    property string nonce: ""
    property string fromAddress: ""
    property string toAddress: ""
    property string gasLimit: ""
    property string gasUsed: ""
    property string gasPrice: ""
    property string inputData: ""

    function open(tokenName, tokenIcon, timestamp, transactionHash, blockNumber,
                     nonce, fromAddress, toAddress, gasLimit, gasUsed, gasPrice,
                     inputData) {
        activityItemRoot.tokenName = tokenName
        activityItemRoot.tokenIcon = tokenIcon
        activityItemRoot.timestamp = timestamp
        activityItemRoot.transactionHash = transactionHash
        activityItemRoot.blockNumber = blockNumber
        activityItemRoot.nonce = nonce
        activityItemRoot.fromAddress = fromAddress
        activityItemRoot.toAddress = toAddress
        activityItemRoot.gasLimit = gasLimit
        activityItemRoot.gasUsed = gasUsed
        activityItemRoot.gasPrice = gasPrice
        activityItemRoot.inputData = inputData

        contentLoader.sourceComponent = contentComponent

        rightPanelRoot.switchTo(rightPanelRoot.rightPanelViewActivityItem)
    }

    Loader {
        id: contentLoader
        anchors.fill: parent
    }

    Component {
        id: contentComponent

        Item {

            WalletComponents.Button {
                id: backToActivity
                anchors.top: parent.top
                anchors.topMargin: Style.current.halfPadding
                anchors.left: parent.left
                imageSource: "../../../img/list-next.svg"
                flipImage: true
                text: qsTr("Activity")
                onClicked: function (){
                    rightPanelRoot.switchTo(rightPanelRoot.rightPanelViewMain,
                                            rightPanelRoot.rightPanelViewMainTabActivity)

                    contentLoader.sourceComponent = undefined
                }
            }

            ScrollView {
                id: scrollView
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: backToActivity.bottom
                anchors.topMargin: Style.current.padding
                height: parent.height
                clip: true

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.current.padding

                        RowLayout {
                            Layout.preferredWidth: parent.width

                            Column {
                                spacing: Style.current.halfPadding

                                Row {
                                    spacing: Style.current.halfPadding

                                    Image {
                                        id: assetIcon
                                        height: 40
                                        width: 40
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: "../../../" + activityItemRoot.tokenIcon
                                        onStatusChanged: {
                                            if (assetIcon.status == Image.Error) {
                                                assetIcon.source = "../../../img/tokens/DEFAULT-TOKEN@3x.png"
                                            }
                                        }
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: activityItemRoot.tokenName
                                        font.weight: Font.Medium
                                        font.pixelSize: Style.current.mainTitlePrimaryFontSize
                                    }
                                }

                                Row {
                                    WalletComponents.DateTime {
                                        timestamp: activityItemRoot.timestamp
                                        selectedFormat: format_ddMyyyy
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                    }

                                    StyledText {
                                        text: " • "
                                        color: Style.current.secondaryText
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                    }

                                    WalletComponents.DateTime {
                                        timestamp: activityItemRoot.timestamp
                                        selectedFormat: format_hhmm
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                    }

                                    StyledText {
                                        text: " • "
                                        color: Style.current.secondaryText
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                    }

                                    StyledText {
                                        text: "aave.com"
                                        width: 160
                                        color: Style.current.secondaryText
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                        elide: Text.ElideMiddle
                                    }
                                }
                            }

                            Item {
                                // this is a simple spacer
                                Layout.preferredHeight: 1
                                Layout.fillWidth: true
                            }

                            WalletComponents.Button {
                                Layout.preferredWidth: width
                                Layout.preferredHeight: height
                                text: qsTr("View on Etherscan")
                                textColor: Style.current.textColor
                                border.width: 1
                                border.color: Style.current.grey
                                radius: Style.current.radius
                                onClicked: function (){

                                }
                            }
                        }

                        Separator {
                            Layout.preferredWidth: parent.width
                        }

                        Column {
                            Layout.preferredWidth: parent.width
                            spacing: Style.current.smallPadding

                            StyledText {
                                text: qsTr("Summary")
                                font.pixelSize: Style.current.primaryTextFontSize
                            }

                            GridLayout {
                                width: parent.width
                                columns: 3
                                rows: 2

                                StyledText {
                                    Layout.preferredWidth: 160
                                    text: qsTr("Network")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 200
                                    Layout.fillWidth: true
                                    text: qsTr("Transaction hash")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    text: qsTr("Block")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                Row {
                                    spacing: Style.current.halfPadding

                                    Image {
                                        id: networkIcon
                                        height: 20
                                        width: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: "../../../img/tokens/DEFAULT-TOKEN@3x.png"
                                        onStatusChanged: {
                                            if (networkIcon.status == Image.Error) {
                                                networkIcon.source = "../../../img/tokens/DEFAULT-TOKEN@3x.png"
                                            }
                                        }
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Hermez"
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                    }
                                }

                                StyledText {
                                    Layout.preferredWidth: 200
                                    Layout.fillWidth: true
                                    text: activityItemRoot.transactionHash
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                    elide: Text.ElideMiddle
                                }

                                StyledText {
                                    text: Utils.toLocaleString(activityItemRoot.blockNumber, globalSettings.locale)
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }
                            }

                            GridLayout {
                                width: parent.width
                                columns: 3
                                rows: 2

                                StyledText {
                                    Layout.fillWidth: true
                                    Layout.columnSpan: 2
                                    text: qsTr("Interacted with")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    text: qsTr("Time")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }


                                StyledText {
                                    Layout.columnSpan: 2
                                    text: "transaction....................addr"
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                Row {
                                    WalletComponents.DateTime {
                                        timestamp: activityItemRoot.timestamp
                                        selectedFormat: format_ddM
                                        color: Style.current.textColor
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: " • "
                                        color: Style.current.secondaryText
                                        font.pixelSize: 8
                                    }

                                    WalletComponents.DateTime {
                                        timestamp: activityItemRoot.timestamp
                                        selectedFormat: format_hhmm
                                        color: Style.current.textColor
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                    }
                                }
                            }

                            GridLayout {
                                width: parent.width
                                columns: 2
                                rows: 2

                                StyledText {
                                    Layout.preferredWidth: 160
                                    text: qsTr("Nonce")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: qsTr("Amount")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    text: activityItemRoot.nonce
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    text: "-0 ETH"
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }
                            }
                        }

                        Separator {
                            Layout.preferredWidth: parent.width
                        }

                        Column {
                            Layout.preferredWidth: parent.width
                            spacing: Style.current.smallPadding

                            StyledText {
                                text: qsTr("Tokens transferred")
                                font.pixelSize: Style.current.primaryTextFontSize
                            }

                            GridLayout {
                                width: parent.width
                                columns: 3
                                rows: 2

                                StyledText {
                                    Layout.preferredWidth: 160
                                    Layout.fillWidth: true
                                    text: qsTr("From")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    Layout.fillWidth: true
                                    text: qsTr("To")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    text: qsTr("For")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    Layout.fillWidth: true
                                    text: activityItemRoot.fromAddress
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                    elide: Text.ElideMiddle
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    Layout.fillWidth: true
                                    text: activityItemRoot.toAddress
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                    elide: Text.ElideMiddle
                                }

                                Row {
                                    spacing: Style.current.halfPadding

                                    Image {
                                        id: tokenIcon
                                        height: 20
                                        width: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        source: "../../../img/tokens/DEFAULT-TOKEN@3x.png"
                                        onStatusChanged: {
                                            if (tokenIcon.status == Image.Error) {
                                                tokenIcon.source = "../../../img/tokens/DEFAULT-TOKEN@3x.png"
                                            }
                                        }
                                    }

                                    StyledText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "24.20202302 DAI"
                                        font.pixelSize: Style.current.secondaryTextFontSize
                                    }
                                }
                            }
                        }

                        Separator {
                            Layout.preferredWidth: parent.width
                        }

                        Column {
                            Layout.preferredWidth: parent.width
                            spacing: Style.current.smallPadding

                            StyledText {
                                text: qsTr("Transaction fee")
                                font.pixelSize: Style.current.primaryTextFontSize
                            }

                            GridLayout {
                                width: parent.width
                                columns: 4
                                rows: 2

                                StyledText {
                                    Layout.preferredWidth: 160
                                    Layout.fillWidth: true
                                    text: qsTr("Gas limit")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    Layout.fillWidth: true
                                    text: qsTr("Gas used")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    Layout.fillWidth: true
                                    text: qsTr("Gas price")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    Layout.preferredWidth: 160
                                    Layout.fillWidth: true
                                    text: qsTr("Total")
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    text: Utils.toLocaleString(activityItemRoot.gasLimit, globalSettings.locale)
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    text: Utils.toLocaleString(activityItemRoot.gasUsed, globalSettings.locale)
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    text: Utils.toLocaleString(activityItemRoot.gasPrice, globalSettings.locale) + " Gwei"
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }

                                StyledText {
                                    text: "0.0002 ETH"
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }
                            }
                        }

                        Separator {
                            Layout.preferredWidth: parent.width
                        }

                        Column {
                            Layout.preferredWidth: parent.width
                            spacing: Style.current.smallPadding

                            StyledText {
                                text: qsTr("Input data")
                                font.pixelSize: Style.current.primaryTextFontSize
                            }

                            Rectangle {
                                width: parent.width
                                height: 100
                                color: Style.current.separator
                                border.width: 1
                                border.color: Style.current.grey
                                radius: Style.current.radius

                                StyledText {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.topMargin: Style.current.halfPadding
                                    anchors.leftMargin: Style.current.halfPadding
                                    anchors.rightMargin: Style.current.halfPadding
                                    text: activityItemRoot.inputData
                                    color: Style.current.secondaryText
                                    font.pixelSize: Style.current.secondaryTextFontSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
