import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

ApplicationWindow {
    id: root

    width: 1024
    height: 768
    visible: true

    property var model

    signal removeLinksRequested(var indexes)
    signal appendLinksRequested(var links)

    SwipeView {
        id: topSwipeView

        anchors.fill: parent

        orientation: Qt.Vertical
        interactive: false

        Page {
            ImagesGridView {
                id: grid

                anchors.fill: parent

                clip: true
                model: root.model

                onClicked: {
                    imagesSwipeView.setCurrentIndex(index)
                    topSwipeView.incrementCurrentIndex()
                }
            }

            Label {
                anchors.fill: parent

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                visible: grid.count === 0
                text: "To add a design, put a link to Figma directly in the Storybook's page code as a comment."
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
