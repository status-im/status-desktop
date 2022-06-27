import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

StatusModal {
    id: root

    /*
    stackItems
    Attached properties:
        canGoNext

    replaceItem
    Attached properties:
        title
        acceptButton
    */

    property string stackTitle: qsTr("StackModal")

    property alias stackItems: stackLayout.children
    property alias currentIndex: stackLayout.currentIndex
    property alias replaceItem: replaceLoader.sourceComponent

    readonly property int itemsCount: stackLayout.children.length
    readonly property var currentItem: stackLayout.currentItem

    property Item nextButton: StatusButton {
        text: qsTr("Next")
        enabled: !!currentItem && (typeof(currentItem.canGoNext) == "undefined" || currentItem.canGoNext)
        onClicked: currentIndex++
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

    onCurrentIndexChanged: updateRightButtons()
    onReplaceItemChanged: updateRightButtons()

    width: 640
    height: Math.max(implicitHeight, replaceLoader.implicitHeight)
    padding: 16

    header.title: replaceLoader.item && typeof(replaceLoader.item.title) != "undefined"
                                                ? replaceLoader.item.title : stackTitle

    leftButtons: StatusRoundButton {
        id: backButton
        icon.name: "arrow-right"
        icon.width: 20
        icon.height: 16
        rotation: 180
        visible: replaceItem || stackLayout.currentIndex > 0
        onClicked: {
            if (replaceItem)
                replaceItem = null;
            else
                stackLayout.currentIndex--;
        }
    }

    rightButtons: [ nextButton, finishButton ]

    Item {
        id: content
        anchors.fill: parent
        implicitWidth: stackLayout.implicitWidth
        implicitHeight: stackLayout.implicitHeight
        clip: true

        StatusAnimatedStack {
            id: stackLayout
            anchors.fill: parent
            visible: !replaceItem
        }

        Loader {
            id: replaceLoader
            anchors.fill: parent
            visible: item
            onItemChanged: {
                root.rightButtons = item ? item.rightButtons : [ nextButton, finishButton ]
                if (!item && root.itemsCount == 0) {
                    root.close();
                }
            }
        }
    }
}