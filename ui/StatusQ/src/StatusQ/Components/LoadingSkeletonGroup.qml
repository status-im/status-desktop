import QtQuick

/*!
   \qmltype LoadingSkeletonGroup
   \inherits Item
   \inqmlmodule StatusQ.Components
   \since StatusQ.Components 0.1
   \brief Renders an arbitrary arrangement of LoadingSkeletonTile shapes with a
   single continuous shimmer sweep across the whole group.

   Use this for creation-time skeleton screens instead of many LoadingComponent
   instances, so that the shimmer runs across the arrangement as one band.

   Example:

   \qml
    LoadingSkeletonGroup {
        width: 200
        height: 60

        Row {
            spacing: 8
            LoadingSkeletonTile { width: 40; height: 40; radius: 20 }
            Column {
                spacing: 6
                LoadingSkeletonTile { width: 120; height: 14 }
                LoadingSkeletonTile { width: 80; height: 12 }
            }
        }
    }
   \endqml
*/
Item {
    id: root

    default property alias contentData: shapesContainer.data

    Item {
        id: shapesContainer
        anchors.fill: parent
    }
}
