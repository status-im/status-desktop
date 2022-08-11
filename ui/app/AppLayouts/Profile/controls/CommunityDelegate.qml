import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1

StatusListItem {
    property var community

    title: community.name
    subTitle: community.amISectionAdmin ? qsTr("Admin") : qsTr("Member")
    asset.name: !!community.image ? community.image : community.name
    asset.isImage: asset.name.includes("data")
    asset.letterSize: 14
    asset.isLetterIdenticon: !community.image
    asset.color: community.color
}
