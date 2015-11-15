window.ContentSelect = {}

class ContentSelect.Range

    # A range representing a content selection on the page

    constructor: (from, to) ->
        @set(from, to)

    # Read-only properties

    isCollapsed: () ->
        # Return true if the range is collapsed (span of 0)
        return @_from == @_to

    span: () ->
        # Return the span (distance between the start and end) of the range
        return @_to - @_from

    # Methods

    collapse: () ->
        # Collapse the range (right to left)
        @_to = @_from

    eq: (range) ->
        # Return true if the specified range is equal to this range
        return @get()[0] == range.get()[0] and @get()[1] == range.get()[1]

    get: () ->
        # Return the range values as an array [start, end]
        return [@_from, @_to]

    select: (element) ->
        # Select the range of content within the specified node

        # Clear any existing selections
        ContentSelect.Range.unselectAll()

        docRange = document.createRange()

        # Find the start/end nodes
        [startNode, startOffset] = _getChildNodeAndOffset(element, @_from)
        [endNode, endOffset] = _getChildNodeAndOffset(element, @_to)

        # Set the range start/end
        startNodeLen = startNode.length or 0;
        endNodeLen = endNode.length or 0;
        docRange.setStart(startNode, Math.min(startOffset, startNodeLen))
        docRange.setEnd(endNode, Math.min(endOffset, endNodeLen))

        # Select the range
        window.getSelection().addRange(docRange)

    set: (from, to) ->
        # Set the range values

        # Don't allow values less then 0
        from = Math.max(0, from)
        to = Math.max(0, to)

        # Ensure the values are set in the correct order from (smallest) to
        # (largest).
        @_from = Math.min(from, to)
        @_to = Math.max(from, to)

    # Class methods

    @prepareElement: (element) ->
        # Prepare an element so that it supports content querying and selection.
        # This method should be called once before the `select` or `query`
        # methods are used but does not need to be called subsequently.

        # Find every self-closing node within the element
        selfClosingNodes = element.querySelectorAll(
            SELF_CLOSING_NODE_NAMES.join(', ')
            )

        # Wrap each of the self-closing nodes in an empty text node accept for
        # the last (FF adds additional spacing if the last self-closing element
        # has an appended empty text node).
        for node, i in selfClosingNodes
            node.parentNode.insertBefore(document.createTextNode(''), node)

            if i < selfClosingNodes.length - 1
                node.parentNode.insertBefore(
                    document.createTextNode(''),
                    node.nextSibling
                    )

    @query: (element) ->
        # Return a range for the content selected within the specified element

        range = new ContentSelect.Range(0, 0)

        # Get the first selection
        try
            docRange = window.getSelection().getRangeAt(0)
        catch
            return range

        # Check for null first & last child (Firefox)
        if element.firstChild is null and element.lastChild is null
            return range

        # Make sure the selection is contained within the specifed element
        if not _containedBy(docRange.startContainer, element)
            return range

        if not _containedBy(docRange.endContainer, element)
            return range

        # Get the range values relative to the nodes it starts/ends in
        [startNode, startOffset, endNode, endOffset] = _getNodeRange(
            element,
            docRange
            )

        # Set the range values relative to the element
        range.set(
            _getOffsetOfChildNode(element, startNode) + startOffset,
            _getOffsetOfChildNode(element, endNode) + endOffset
            )

        return range

    @rect: () ->
        # Return a bounding rectangle for the currently selected range

        # Get the first selection
        try
            docRange = window.getSelection().getRangeAt(0)
        catch
            return null

        # HACK: Fix for bug in chrome where collapsed ranges don't return a
        # bounding rect.
        if docRange.collapsed

            # To solve the issue we insert a marker node to query for the rect
            # and then remove it once done.
            marker = document.createElement('span')
            docRange.insertNode(marker)
            rect = marker.getBoundingClientRect()
            marker.parentNode.removeChild(marker)

            return rect

        else
            return docRange.getBoundingClientRect()

    @unselectAll: () ->
        # Unselect all selected content on the page
        if window.getSelection()
            window.getSelection().removeAllRanges()


# The following constants and functions are private to the module, they are not
# accessible outside of this file.

# A list of names for inline nodes (must be specified as lowercase)
SELF_CLOSING_NODE_NAMES = ['br', 'img', 'input']

_containedBy = (nodeA, nodeB) ->
    # Return true if nodeA is contained in nodeB

    while nodeA
        if nodeA == nodeB
            return true
        nodeA = nodeA.parentNode

    return false

_getChildNodeAndOffset = (parentNode, parentOffset) ->
    # Given a parent node and offset (in characters), find and return the child
    # node the parent offset falls within, and the offset relative to that
    # child. The child node does not have to be a direct descendant.

    # If a parentNode with no child nodes is passed to the function then it
    # returns the arguments passed in (as there are no children to search).
    if (parentNode.childNodes.length == 0)
        return [parentNode, parentOffset]

    # We use a stack structure to parse the tree structure of the parent node
    childNode = null
    childOffset = parentOffset
    childStack = (n for n in parentNode.childNodes)

    while childStack.length > 0
        childNode = childStack.shift()

        # Process each child node based on the type of node
        switch childNode.nodeType

            # Text nodes
            when Node.TEXT_NODE

                # Found - stop processing and return
                if childNode.textContent.length >= childOffset
                    return [childNode, childOffset]

                # Update the offset to reflect that we've moved passed this node
                childOffset -= childNode.textContent.length

            # Elements
            when Node.ELEMENT_NODE

                # Inline block elements count as a single character
                if childNode.nodeName.toLowerCase() in SELF_CLOSING_NODE_NAMES
                    if childOffset == 0
                        return [childNode, 0]
                    else
                        childOffset = Math.max(0, childOffset - 1)

                # For elements that support children we prepend any children to
                # the stack to be processed.
                else
                    if childNode.childNodes
                        Array::unshift.apply(
                            childStack,
                            (n for n in childNode.childNodes)
                            )

    # If the node/child wasn't found we return the last child node and offset to
    # its end.
    return [childNode, childOffset]

_getOffsetOfChildNode = (parentNode, childNode) ->
    # Return the offset of a child node relative to a parent node. The child
    # node does not have to be a direct descendant.

    # If a parentNode with no child nodes is passed to the function then we
    # return 0.
    if (parentNode.childNodes.length == 0)
        return 0

    # We use a stack structure to parse the tree structure of the parent node
    offset = 0
    childStack = (n for n in parentNode.childNodes)

    while childStack.length > 0
        otherChildNode = childStack.shift()

        # If this child node is a match for the specified child node return the
        # current offset.
        if otherChildNode == childNode
            if otherChildNode.nodeName.toLowerCase() in SELF_CLOSING_NODE_NAMES
                return offset + 1
            return offset

        # Process each child node based on the type of node
        switch otherChildNode.nodeType

            # Text nodes
            when Node.TEXT_NODE
                offset += otherChildNode.textContent.length

            # Elements
            when Node.ELEMENT_NODE

                # Inline block elements count as a single character
                if otherChildNode.nodeName.toLowerCase() in
                        SELF_CLOSING_NODE_NAMES
                    offset += 1

                # For elements that support children we prepend any children to
                # the stack to be processed.
                else
                    if otherChildNode.childNodes
                        Array::unshift.apply(
                            childStack,
                            (n for n in otherChildNode.childNodes)
                            )

    # If the child node wasn't found an offset pointing to the end of the parent
    # node will be sent.
    return offset

_getNodeRange = (element, docRange) ->
    # Return the start/end nodes and relative offsets for the specified document
    # range. This function accepts a document range (e.g Document.createRange),
    # not a ContentSelect.Range.
    childNodes = element.childNodes

    # Clone the document range so we can modify it without affecting the current
    # selection.
    startRange = docRange.cloneRange()
    startRange.collapse(true)

    endRange = docRange.cloneRange()
    endRange.collapse(false)

    startNode = startRange.startContainer
    startOffset = startRange.startOffset
    endNode = endRange.endContainer
    endOffset = endRange.endOffset

    # HACK: We use comparePoint for FF and Chrome when the start/end nodes are
    # reported as the ancestor element and therefore we need to manually find
    # the actual start/end nodes manually and get the correct offset from it.
    #
    # IE 9+ doesn't seem to handle this the same way, the offset still appears
    # to reported correctly in testing and therefore we don't need to use
    # comparePoint for IE - which by is really useful (and worryingly convienent
    # as IE ranges don't support the method.
    if not startRange.comparePoint
        return [startNode, startOffset, endNode, endOffset]

    # Find the starting node and offset
    if startNode == element
        startNode = childNodes[childNodes.length - 1]
        startOffset = startNode.textContent.length

        for childNode, i in childNodes

            # Check to see if the child node appears after the first character
            # in the range (this is why we collapse the start range).
            if startRange.comparePoint(childNode, 0) != 1
                continue

            # If this is the first node then the offset must be 0...
            if i == 0
                startNode = childNode
                startOffset = 0

            # ...otherwise select the previous node and set the start offset to
            # the end of the node.
            else
                startNode = childNodes[i - 1]
                startOffset = childNode.textContent.length

            # If the node is an inline block then set the length to 1
            if startNode.nodeName.toLowerCase in SELF_CLOSING_NODE_NAMES
                startOffset = 1

            break

    # Find the ending node and offset

    # If the document range is collapsed the range starts and finishes at the
    # same point so we don't need to search for the end.
    if docRange.collapsed
        return [startNode, startOffset, startNode, startOffset]

    if endNode == element
        endNode = childNodes[childNodes.length - 1]
        endOffset = endNode.textContent.length

        for childNode, i in childNodes

            # Check to see if the child node appears after the first character
            # in the range (this is why we collapse the start range).
            if endRange.comparePoint(childNode, 0) != 1
                continue

            # If this is the first node select it...
            if i == 0
                endNode = childNode

            # ...otherwise select the previous node
            else
                endNode = childNodes[i - 1]

            endOffset = childNode.textContent.length + 1

    return [startNode, startOffset, endNode, endOffset]