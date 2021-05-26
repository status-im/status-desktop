import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

Item {
    visible: chatsModel.activeChannel.chatType === Constants.chatTypeOneToOne &&
             !isContact &&
             !doNotShowAddToContactBannerToThose.includes(activeChatId)
    height: 36

    SVGImage {
        source: "../../../../img/plusSign.svg"
        anchors.right: addToContactsTxt.left
        anchors.rightMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        layer.enabled: true
        layer.effect: ColorOverlay { color: addToContactsTxt.color }
    }

    StyledText {
        id: addToContactsTxt
        text: qsTr("Add to contacts")
        color: Style.current.primary
        anchors.centerIn: parent
    }

    Separator {
        anchors.bottom: parent.bottom
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: profileModel.contacts.addContact(activeChatId)
    }

    StatusIconButton {
        id: closeBtn
        icon.name: "close"
        onClicked: {
            const newArray = Object.assign([], doNotShowAddToContactBannerToThose)
            newArray.push(activeChatId)
            doNotShowAddToContactBannerToThose = newArray
        }
        width: 20
        height: 20
        anchors.right: parent.right
        anchors.rightMargin: Style.current.halfPadding
        anchors.verticalCenter: parent.verticalCenter
    }
}
