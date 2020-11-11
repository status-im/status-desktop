import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import QtGraphicalEffects 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup

    onOpened: {
        searchBox.text = "";
        searchBox.forceActiveFocus(Qt.MouseFocusReason)
    }

    title: qsTr("Communities")

    SearchBox {
        id: searchBox
        iconWidth: 17
        iconHeight: 17
        customHeight: 36
        fontPixelSize: 15
    }

    ScrollView {
        id: scrollView
        width: parent.width
        anchors.topMargin: Style.current.padding
        anchors.top: searchBox.bottom
        anchors.bottom: parent.bottom
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: communitiesList.contentHeight > communitiesList.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

        ListView {
            anchors.fill: parent
            model: chatsModel.communities
            spacing: 0
            clip: true
            id: communitiesList
            delegate: Item {
                height: childrenRect.height

                Image {
                    id: communityImage
                    width: 40
                    height: 40
                    source: "../../../img/ens-header-dark@2x.png"

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            anchors.centerIn: parent
                            width: communityImage.width
                            height: communityImage.height
                            radius: imagePreview.width / 2
                        }
                    }
                }

                StyledText {
                    text: description
                    anchors.left: communityImage.right
                    anchors.leftMargin: Style.current.padding
                }
            }
        }
    }
    
    footer: StatusButton {
        text: qsTr("Create a community")
        anchors.right: parent.right
        onClicked: {
            openPopup(createCommunitiesPopupComponent)
            popup.close()
        }
    }
}

