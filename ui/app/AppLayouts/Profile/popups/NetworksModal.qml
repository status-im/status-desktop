import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

import "../controls"
import "../panels"

import StatusQ.Controls 0.1 as StatusQControls

// TODO: replace with StatusQ component
ModalPopup {
    id: popup
    //% "Network"
    title: qsTrId("network")

    property var advancedStore

    ScrollView {
        id: svNetworks
        width: parent.width
        height: Style.dp(300)
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        Column {
            id: column
            spacing: Style.current.padding
            width: parent.width

            ButtonGroup { id: networkSettings }

            Item {
                id: addNetwork
                width: parent.width
                height: addButton.height

                StatusQControls.StatusRoundButton {
                    id: addButton
                    width: Style.dp(40)
                    height: Style.dp(40)
                    icon.name: "add"
                    type: StatusQControls.StatusRoundButton.Type.Secondary
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    id: usernameText
                    //% "Add network"
                    text: qsTrId("add-network")
                    color: Style.current.blue
                    anchors.left: addButton.right
                    anchors.leftMargin: Style.current.padding
                    anchors.verticalCenter: addButton.verticalCenter
                    font.pixelSize: Style.current.primaryTextFontSize
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Global.openPopup(addNetworkPopupComponent)
                }
            }

            Component {
                id: addNetworkPopupComponent
                NewCustomNetworkModal {
                    anchors.centerIn: parent
                    advancedStore: popup.advancedStore
                    onClosed: {
                        destroy()
                    }
                }
            }



            Column {
                spacing: Style.current.smallPadding
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.current.padding
                anchors.rightMargin: Style.current.padding

                ButtonGroup {
                    id: radioGroup
                }


                StatusSectionHeadline {
                    //% "Main networks"
                    text: qsTrId("main-networks")
                }


                NetworkRadioSelector {
                    advancedStore: popup.advancedStore
                    network: Constants.networkMainnet
                    buttonGroup: radioGroup
                }

                NetworkRadioSelector {
                    advancedStore: popup.advancedStore
                    network: Constants.networkPOA
                    buttonGroup: radioGroup
                }

                NetworkRadioSelector {
                    advancedStore: popup.advancedStore
                    network: Constants.networkXDai
                    buttonGroup: radioGroup
                }

                StatusSectionHeadline {
                    //% "Test networks"
                    text: qsTrId("test-networks")
                    anchors.leftMargin: -Style.current.padding
                    anchors.rightMargin: -Style.current.padding
                }

                NetworkRadioSelector {
                    advancedStore: popup.advancedStore
                    network: Constants.networkGoerli
                    buttonGroup: radioGroup
                }

                NetworkRadioSelector {
                    advancedStore: popup.advancedStore
                    network: Constants.networkRinkeby
                    buttonGroup: radioGroup
                }

                NetworkRadioSelector {
                    advancedStore: popup.advancedStore
                    network: Constants.networkRopsten
                    buttonGroup: radioGroup
                }

                StatusSectionHeadline {
                    //% "Custom Networks"
                    text: qsTrId("custom-networks")
                    anchors.leftMargin: -Style.current.padding
                    anchors.rightMargin: -Style.current.padding
                }

                Repeater {
                    model: popup.advancedStore.customNetworksModel
                    delegate: NetworkRadioSelector {
                        advancedStore: popup.advancedStore
                        networkName: model.name
                        network: model.id
                        buttonGroup: radioGroup
                    }
                }
            }
        }
    }

    StyledText {
        anchors.top: svNetworks.bottom
        anchors.topMargin: Style.current.padding
        //% "Under development\nNOTE: You will be logged out and all installed\nsticker packs will be removed and will\nneed to be reinstalled. Purchased sticker\npacks will not need to be re-purchased."
        text: qsTrId("under-development-nnote--you-will-be-logged-out-and-all-installed-nsticker-packs-will-be-removed-and-will-nneed-to-be-reinstalled--purchased-sticker-npacks-will-not-need-to-be-re-purchased-")
    }
}
