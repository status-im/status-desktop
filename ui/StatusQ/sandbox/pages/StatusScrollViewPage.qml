import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Layout 0.1
import StatusQ.Platform 0.1
import StatusQ.Popups 0.1

Rectangle {
    id: root

    color: "transparent"

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    QtObject {
        id: d

        readonly property string text1: "felis imperdiet proin fermentum leo vel orci porta non pulvinar neque laoreet suspendisse interdum consectetur libero id faucibus nisl tincidunt eget nullam non nisi est sit amet facilisis magna etiam tempor orci eu lobortis elementum nibh tellus molestie nunc non blandit massa enim nec dui nunc mattis enim ut tellus elementum sagittis vitae et leo duis ut diam quam nulla porttitor massa id neque aliquam vestibulum morbi blandit cursus risus at ultrices mi tempus imperdiet nulla malesuada pellentesque elit eget gravida cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus mauris vitae ultricies leo integer malesuada nunc vel risus commodo viverra maecenas accumsan lacus vel facilisis volutpat est velit egestas dui id ornare arcu odio ut sem nulla pharetra diam sit amet nisl suscipit adipiscing bibendum est ultricies integer quis auctor elit sed vulputate mi sit amet mauris commodo quis imperdiet massa tincidunt nunc pulvinar sapien et ligula ullamcorper malesuada proin libero nunc consequat interdum varius sit amet mattis vulputate enim nulla aliquet porttitor lacus luctus accumsan tortor posuere ac ut consequat semper viverra nam libero justo laoreet sit amet cursus sit amet dictum sit amet justo donec enim diam vulputate ut pharetra sit amet aliquam id diam maecenas ultricies mi eget mauris pharetra et ultrices neque ornare aenean euismod elementum nisi quis eleifend quam adipiscing vitae proin sagittis nisl rhoncus mattis rhoncus urna neque viverra justo nec ultrices dui sapien eget mi proin sed libero enim sed faucibus turpis in eu mi bibendum neque egestas congue quisque egestas diam in arcu cursus euismod quis viverra nibh cras pulvinar mattis nunc sed blandit libero volutpat sed cras ornare arcu dui vivamus arcu felis bibendum ut tristique et egestas quis ipsum suspendisse ultrices gravida dictum fusce ut placerat orci nulla pellentesque dignissim enim sit amet venenatis urna cursus eget nunc scelerisque viverra mauris in aliquam sem fringilla ut morbi tincidunt augue interdum velit euismod in pellentesque massa placerat duis ultricies lacus sed turpis tincidunt id aliquet risus feugiat in ante metus dictum at tempor commodo ullamcorper a lacus vestibulum sed arcu non odio euismod lacinia at quis risus sed vulputate odio ut enim blandit volutpat maecenas volutpat blandit aliquam etiam erat velit scelerisque in dictum non consectetur a erat nam at lectus urna duis convallis convallis tellus id interdum velit laoreet id donec ultrices tincidunt arcu non sodales neque sodales ut etiam sit amet nisl purus in mollis"
        readonly property string text2: text1.repeat(8)
        readonly property int padding: 20
    }

    component Docs: StatusBaseText {
        id: docs
        textFormat: Text.MarkdownText
        wrapMode: Text.WordWrap

        onLinkActivated: (link) => {
            Qt.openUrlExternally(link)
        }

        MouseArea {
            anchors.fill: parent
            visible: !!docs.hoveredLink
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.NoButton
        }
    }

    component Modal: StatusModal {
        anchors.centerIn: parent
        headerSettings.title: `Popup with fixed width ${width}px`
        rightButtons: [ StatusButton { text: "Button" } ]
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 20

        Docs {
            Layout.fillWidth: true
            text:
"
## ScrollView
* single item: content size is automatically calculated based on the implicit size of its contained item.
* more than one item (or implicit size is not provided): the contentWidth and contentHeight must be set
* `ScrollView contentWidth: availableWidth` (this takes any padding or scroll bars into account)
* `Itemwidth: scrollView.availableWidth`
* Qt ScrollView has twitching bugs: [#5781](https://github.com/status-im/status-desktop/issues/5781)
* `contentItem` is a `Flickable`

Here's how `contentWidth` is calculated internally:
* [QQuickScrollViewPrivate::getContentWidth](https://codebrowser.dev/qt5/qtquickcontrols2/src/quicktemplates2/qquickscrollview.cpp.html#_ZNK23QQuickScrollViewPrivate15getContentWidthEv)
* [QQuickPanePrivate::getContentWidth](https://codebrowser.dev/qt5/qtquickcontrols2/src/quicktemplates2/qquickpane.cpp.html#_ZNK17QQuickPanePrivate15getContentWidthEv)
"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            StatusButton {
                type: StatusBaseButton.Type.Primary
                text: "StatusScrollView"
                onClicked: statusScrollViewPopup.open()
            }

            StatusButton {
                text: "ScrollView"
                onClicked: scrollViewPopup.open()
            }

            StatusButton {
                text: "ScrollView with applied fix"
                onClicked: fixedScrollViewPopup.open()
            }
        }

        Docs {
            Layout.fillWidth: true
            text:
"
## Flickable
* contentWidth and contentHeight must be set
* size of the contentItem is determined by contentWidth and contentHeight.
* items are parented to Flickable's contentItem
* items cannot anchor to Flickable. Use parent, which refers to the Flickable's contentItem
* `Item width: parent.width`
"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            StatusButton {
                text: "Flickable"
                onClicked: flickable1Popup.open()
            }

            StatusButton {
                text: "Flickable with attached ScrollBars"
                onClicked: flickable2Popup.open()
            }

            StatusButton {
                text: "Flickable with ScrollBars"
                onClicked: flickable3Popup.open()
            }
        }
    }

    Modal {
        id: scrollViewPopup

        ScrollView {
            id: scrollView
            anchors.fill: parent
            padding: d.padding
            contentWidth: availableWidth
            clip: true

            StatusBaseText {
                id: modalItem
                width: scrollView.availableWidth
                wrapMode: Text.WordWrap
                text: d.text2
            }
        }
    }

    Modal {
        id: fixedScrollViewPopup

        ScrollView {
            id: fixedScrollView
            anchors.fill: parent
            padding: d.padding
            contentWidth: availableWidth

            clip: true

            readonly property Flickable flickable: contentItem

            Component.onCompleted: {
                flickable.boundsBehavior = Flickable.StopAtBounds
                flickable.maximumFlickVelocity = 2000
                flickable.synchronousDrag = true
            }

            StatusBaseText {
                width: fixedScrollView.availableWidth
                wrapMode: Text.WordWrap
                text: d.text2
            }

            ScrollBar.horizontal: StatusScrollBar {
                parent: fixedScrollView
                x: fixedScrollView.mirrored ? 0 : fixedScrollView.width - width
                y: fixedScrollView.topPadding
                height: fixedScrollView.availableHeight
                active: fixedScrollView.ScrollBar.horizontal.active
                policy: ScrollBar.AlwaysOn
            }

            ScrollBar.vertical: StatusScrollBar {
                parent: fixedScrollView
                x: fixedScrollView.mirrored ? 0 : fixedScrollView.width - width
                y: fixedScrollView.topPadding
                height: fixedScrollView.availableHeight
                active: fixedScrollView.ScrollBar.horizontal.active
                policy: ScrollBar.AlwaysOn
            }
        }
    }


    Modal {
        id: flickable1Popup

        Flickable {
            id: flickable1
            anchors.fill: parent

            clip: true

            topMargin: d.padding
            bottomMargin: d.padding
            leftMargin: d.padding
            rightMargin: d.padding

            implicitWidth: contentWidth // + leftMargin + rightMargin
            implicitHeight: contentHeight + topMargin + bottomMargin

            contentHeight: contentItem.childrenRect.height

            StatusBaseText {
                id: fliackable1Item
                width: parent.width
                wrapMode: Text.WordWrap
                text: d.text2
            }
        }
    }

    Modal {
        id: flickable2Popup

        contentWidth: flickable2.implicitWidth
        contentHeight: flickable2.implicitHeight

        Flickable {
            id: flickable2
            anchors.fill: parent

            clip: true

            topMargin: d.padding
            bottomMargin: d.padding
            leftMargin: d.padding
            rightMargin: d.padding

            implicitWidth: contentWidth // + leftMargin + rightMargin
            implicitHeight: contentHeight + topMargin + bottomMargin

            contentHeight: flickable2Item.height

            ScrollBar.horizontal: StatusScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            ScrollBar.vertical: StatusScrollBar {
                policy: ScrollBar.AlwaysOn
            }

            StatusBaseText {
                id: flickable2Item
                width: parent.width
                wrapMode: Text.WordWrap
                text: d.text2
            }
        }
    }

    Modal {
        id: flickable3Popup

        contentWidth: flickable3.implicitWidth
        contentHeight: flickable3.implicitHeight

        Flickable {
            id: flickable3
            anchors.fill: parent

            clip: true

            topMargin: d.padding
            bottomMargin: d.padding
            leftMargin: d.padding
            rightMargin: d.padding

            implicitWidth: contentWidth // + leftMargin + rightMargin
            implicitHeight: contentHeight + topMargin + bottomMargin

            contentHeight: flickable3Item.height

            StatusBaseText {
                id: flickable3Item
                width: parent.width
                wrapMode: Text.WordWrap
                text: d.text2
            }
        }

        ScrollBar {
            id: vbar
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            size: flickable3.visibleArea.heightRatio
            position: flickable3.visibleArea.yPosition
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            policy: ScrollBar.AlwaysOn
        }

        ScrollBar {
            id: hbar
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Horizontal
            size: flickable3.visibleArea.widthRatio
            position: flickable3.visibleArea.xPosition
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            policy: ScrollBar.AlwaysOn
        }
    }

    Modal {
        id: statusScrollViewPopup

        StatusScrollView {
            id: statusScrollView
            anchors.fill: parent
            contentWidth: availableWidth
            padding: d.padding

            StatusBaseText {
                id: statusScrollViewItem
                width: statusScrollView.availableWidth
                wrapMode: Text.WordWrap
                text: d.text2
            }
        }
    }
}
