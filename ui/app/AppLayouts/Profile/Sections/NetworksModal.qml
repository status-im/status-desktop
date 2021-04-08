import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    //% "Network"
    title: qsTrId("network")

    property string newNetwork: "";
 
    ScrollView {
        id: svNetworks
        width: parent.width
        height: 300
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

                StatusRoundButton {
                    id: addButton
                    icon.name: "plusSign"
                    size: "medium"
                    type: "secondary"
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
                    font.pixelSize: 15
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: openPopup(addNetworkPopupComponent)
                }
            }

            Component {
                id: addNetworkPopupComponent
                NewCustomNetworkModal {
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


                StatusSectionHeadline {
                    //% "Main networks"
                    text: qsTrId("main-networks")
                }


                NetworkRadioSelector {
                    network: Constants.networkMainnet
                }

                NetworkRadioSelector {
                    network: Constants.networkPOA
                }

                NetworkRadioSelector {
                    network: Constants.networkXDai
                }

                StatusSectionHeadline {
                    //% "Test networks"
                    text: qsTrId("test-networks")
                    anchors.leftMargin: -Style.current.padding
                    anchors.rightMargin: -Style.current.padding
                }

                NetworkRadioSelector {
                    network: Constants.networkGoerli
                }

                NetworkRadioSelector {
                    network: Constants.networkRinkeby
                }

                NetworkRadioSelector {
                    network: Constants.networkRopsten
                }

                StatusSectionHeadline {
                    //% "Custom Networks"
                    text: qsTrId("custom-networks")
                    anchors.leftMargin: -Style.current.padding
                    anchors.rightMargin: -Style.current.padding
                }

                Repeater {
                    model: profileModel.network.customNetworkList
                    delegate: NetworkRadioSelector {
                        networkName: name
                        network: customNetworkId
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
