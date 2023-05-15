import QtQuick 2.15

/// \note ensures data model always has consecutive Separator and Number after Base without duplicates except current element
/// \note for future work: split deleteInContent in deleteInContent and deleteElements and move data model to a DataModel object;
///     also fix code duplication in parseDerivationPath generating static level definitions and iterate through it
/// \note using Item to support embedded sub-components
Item {
    id: root

    required property color enabledColor
    required property color frozenColor
    required property color errorColor
    required property color warningColor

    /// Don't allow inserting more than \c levelsLimit Number elements
    property int levelsLimit: 0
    property bool complainTooBigAccIndex: true

    readonly property string inputError: qsTr("Please enter numbers only")
    readonly property string tooBigError: qsTr("Account number must be <100")
    readonly property string nonEthCoinWarning: qsTr("Non-Ethereum cointype")

    QtObject {
        id: d

        // d flag and named capture groups not supported in Qt 5.15. Use multiple regexes instead
        // Captured groups:                                     ?<coin_type_h> ?<coin_type_s> ?<account> ?<change>
        readonly property var derivationPathRegex: /^m\/44[’|']\/?(?:(.*?)[’|'])?(.*?)(?:\/(.*?)[’|']?)?(?:\/(.*?))?((?:\/.*?)?)$/
        // The expected characters before each group. Workaround to missing capture group offsets in Qt 5.15
        readonly property var offsets: [6, 0, 2, 2]

        readonly property int addressIndexStart: 3
        readonly property int ethereumCoinType: 60

        // Reference derivation path used to normalize separators (hardened or not). The last separator will be used
        property var referenceElements: []
        function initializeReferenceElementsIfRequired() {
            if (referenceElements.length === 0) {
                referenceElements = root.parseDerivationPath("m/44'/0'/1'/2/3")
            }
        }

        function createElement(content, startIndex, endIndex, contentType, isFrozen = false) {
            return elementComponent.createObject(root, {
                content: content,
                startIndex: startIndex,
                endIndex: endIndex,
                contentType: contentType,
                isFrozen: isFrozen});
        }
    }

    /// Returns null if the derivationPath is invalid or an array of Element objects if derivationPath is valid
    function parseDerivationPath(derivationPath) {
        const matches = d.derivationPathRegex.exec(derivationPath)
        if (matches === null) {
            return null
        }

        var elements = []
        var groupIndex = 0
        var currentIndex = 0

        // Extract the captured groups
        const coin_type_hardened = matches[1]
        const coin_type_simple = matches[2]
        const coin_type = coin_type_hardened || coin_type_simple
        const account = matches[3]
        const change = matches[4]
        const addressIndexes = matches[5] ? matches[5].substring(1) : ""; // remove the leading slash

        var nextIndex = coin_type != null ? d.offsets[groupIndex] : derivationPath.length
        elements.push(d.createElement(derivationPath.slice(currentIndex, nextIndex), currentIndex, nextIndex, Element.ContentType.Base))

        if (coin_type != null && nextIndex < derivationPath.length) {
            currentIndex = nextIndex
            nextIndex = currentIndex + coin_type.length
            elements.push(d.createElement(coin_type, currentIndex, nextIndex, Element.ContentType.Number))
            groupIndex += 2

            if(coin_type_simple && derivationPath.length > nextIndex) {
                return null
            }

            // Standard separator if there is an account otherwise keep the rest
            currentIndex = nextIndex
            nextIndex = (account != null ? currentIndex + d.offsets[groupIndex] : derivationPath.length)
            if(currentIndex < nextIndex) {
                elements.push(d.createElement(derivationPath.slice(currentIndex, nextIndex), currentIndex, nextIndex, Element.ContentType.Separator))
            }

            if(account != null) {
                currentIndex = nextIndex
                nextIndex = currentIndex + account.length
                elements.push(d.createElement(account, currentIndex, nextIndex, Element.ContentType.Number))
                groupIndex++

                currentIndex = nextIndex
                nextIndex = (change != null ? currentIndex + d.offsets[groupIndex] : derivationPath.length)
                if(currentIndex < nextIndex) {
                    elements.push(d.createElement(derivationPath.slice(currentIndex, nextIndex), currentIndex, nextIndex, Element.ContentType.Separator))
                }

                if(change != null) {
                    currentIndex = nextIndex
                    nextIndex = currentIndex + change.length
                    elements.push(d.createElement(change, currentIndex, nextIndex, Element.ContentType.Number))

                    // Check if there are any address indexes
                    if (matches[5] != null && matches[5].length > 0) {
                        const addressIndexesParts = addressIndexes.split('/')
                        for (const addressIndex of addressIndexesParts) {
                            currentIndex = nextIndex
                            nextIndex = currentIndex + 1
                            elements.push(d.createElement(derivationPath.slice(currentIndex, nextIndex), currentIndex, nextIndex, Element.ContentType.Separator))

                            currentIndex = nextIndex
                            nextIndex = currentIndex + addressIndex.length
                            elements.push(d.createElement(addressIndex, currentIndex, nextIndex, Element.ContentType.Number))
                        }
                    }
                } else if(addressIndexes.length > 0) {
                    return null
                }
            } else if(change || addressIndexes.length > 0) {
                return null
            }
        } else if(account || change || addressIndexes.length > 0) {
            return null
        }
        return elements
    }

    function generateHtmlFromElements(elements) {
        // d class is disabled; e class is editable; f class is error; w class is warning
        var res = `<style>.d{color:${root.frozenColor};}.e{color:${root.enabledColor};}.f{color:${root.errorColor};}.w{color:${root.warningColor};}</style>`
        const format = (content, cssClass) => `<span class="${cssClass}">${content}</span>`

        var numberLevel = 0
        for(var i = 0; i < elements.length; i++) {
            if (elements[i].isFrozen) {
                res += format(elements[i].content, "d")
            } else if(validateElement(elements[i], elements[i].isNumber() ? numberLevel : -1).error.length > 0) {
                res += format(elements[i].content, "f")
            } else if(validateElement(elements[i], elements[i].isNumber() ? numberLevel : -1).warning.length > 0) {
                res += format(elements[i].content, "w")
            } else {
                res += format(elements[i].content, "e")
            }
            if(elements[i].isNumber()) {
                numberLevel++
            }
        }
        return res
    }

    Component {
        id: completedDerivationPathComponent
        QtObject {
            required property var elements
            required property string errorMessage
        }
    }

    /// Matches the derivation path with a base path and freezes the base path elements
    /// It also completes last separator and content if needed
    /// \return CompletedDerivationPath
    function completeDerivationPath(basePath, derivationPath) {
        const errorResponse = () => {
            const res = completedDerivationPathComponent.createObject(root, {
                elements: [],
                errorMessage: root.inputError
            })
            return res
        }

        const baseElements = root.parseDerivationPath(basePath)
        if (!baseElements) {
            console.info(`Invalid base of derivation path: ${basePath}`)
            return errorResponse()
        }

        var elements = root.parseDerivationPath(derivationPath)
        if (!elements) {
            console.info(`Invalid derivation path: ${derivationPath}`)
            return errorResponse()
        }

        if(baseElements.length > elements.length) {
            console.info(`Base path elements length (${baseElements.length}) bigger than path length (${elements.length})`)
            return errorResponse()
        }

        for(const i in elements) {
            if(i < baseElements.length) {
                if(!baseElements[i].isSimilar(elements[i])) {
                    console.warn(`Base content "${baseElements[i].content}" doesn't match derivation path content "${elements[i].content}" for index ${i}`)
                    return errorResponse()
                }
                elements[i].isFrozen = true
            } else {
                elements[i].isFrozen = !elements[i].isNumber()
            }
        }

        if(elements[elements.length - 1].isBase()
                && (elements[elements.length - 1].content.slice(-1) === "'" || elements[elements.length - 1].content.slice(-1) === "’")) {
            elements[elements.length - 1].content += "/"
        }
        if(elements[elements.length - 1].isSeparator() || elements[elements.length - 1].isBase()) {
            elements.push(d.createElement("", elements[elements.length - 1].endIndex, elements[elements.length - 1].endIndex, Element.ContentType.Number))
        }
        normalizeAndRemoveDuplicateSeparators(elements, elements.length - 1)

        let res = completedDerivationPathComponent.createObject(root, {
            elements: elements,
            errorMessage: ""
        })

        return res
    }

    /// \return true if an element was added
    function tryAddAndFixSeparators(elements, insertIndex, insertLeft = false) {
        if(root.levelsLimit > 0 && countNonEmptyLevels(elements) >= root.levelsLimit) {
            return -1
        }
        return addAndFixSeparators(elements, insertIndex, insertLeft)
    }

    /// \return the newly created element's index or -1 if no element was created
    function addAndFixSeparators(elements, insertIndex, insertLeft = false) {
        var finalInsertIndex = insertIndex
        var newContentIndex = 0
        if(insertLeft) {
            while(finalInsertIndex >= 0 && elements[finalInsertIndex].isFrozen) {
                finalInsertIndex--
            }
            if(finalInsertIndex >= 0) {
                newContentIndex = finalInsertIndex
                elements.splice(newContentIndex, 0, d.createElement("", elements[finalInsertIndex - 1].endIndex, elements[finalInsertIndex - 1].endIndex, Element.ContentType.Number))
                elements.splice(finalInsertIndex + 1, 0, d.createElement("/", elements[finalInsertIndex].endIndex, elements[finalInsertIndex].endIndex + 1, Element.ContentType.Separator, true))
            } else {
                insertLeft = false
                finalInsertIndex = insertIndex
            }
        }
        if(!insertLeft) {
            while(finalInsertIndex < elements.length && !elements[finalInsertIndex].isFrozen) {
                finalInsertIndex++
            }

            elements.splice(finalInsertIndex, 0, d.createElement("/", elements[finalInsertIndex - 1].endIndex, elements[finalInsertIndex - 1].endIndex + 1, Element.ContentType.Separator, true))
            newContentIndex = finalInsertIndex + 1
            elements.splice(newContentIndex, 0, d.createElement("", elements[finalInsertIndex].endIndex, elements[finalInsertIndex].endIndex, Element.ContentType.Number))
        }

        normalizeAndRemoveDuplicateSeparators(elements, newContentIndex)
        return findFirstEmptyContent(elements)
    }

    function insertContent(elements, elementIndex, text, cursorPos) {
        while(elementIndex < (elements.length - 1) && (!elements[elementIndex].isNumber() || elements[elementIndex].isFrozen)) {
            elementIndex++
        }
        if(cursorPos < elements[elementIndex].startIndex)
            cursorPos = elements[elementIndex].endIndex
        const element = elements[elementIndex]
        const insertIdx = cursorPos - element.startIndex
        element.content = element.content.slice(0, insertIdx) + text + element.content.slice(insertIdx)
        element.endIndex += text.length
        controller.updateFollowingIndices(elements, elementIndex)
    }

    /// \return cursor offset
    function deleteInContent(elements, elementIndex, cursorPos, deleteRightOfCursor = true) {
        const element = elements[elementIndex]
        var deleteIdx = -1  // Also marks content change
        var cursorOffset = 0
        var startOfIndicesUpdate = elementIndex
        if(deleteRightOfCursor) {
            if (cursorPos === element.endIndex) {
                // If at the end of the content delete next separator and merge content
                if((elementIndex + 2) < elements.length && elements[elementIndex + 1].isSeparator() && !elements[elementIndex + 2].isFrozen) {
                    const newContent = element.content + elements[elementIndex + 2].content
                    elements.splice(elementIndex + 1, 2)
                    element.content = newContent
                    startOfIndicesUpdate = elementIndex
                }
            } else {
                deleteIdx = cursorPos - element.startIndex
            }
        } else {
            if (cursorPos === element.startIndex) {
                // If at content's beginning delete left separator and merge content
                var deletedChars = 0
                if((elementIndex - 2) > 0 && elements[elementIndex - 1].isSeparator() && !elements[elementIndex - 2].isFrozen) {
                    const newContent = elements[elementIndex - 2].content + element.content
                    cursorOffset = -(elements[elementIndex - 1].content.length)
                    elements.splice(elementIndex - 2, 2)
                    element.content = newContent
                    startOfIndicesUpdate = elementIndex - 2
                }
            } else {
                deleteIdx = cursorPos - element.startIndex - 1
                cursorOffset = -1
            }
        }
        if(deleteIdx > -1) {
            element.content = element.content.slice(0, deleteIdx) + element.content.slice(deleteIdx + 1)
            element.endIndex -= 1
        }
        controller.updateFollowingIndices(elements, startOfIndicesUpdate)
        return cursorOffset
    }

    function countNonEmptyLevels(elements) {
        var count = 0
        for(var i = 0; i < (elements.length-1); i++) {
            if((elements[i].isSeparator() || elements[i].isBase()) && elements[i + 1].isNumber() && !elements[i + 1].isEmptyNumber()) {
                count++
            }
        }
        return count
    }

    function normalizeAndRemoveDuplicateSeparators(elements, exceptIndex) {
        var currentContent = ""

        var markToDelete = []
        for(var i = 0; i < (elements.length - 1); i++) {
            if(elements[i].isEmptyNumber() && elements[i+1].isSeparator() && i !== exceptIndex) {
                markToDelete.push(i)
                markToDelete.push(i + 1)
            }
        }
        // Cleanup the last separator if it is the case
        if(elements.length > 2 && elements[elements.length - 2].isSeparator() && elements[elements.length - 1].isEmptyNumber() && (elements.length - 1) !== exceptIndex) {
            markToDelete.push(elements.length - 2)
            markToDelete.push(elements.length - 1)
        }
        for (var i = markToDelete.length - 1; i >= 0; i--) {
            elements.splice(markToDelete[i], 1)
        }

        d.initializeReferenceElementsIfRequired()
        // Normalize separators
        for(var i = 0; i < elements.length; i++) {
            if(i < d.referenceElements.length && d.referenceElements[i].isSeparator()) {
                currentContent = d.referenceElements[i].content
            } // else: use the last separator

            if(elements[i].isSeparator() && currentContent.length > 0 && elements[i].content !== currentContent) {
                elements[i].content = currentContent
            }
        }

        updateFollowingIndices(elements, 0)
    }

    function updateFollowingIndices(elements, firstElementIndex) {
        for(var i = firstElementIndex; i < elements.length; i++) {
            if(i == 0) {
                elements[i].startIndex = 0
            } else {
                elements[i].startIndex = elements[i - 1].endIndex
            }
            elements[i].endIndex = elements[i].startIndex + elements[i].content.length
        }
    }

    function findFirstEmptyContent(elements) {
        for(var i = 0; i < elements.length; i++) {
            if(elements[i].content.length === 0) {
                return i
            }
        }
        return -1
    }

    function deleteFromStartToEnd(elements, startPos, endPos) {
        var startIndex = -1
        var endIndex = -1
        for(var i = 0; i < elements.length; i++) {
            if(startIndex == -1 && startPos >= elements[i].startIndex) {
                startIndex = i
            } else if(endIndex == -1 && endPos <= elements[i].startIndex) {
                endIndex = i
            }
        }
        elements.splice(startIndex, endIndex - startIndex)
        updateFollowingIndices(elements, 0)
    }

    /// \return the object {error: "", warning: ""}
    function validateAllElements(elements) {
        var numberLevel = 0
        var warningMessage = ""
        for(var i = 0; i < elements.length; i++) {
            const res = validateElement(elements[i], elements[i].isNumber() ? numberLevel : -1)
            if(res.error.length > 0) {
                return res
            } else if(res.warning.length > 0 && warningMessage === "") {
                warningMessage = res.warning
            }
            if(elements[i].isNumber()) {
                numberLevel++
            }
        }
        return {error: "", warning: warningMessage}
    }

    /// Expect -1 if not an number element
    /// \return the object {error: "", warning: ""}
    function validateElement(element, numberLevel) {
        if(numberLevel > -1 && !element.validateNumber() && !element.isEmptyNumber()) {
            return {error: root.inputError, warning: ""}
        } else if(numberLevel == 0 && !element.isEmptyNumber() && element.number() != d.ethereumCoinType) {
            return {error: "", warning: root.nonEthCoinWarning}
        } else if(root.complainTooBigAccIndex && numberLevel >= d.addressIndexStart && element.number() >= 100) {
            return {error: root.tooBigError, warning: ""}
        }
        return {error: "", warning: ""}
    }


    Component {
        id: elementComponent
        Element {
            content: ""
            startIndex: 0
            endIndex: 0
            contentType: 0
        }
    }
}
