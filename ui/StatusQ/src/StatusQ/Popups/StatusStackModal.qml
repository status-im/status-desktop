import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusModal {
    id: root

    property string stackTitle: qsTr("StackModal")
    property int subHeaderPadding: 16

    property alias stackItems: stackLayout.children
    property alias currentIndex: stackLayout.currentIndex
    property alias replaceItem: replaceLoader.sourceComponent
    property alias subHeaderItem: subHeaderLoader.sourceComponent

    readonly property int itemsCount: stackLayout.count
    readonly property var currentItem: stackLayout.currentItem

    property Item backButton: StatusBackButton {
        visible: replaceItem || stackLayout.currentIndex > 0
        onClicked: {
            if (replaceItem) {
                replaceItem = null;
            } else {
                let prevAction = stackLayout.currentItem.prevAction
                stackLayout.currentIndex--;
                if (typeof(prevAction) == "function") {
                    prevAction()
                }
            }
        }
    }

    property Item nextButton: StatusButton {
        text: qsTr("Next")
        onClicked: root.currentIndex++
    }

    property Item finishButton: StatusButton {
        text: qsTr("Finish")
        onClicked: root.close()
    }

    function replace(item) { replaceItem = item; }

    function updateRightButtons() {
        if (replaceItem) {
            nextButton.visible = false;
            finishButton.visible = false;
        } else if (currentIndex < itemsCount - 1) {
            nextButton.visible = true;
            finishButton.visible = false;
        } else {
            nextButton.visible = false;
            finishButton.visible = true;
        }
    }

    Component.onCompleted: updateRightButtons()
    onCurrentIndexChanged: updateRightButtons()
    onReplaceItemChanged: updateRightButtons()

    headerSettings.title: replaceLoader.item && typeof(replaceLoader.item.title) != "undefined"
                                                ? replaceLoader.item.title : stackTitle
    padding: 16

    leftButtons: [ backButton ]

    rightButtons: [ nextButton, finishButton ]

    Item {
        id: content
        anchors.fill: parent
        implicitWidth: Math.max(stackLayout.implicitWidth, subHeaderLoader.implicitWidth, replaceLoader.implicitWidth)
        implicitHeight: Math.max(stackLayout.implicitHeight +
                         (subHeaderLoader.item && subHeaderLoader.item.visible ? subHeaderLoader.height + root.subHeaderPadding : 0),
                         replaceLoader.implicitHeight)

        Loader {
            id: subHeaderLoader
            anchors.top: parent.top
            width: parent.width
            clip: true
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: subHeaderLoader.bottom
            anchors.bottom: parent.bottom

            clip: true

            anchors.bottomMargin: -root.padding
            anchors.leftMargin: -root.leftPadding
            anchors.rightMargin: -root.rightPadding
            anchors.topMargin: subHeaderLoader.item && subHeaderLoader.item.visible ? 0 : -root.padding

            StatusAnimatedStack {
                id: stackLayout

                anchors.fill: parent

                anchors.bottomMargin: root.padding
                anchors.leftMargin: root.leftPadding
                anchors.rightMargin: root.rightPadding
                anchors.topMargin: (subHeaderLoader.item && subHeaderLoader.item.visible ? root.subHeaderPadding : root.padding)

                visible: !replaceItem
                clip: false
            }


            Loader {
                id: replaceLoader
                anchors.fill: parent
                anchors.margins: root.padding
                visible: item
                clip: false
                onItemChanged: {
                    root.rightButtons = item ? item.rightButtons : [ nextButton, finishButton ]
                    if (!item && root.itemsCount == 0) {
                        root.close();
                    }
                }
            }
        }
    }
}
