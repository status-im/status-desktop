import QtQuick 2.12
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property alias membershipRequestList: membershipRequestList

    id: popup

    onOpened: {
        errorText.text = ""
    }

    header: Item {
        height: 60
        width: parent.width

        StyledText {
            id: titleText
            text: qsTr("Membership requests")
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: parent.left
            font.bold: true
            font.pixelSize: 17
            wrapMode: Text.WordWrap
        }

        StyledText {
            id: nbRequestsText
            text: membershipRequestList.count
            width: 160
            anchors.left: titleText.left
            anchors.top: titleText.bottom
            anchors.topMargin: 2
            font.pixelSize: 15
            color: Style.current.darkGrey
        }

        Separator {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            anchors.leftMargin: -Style.current.padding
        }
    }

    Item {
        anchors.fill: parent

        StyledText {
            id: errorText
            visible: !!text
            height: visible ? implicitHeight : 0
            color: Style.current.danger
            anchors.top: parent.top
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            anchors.topMargin: visible ? Style.current.smallPadding : 0
            width: parent.width
        }

        ListView {
            id: membershipRequestList
            model: chatsModel.communities.activeCommunity.communityMembershipRequests
            anchors.top: errorText.bottom
            anchors.topMargin: Style.current.smallPadding
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: -Style.current.padding
            anchors.leftMargin: -Style.current.padding
            height: parent.height

            delegate: Item {
                property int contactIndex: profileModel.contacts.list.getContactIndexByPubkey(publicKey)
                property string identicon: utilsModel.generateIdenticon(publicKey)
                property string profileImage: contactIndex === -1 ? identicon :
                                                                    profileModel.contacts.list.rowData(contactIndex, 'thumbnailImage') || identicon
                property string displayName: Utils.getDisplayName(publicKey, contactIndex)

                id: requestLine
                height: 52
                width: parent.width

                StatusImageIdenticon {
                    id: accountImage
                    width: 36
                    height: 36
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source: requestLine.profileImage
                    anchors.leftMargin: Style.current.padding
                }

                StyledText {
                    text: requestLine.displayName
                    elide: Text.ElideRight
                    anchors.left: accountImage.right
                    anchors.leftMargin: Style.current.padding
                    anchors.right: thumbsUp.left
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 15
                    color: Style.current.darkGrey
                }

                SVGImage {
                    id: thumbsUp
                    source: "../../../img/thumbsUp.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: thumbsDown.left
                    anchors.rightMargin: Style.current.padding
                    width: 28

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            errorText.text = ""
                            const error = chatsModel.communities.acceptRequestToJoinCommunity(id)
                            if (error) {
                                errorText.text = error
                            }
                        }
                    }
                }

                SVGImage {
                    id: thumbsDown
                    source: "../../../img/thumbsDown.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    width: 28

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            errorText.text = ""
                            const error = chatsModel.communities.declineRequestToJoinCommunity(id)
                            if (error) {
                                errorText.text = error
                            }
                        }
                    }
                }
            }

        }
    }

    footer: StatusRoundButton {
        id: btnBack
        anchors.left: parent.left
        icon.name: "arrow-right"
        icon.width: 20
        icon.height: 16
        rotation: 180
        onClicked: popup.close()
    }
}
