(function() {
  var Range, element;

  Range = ContentSelect.Range;

  element = document.createElement('p');

  element.innerHTML = 'ContentSelect <br>is <b>a CoffeeScript/JavaScript</b> library that provides cross-browser support for content selection. It is designed specifically for use with the `contenteditable` attribute and web based WYSIWYG editors.';

  document.body.appendChild(element);

  describe('ContentSelect.Range()', function() {
    it('should create a content range that can be used to select page content', function() {
      var otherRange, range;
      range = new Range(0, 20);
      range.select(element);
      otherRange = Range.query(element);
      return expect(range.eq(otherRange)).toBe(true);
    });
    return it('should accept from/to values in reverse order and order them correctly', function() {
      var otherRange, range;
      range = new Range(20, 5);
      otherRange = new Range(5, 20);
      return expect(range.eq(otherRange)).toBe(true);
    });
  });

  describe('ContentSelect.Range.isCollapsed()', function() {
    return it('should return true if a range is collapsed (start == end)', function() {
      var range;
      range = new Range(10, 10);
      expect(range.isCollapsed()).toBe(true);
      range = new Range(10, 20);
      return expect(range.isCollapsed()).toBe(false);
    });
  });

  describe('ContentSelect.Range.span()', function() {
    return it('should return a range\'s span (distance between the start and end)', function() {
      var range;
      range = new Range(10, 20);
      return expect(range.span()).toBe(10);
    });
  });

  describe('ContentSelect.Range.collapse()', function() {
    return it('should collapse a range to so the end is equal to the start', function() {
      var range;
      range = new Range(30, 60);
      expect(range.isCollapsed()).toBe(false);
      range.collapse();
      return expect(range.isCollapsed()).toBe(true);
    });
  });

  describe('ContentSelect.Range.eq()', function() {
    return it('should return true if 2 ranges are equal', function() {
      var rangeA, rangeB, rangeC;
      rangeA = new Range(30, 60);
      rangeB = new Range(30, 60);
      rangeC = new Range(45, 60);
      expect(rangeA.eq(rangeB)).toBe(true);
      return expect(rangeA.eq(rangeC)).toBe(false);
    });
  });

  describe('ContentSelect.Range.get()', function() {
    return it('should return a range as 2 item array [start, end]', function() {
      var range;
      range = new Range(30, 60);
      return expect(range.get()).toEqual([30, 60]);
    });
  });

  describe('ContentSelect.Range.select()', function() {
    return it('should select content on the page', function() {
      var otherRange, range, ranges, _i, _len, _results;
      ranges = [new Range(0, 20), new Range(10, 30), new Range(11, 12), new Range(55, 55), new Range(0, 0)];
      _results = [];
      for (_i = 0, _len = ranges.length; _i < _len; _i++) {
        range = ranges[_i];
        range.select(element);
        otherRange = Range.query(element);
        _results.push(expect(range).toEqual(otherRange));
      }
      return _results;
    });
  });

  describe('ContentSelect.Range.set()', function() {
    return it('should set the start and end of a range', function() {
      var range;
      range = new Range(0, 0);
      range.set(10, 20);
      return expect(range.get()).toEqual([10, 20]);
    });
  });

  describe('ContentSelect.Range.@query()', function() {
    return it('should return a range for the content currently selected on the page', function() {
      var otherRange, range;
      range = new Range(50, 60);
      range.select(element);
      otherRange = Range.query(element);
      return expect(range.eq(otherRange)).toBe(true);
    });
  });

  describe('ContentSelect.Range.@rect()', function() {
    return it('should return a bounding rectangle for the currently select content on the page', function() {
      var collapsedRect, range, rect;
      range = new Range(50, 60);
      range.select(element);
      rect = Range.rect();
      expect(rect.bottom > -1).toBe(true);
      expect(rect.height > -1).toBe(true);
      expect(rect.left > -1).toBe(true);
      expect(rect.right > -1).toBe(true);
      expect(rect.top > -1).toBe(true);
      expect(rect.width > -1).toBe(true);
      range = new Range(50, 50);
      range.select(element);
      collapsedRect = Range.rect();
      expect(collapsedRect.bottom > 0).toBe(true);
      expect(collapsedRect.height > 0).toBe(true);
      expect(collapsedRect.left > 0).toBe(true);
      expect(collapsedRect.right > 0).toBe(true);
      expect(collapsedRect.top > 0).toBe(true);
      return expect(collapsedRect.width).toBe(0);
    });
  });

  describe('ContentSelect.Range.@unselectAll()', function() {
    return it('should unselect all content on the page', function() {
      var range;
      Range.unselectAll();
      range = Range.query(element);
      return expect(range.get()).toEqual([0, 0]);
    });
  });

}).call(this);
