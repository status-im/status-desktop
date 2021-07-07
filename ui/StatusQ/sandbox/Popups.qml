import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

Column {
    spacing: 20

    StatusButton {
        text: "Simple modal"
        onClicked: simpleModal.open()
    }

    StatusButton {
        text: "Modal with header image"
        onClicked: headerImageModal.open()
    }

    StatusButton {
        text: "Modal with footer buttons"
        onClicked: footerButtonsModal.open()
    }

    StatusButton {
        text: "Modal with header action button"
        onClicked: headerActionButtonModal.open()
    }

    StatusButton {
        text: "Modal with content"
        onClicked: modalExample.open()
    }

    StatusButton {
        text: "Modal with changable content"
        onClicked: modalWithContentAccess.open()
    }

    StatusModal {
        id: simpleModal
        anchors.centerIn: parent
        header.title: "Some Title"
        header.subTitle: "Subtitle"
    }

    StatusModal {
        id: headerImageModal
        anchors.centerIn: parent
        header.title: "Some Title"
        header.subTitle: "Subtitle"
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
    }

    StatusModal {
        id: footerButtonsModal
        anchors.centerIn: parent
        header.title: "Some Title"
        header.subTitle: "Subtitle"
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
        leftButtons: [
            StatusRoundButton {
                icon.name: "arrow-right"
                rotation: 180
            }
        ]
        rightButtons: [
            StatusButton {
                text: "Button"
            },
            StatusButton {
                text: "Button"
            }
        ]
    }

    StatusModal {
        id: headerActionButtonModal
        anchors.centerIn: parent
        header.title: "Some Title"
        header.subTitle: "Subtitle"
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"

        headerActionButton: StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 32
            height: 32

            icon.width: 20
            icon.height: 20
            icon.name: "info"
        }

        leftButtons: [
            StatusRoundButton {
                icon.name: "arrow-right"
                rotation: 180
            }
        ]
        rightButtons: [
            StatusButton {
                text: "Button"
            },
            StatusButton {
                text: "Button"
            }
        ]
    }

    StatusModal {
        id: modalExample
        anchors.centerIn: parent
        header.image.source: "https://pbs.twimg.com/profile_images/1369221718338895873/T_5fny6o_400x400.jpg"
        header.title: "Header"
        header.subTitle: "SubTitle"
        rightButtons: [
            StatusButton {
                text: "Button"
            },
            StatusButton {
                text: "Button"
            }
        ]

        leftButtons: [
            StatusRoundButton {
                icon.name: "arrow-right"
                rotation: 180
            }
        ]

        content: StatusBaseText {
            anchors.centerIn: parent
            text: "Some text content"
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        headerActionButton: StatusFlatRoundButton {
            type: StatusFlatRoundButton.Type.Secondary
            width: 32
            height: 32

            icon.width: 20
            icon.height: 20
            icon.name: "info"
        }
    }

    StatusModal {
        id: modalWithContentAccess
        anchors.centerIn: parent
        header.title: "Header"
        header.subTitle: "SubTitle"

        content: StatusBaseText {
            id: text
            anchors.centerIn: parent
            text: "Some text content"
            font.pixelSize: 15
            color: Theme.palette.directColor1
        }

        rightButtons: [
            StatusButton {
                text: "Change text"
                onClicked: {
                    modalWithContentAccess.contentComponent.text = "Changed!"
                }
            }
        ]
    }
}
