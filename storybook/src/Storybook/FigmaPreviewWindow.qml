import QtQuick 2.14
import QtQuick.Controls 2.14

ApplicationWindow {
    id: root

    width: 1024
    height: 768
    visible: true

    property var model

    SwipeView {
        id: topSwipeView

        anchors.fill: parent

        orientation: Qt.Vertical
        interactive: false

        ImagesGridView {
            clip: true
            model: root.model

            onClicked: {
                imagesSwipeView.setCurrentIndex(index)
                topSwipeView.incrementCurrentIndex()
            }
        }

        Item {
            SwipeView {
                id: imagesSwipeView

                anchors.fill: parent
                currentIndex: imageNavigationLayout.currentIndex

                Repeater {
                    id: repeater

                    model: root.model

                    FlickableImage {
                        source: model.imageLink
                    }
                }
            }

            ImagesNavigationLayout {
                id: imageNavigationLayout

                anchors.bottom: imagesSwipeView.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                count: imagesSwipeView.count
                currentIndex: imagesSwipeView.currentIndex

                onUp: topSwipeView.decrementCurrentIndex()
                onLeft: imagesSwipeView.decrementCurrentIndex()
                onRight: imagesSwipeView.incrementCurrentIndex()
            }
        }
    }
}
