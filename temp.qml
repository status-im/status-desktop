// 1. Simple example with an image

StatusScrollView {
    anchors.fill: parent

    Image {
        source: "https://placekitten.com/400/600"
    }
}

// 2. Simple example with ColumnLayout

StatusScrollView {
    id: scrollView

    anchors.fill: parent
    contentWidth: availableWidth

    ColumnLayout {
        width: scrollView.availableWidth
    }
}

// 3. 

StatusModal {
    padding: 0

    StatusScrollView {
        id: scrollView

        anchors.fill: parent
        implicitWidth: 400
        contentWidth: availableWidth
        padding: 16

        Text {
            width: scrollView.availableWidth
            wrapMode: Text.WrapAnywhere
            text: "long text here"
        }
    }
}

// 4.

StatusModal {
    padding: 16

    ColumnLayout {
        anchors.fill: parent

        Text {
            Layout.fillWidth: true
            text: "This header is fixed and not scrollable"
        }

        Item {
            id: scrollViewWrapper

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: scrollView.implicitWidth
            implicitHeight: scrollView.implicitHeight

            StatusScrollView {
                id: scrollView
                
                anchors.fill: parent
                contentWidth: availableWidth
                padding: 0

                ScrollBar.vertical: StatusScrollBar {
                    parent: scrollViewWrapper    // parent to wrapper
                    anchors.top: scrollView.top
                    anchors.bottom: scrollView.bottom
                    anchors.left: scrollView.right
                    anchors.leftMargin: 1
                }

                Text {
                    width: scrollView.availableWidth
                    wrapMode: Text.WrapAnywhere
                    text: "long scrollable text here"
                }
            }
        }
    }
}
