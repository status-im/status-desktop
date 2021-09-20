import QtQuick 2.14
import QtQuick.Controls 2.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import "../components" as WalletComponents
import "../../../../imports"

Item {
    id: assetsItemRoot

    function open() {

        contentLoader.sourceComponent = contentComponent

        rightPanelRoot.switchTo(rightPanelRoot.rightPanelViewMainTabActivity)
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
                text: qsTr("Assets")
                onClicked: function (){
                    rightPanelRoot.switchTo(rightPanelRoot.rightPanelViewMain,
                                            rightPanelRoot.rightPanelViewMainTabAssets)

                    contentLoader.sourceComponent = undefined
                }
            }

            //graph placeholder
            Rectangle {
                width: 649
                height: 253
                anchors.centerIn: parent
                color: "pink"
                opacity: 0.3
            }
        }
    }
}
