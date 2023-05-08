import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Chat.panels.communities 1.0

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property bool preview: false

    // Collectible object properties:
    property alias artworkSource: image.source
    property alias symbol: symbolBox.value
    property alias description: descriptionItem.text
    property alias chainName: chainText.text
    property string name
    property int supplyAmount
    property bool infiniteSupply
    property bool transferable
    property bool selfDestruct
    property int chainId
    property string chainIcon
    property int deployState
    property var tokenOwnersModel

    property alias accountName: accountBox.value

    signal mintCollectible(url artworkSource,
                           string name,
                           string symbol,
                           string description,
                           int supply,
                           bool infiniteSupply,
                           bool transferable,
                           bool selfDestruct,
                           int chainId,
                           string accountName)

    QtObject {
        id: d

        readonly property int imageSelectorRectSize: 280
        readonly property int iconSize: 20
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    padding: 0

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        RowLayout {
            visible: !root.preview && (root.deployState === Constants.DeployState.InProgress)
            spacing: Style.current.halfPadding

            StatusDotsLoadingIndicator {}

            StatusBaseText {
                elide: Text.ElideRight
                font.pixelSize: Theme.primaryTextFontSize
                text: qsTr("Collectible is being minted")
            }
        }

        Rectangle {
            Layout.preferredHeight: d.imageSelectorRectSize
            Layout.preferredWidth: Layout.preferredHeight
            radius: 8
            color: Theme.palette.baseColor2

            Image {
                id: image

                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
            }
        }

        StatusBaseText {
            id: descriptionItem

            Layout.fillWidth: true
            wrapMode: TextEdit.WordWrap
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
        }

        Flow {
            spacing: Style.current.halfPadding
            Layout.fillWidth: true

            component CustomPreviewBox: Rectangle {
                id: previewBox

                property string label
                property string value
                property bool leftAlignment: true

                radius: 8
                border.color: Theme.palette.baseColor2
                color: "transparent"
                implicitWidth: Math.min(boxContent.implicitWidth + Style.current.padding, mainLayout.width)
                implicitHeight: boxContent.implicitHeight + Style.current.padding

                ColumnLayout {
                    id: boxContent
                    anchors.centerIn: parent
                    spacing: 2

                    StatusBaseText {
                        Layout.fillWidth: true
                        text: previewBox.label
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        color: Theme.palette.baseColor1
                        horizontalAlignment: Text.AlignHCenter
                    }

                    StatusBaseText {
                        Layout.maximumWidth: mainLayout.width - Style.current.padding
                        Layout.alignment: previewBox.leftAlignment ? Qt.AlignLeft : Qt.AlignHCenter
                        text: previewBox.value
                        elide: Text.ElideRight
                        font.pixelSize: Theme.primaryTextFontSize
                        color: Theme.palette.directColor1
                        horizontalAlignment: previewBox.leftAlignment ? Text.AlignLeft : Text.AlignHCenter
                    }
                }
            }

            CustomPreviewBox {
                label: root.infiniteSupply ? qsTr("Infinite supply") : qsTr("Total")
                value: root.infiniteSupply ? qsTr("Yes") : LocaleUtils.numberToLocaleString(root.supplyAmount)
                leftAlignment: root.infiniteSupply
            }

            CustomPreviewBox {
                label: qsTr("Transferable")
                value: root.transferable ? qsTr("Yes") : qsTr("No")
            }

            CustomPreviewBox {
                label: qsTr("Remote self-destruct")
                value: root.selfDestruct ? qsTr("Yes") : qsTr("No")
            }

            CustomPreviewBox {
                id: symbolBox

                label: qsTr("Symbol")
                leftAlignment: false
            }

            CustomPreviewBox {
                id: accountBox

                label: qsTr("Account")
                leftAlignment: false
            }

            Rectangle {
                height: symbolBox.height
                width: rowChain.implicitWidth + 2 * Style.current.padding
                border.width: 1
                radius: 8
                border.color: Theme.palette.baseColor2
                color: "transparent"

                RowLayout {
                    id: rowChain

                    anchors.centerIn: parent
                    spacing: Style.current.padding

                    SVGImage {
                        id: chainIcon

                        Layout.alignment: Qt.AlignVCenter
                        height: 24
                        width: height
                        source: Style.svg(root.chainIcon)
                    }

                    StatusBaseText {
                        id: chainText

                        Layout.alignment: Qt.AlignVCenter
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: Theme.palette.baseColor1
                    }
                }
            }
        }

        RowLayout {
            visible: root.preview
            Layout.fillWidth: true

            StatusIcon {
                Layout.preferredWidth: d.iconSize
                Layout.preferredHeight: d.iconSize
                Layout.alignment: Qt.AlignTop
                color: Theme.palette.baseColor1
                icon: "info"
            }

            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.baseColor1
                text: qsTr("Make sure you’re happy with your collectible before minting it as it can’t be edited later")
            }
        }

        StatusButton {
            visible: root.preview
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding
            text: qsTr("Mint")

            onClicked: {
                root.mintCollectible(root.artworkSource,
                                     root.name,
                                     root.symbol,
                                     root.description,
                                     root.supplyAmount,
                                     root.infiniteSupply,
                                     root.transferable,
                                     root.selfDestruct,
                                     root.chainId,
                                     root.accountName)
            }
        }

        TokenHoldersPanel {
            visible: !root.preview
            tokenName: root.name
            model: root.tokenOwnersModel
            Layout.topMargin: Style.current.padding
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
