# Localise the `ContentSelect.Range` class to `Range` for the sake of brevity
Range = ContentSelect.Range

# Create an element to test the selection against
element = document.createElement('p')
element.innerHTML = 'ContentSelect <br>is <b>a CoffeeScript/JavaScript</b> library that provides cross-browser support for content selection. It is designed specifically for use with the `contenteditable` attribute and web based WYSIWYG editors.'
document.body.appendChild(element)

describe 'ContentSelect.Range()', () ->

    it 'should create a content range that can be used to select page \
        content', () ->

        # Create the range and select the page content
        range = new Range(0, 20)
        range.select(element)

        # Query the current selection and check the result matches the selection
        # we made.
        otherRange = Range.query(element)
        expect(range.eq(otherRange)).toBe true

    it 'should accept from/to values in reverse order and order them correctly', () ->
        range = new Range(20, 5)
        otherRange = new Range(5, 20)
        expect(range.eq(otherRange)).toBe true


describe 'ContentSelect.Range.isCollapsed()', () ->

    it 'should return true if a range is collapsed (start == end)', () ->

        range = new Range(10, 10)
        expect(range.isCollapsed()).toBe true

        range = new Range(10, 20)
        expect(range.isCollapsed()).toBe false


describe 'ContentSelect.Range.span()', () ->

    it 'should return a range\'s span (distance between the start and \
        end)', () ->

        range = new Range(10, 20)
        expect(range.span()).toBe 10


describe 'ContentSelect.Range.collapse()', () ->

    it 'should collapse a range to so the end is equal to the start', () ->

        # Test that the range is not collapsed initially
        range = new Range(30, 60)
        expect(range.isCollapsed()).toBe false

        # Collapse the range and test that it is collapsed
        range.collapse()
        expect(range.isCollapsed()).toBe true


describe 'ContentSelect.Range.eq()', () ->

    it 'should return true if 2 ranges are equal', () ->
        rangeA = new Range(30, 60)
        rangeB = new Range(30, 60)
        rangeC = new Range(45, 60)

        expect(rangeA.eq(rangeB)).toBe true
        expect(rangeA.eq(rangeC)).toBe false


describe 'ContentSelect.Range.get()', () ->

    it 'should return a range as 2 item array [start, end]', () ->
        range = new Range(30, 60)
        expect(range.get()).toEqual [30, 60]


describe 'ContentSelect.Range.select()', () ->

    it 'should select content on the page', () ->

        # Create a list of
        ranges = [
            new Range(0, 20),
            new Range(10, 30),
            new Range(11, 12),
            new Range(55, 55),
            new Range(0, 0)
            ]

        for range in ranges

            # Select the range
            range.select(element)

            # Query the current selection and check the result matches the
            # selection we made.
            otherRange = Range.query(element)
            expect(range).toEqual otherRange


describe 'ContentSelect.Range.set()', () ->

    it 'should set the start and end of a range', () ->
        range = new Range(0, 0)
        range.set(10, 20)
        expect(range.get()).toEqual [10, 20]


describe 'ContentSelect.Range.@query()', () ->

    it 'should return a range for the content currently selected on the \
        page', () ->

        # Select some content
        range = new Range(50, 60)
        range.select(element)

        # Query the selection and check the results match
        otherRange = Range.query(element)
        expect(range.eq(otherRange)).toBe true


describe 'ContentSelect.Range.@rect()', () ->

    it 'should return a bounding rectangle for the currently select content on \
        the page', () ->

        # Select some content
        range = new Range(50, 60)
        range.select(element)

        # Query the selection and check the results match
        rect = Range.rect()
        expect(rect.bottom > -1).toBe true
        expect(rect.height > -1).toBe true
        expect(rect.left > -1).toBe true
        expect(rect.right > -1).toBe true
        expect(rect.top > -1).toBe true
        expect(rect.width > -1).toBe true

        # Position the cursor without selecting any content
        range = new Range(50, 50)
        range.select(element)

        # Query the selection and check the results match
        collapsedRect = Range.rect()
        expect(collapsedRect.bottom > 0).toBe true
        expect(collapsedRect.height > 0).toBe true
        expect(collapsedRect.left > 0).toBe true
        expect(collapsedRect.right > 0).toBe true
        expect(collapsedRect.top > 0).toBe true
        expect(collapsedRect.width).toBe 0


describe 'ContentSelect.Range.@unselectAll()', () ->

    it 'should unselect all content on the page', () ->
        Range.unselectAll()
        range = Range.query(element)
        expect(range.get()).toEqual [0, 0]