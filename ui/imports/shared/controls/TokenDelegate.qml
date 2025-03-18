import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import AppLayouts.Wallet 1.0
import AppLayouts.Wallet.controls 1.0
import utils 1.0

StatusListItem {
    id: root

    property string name
    property url icon
    property string balance

    property bool marketDetailsAvailable: false
    property string marketBalance
    property bool marketDetailsLoading: false
    property string marketCurrencyPrice
    property real marketChangePct24hour

    property string communityId
    property string communityName
    property url communityIcon

    property string errorTooltipText_1
    property string errorTooltipText_2

    signal communityClicked(string communityId)

    QtObject {
        id: d

        readonly property bool isCommunityToken: !!root.communityId

        readonly property string textColor: {
            if (!root.marketDetailsAvailable)
                return Theme.palette.successColor1
            return WalletUtils.getChangePct24HourColor(root.marketChangePct24hour)
        }
    }

    title: root.name
    subTitle: root.balance
    asset.name: root.icon
    asset.isImage: true
    asset.width: 32
    asset.height: 32
    errorIcon.tooltip.maxWidth: 300
    height: implicitHeight

    statusListItemTitleIcons.sourceComponent: StatusFlatRoundButton {
        width: 14
        height: visible ? 14 : 0
        icon.width: 14
        icon.height: 14
        icon.name: "tiny/warning"
        icon.color: Theme.palette.dangerColor1
        tooltip.text: root.errorTooltipText_1
        tooltip.maxWidth: 300
        visible: !!tooltip.text
    }

    components: [
        Column {
            anchors.verticalCenter: parent.verticalCenter
            StatusFlatRoundButton {
                id: errorIcon
                width: 14
                height: visible ? 14 : 0
                icon.width: 14
                icon.height: 14
                icon.name: "tiny/warning"
                icon.color: Theme.palette.dangerColor1
                tooltip.text: root.errorTooltipText_2
                tooltip.maxWidth: 200
                visible: root.marketDetailsAvailable && !!tooltip.text
            }
            StatusTextWithLoadingState   {
                id: currencyBalance

                anchors.right: parent.right
                visible: !errorIcon.visible && root.marketDetailsAvailable

                loading: root.marketDetailsLoading
                text: loading ? Constants.dummyText : root.marketBalance
            }
            Row {
                anchors.right: parent.right
                spacing: 6
                visible: !errorIcon.visible && root.marketDetailsAvailable

                StatusTextWithLoadingState {
                    id: change24HourPercentageText

                    anchors.verticalCenter: parent.verticalCenter
                    customColor: d.textColor
                    font.pixelSize: 13
                    loading: root.marketDetailsLoading

                    text: qsTr("%1 %2%", "[up/down/none character depending on value sign] [localized percentage value]%")
                    .arg(WalletUtils.getUpDownTriangle(root.marketChangePct24hour))
                    .arg(LocaleUtils.numberToLocaleString(root.marketChangePct24hour, 2))
                }
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 12
                    color: Theme.palette.directColor9
                }
                StatusTextWithLoadingState {
                    id: currencyPrice

                    anchors.verticalCenter: parent.verticalCenter
                    customColor: d.textColor
                    font.pixelSize: 13
                    loading: root.marketDetailsLoading
                    text: loading ? Constants.dummyText : root.marketCurrencyPrice
                }
            }

            Loader {
                active: d.isCommunityToken

                sourceComponent: ManageTokensCommunityTag {
                    anchors.right: parent.right

                    communityImage: root.communityIcon
                    communityName: root.communityName
                    communityId: root.communityId

                    asset.letterSize: 12

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onSingleTapped: root.communityClicked(root.communityId)
                    }
                }
            }
        }
    ]

    states: State {
        name: "unknownToken"
        when: !root.icon.toString()

        PropertyChanges {
            target: root.asset
            isLetterIdenticon: true
            color: Theme.palette.miscColor5
            name: root.name
        }
    }
}
