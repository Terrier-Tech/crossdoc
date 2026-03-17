# takes a document and spreads it into multiple pages
class CrossDoc::Paginator

  def initialize(num_levels: 3, max_pages: 10, overlap_threshold: 0.01)
    @num_levels = num_levels
    @max_pages = max_pages

    @overlap_threshold = overlap_threshold # if children overlap by more than this much, they are considered overlapping
  end

  # Given a spanning node, find the child node that spans the remaining height on the page.
  # If no child spans the remaining height, no node is returned and the given parent is the minimum spanning node.
  def find_spanning_node(parent, remaining_height)
    return nil if parent.children.empty?

    # if the parent's children are laid out horizontally (i.e., their height overlaps), we want the parent node and its
    # children to break together. therefore, the parent doesn't have a spanning child if any of its children have
    # vertical overlap.
    return nil if parent.children.any? do |child_1|
      next false if child_1.box.nil?
      parent.children.any? do |child_2|
        next nil if child_2.box.nil? || child_1 == child_2

        # find the amount of overlap (in pixels) between the two children
        box_1 = child_1.box
        box_2 = child_2.box

        min = [box_1.y, box_2.y].max
        max = [box_1.bottom, box_2.bottom].min

        # if the amount of overlap exeeds the threshold, the parent should be the minimum spanning node
        (max - min) >= @overlap_threshold
      end
    end

    parent.children&.find do |node|
      next false unless node.box.present?

      # If the bottom of this child extends below the remaining height, it spans the page break
      node.box.bottom > remaining_height
    end
  end

  def break_page(page, stack, content_height)
    new_page = page.shallow_copy
    new_page.children = []

    # keep floating children on their original page number
    new_page.floating_children = page.floating_children
    page.floating_children = []

    # from bottom to top in the stack, move siblings after the spanning sibling to the next page
    before_parent = new_page
    after_parent = page
    stack.each do |after_node|
      end_of_stack = after_node == stack.last
      i = after_parent.children.index after_node

      # add all nodes before the split to the before_parent
      if i > 0
        before_parent.children = after_parent.children[0..i-1]
      end

      # remove nodes before the split from the after_parent
      after_parent.children = after_parent.children[i..-1]

      if end_of_stack
        # we're at the top of the stack, so the current node will be fully on the next page
        last_before_node = before_parent.children.last

        # if the current node is taller than the page, limit its height so it doesn't overflow the next page as well.
        after_node.box.height = content_height if content_height <= after_node.box.height
      else
        # if we're not at the end of the stack, split this node between the previous and current page. on the next level
        # of the stack, siblings before the spanning child will be moved _back_ to this copy.
        last_before_node = after_node.shallow_copy
        last_before_node.children = []
        last_before_node.box = last_before_node.box.dup
        before_parent.children << last_before_node
      end

      # adjust the before_parent height to match the reduced number of children
      unless before_parent == new_page
        before_parent.box.height = last_before_node&.box&.bottom || 0
      end

      # ordered list was broken up, so change the start of after_parent
      if after_parent.is_a?(CrossDoc::Node) && after_parent.tag&.downcase == 'ol' && before_parent.tag&.downcase == 'ol'
        after_parent.start = before_parent.children.count + before_parent.start - 1 # -1 for seemingly phantom list item
      end

      after_parent = after_node
      before_parent = last_before_node
    end # after_node

    # from top to bottom in the stack, adjust the vertical position of nodes that are on the current page to account for
    # the height of nodes moved to the previous page.
    full_stack = [page] + stack
    height_diff = 0
    1.upto(stack.size).each do |i|
      child = full_stack[-i]
      parent = full_stack[-i-1]
      dy = child.box.y
      # if parent == page
      #   dy -= parent.padding.top
      # end
      parent.children.each do |c|
        next if c.box.nil?
        c.box.y -= dy
        if c != child
          c.box.y -=  height_diff
        end
        c.box.y = [c.box.y, 0].max
      end
      unless parent == page
        last_block_child = parent.children.reverse.find { |c| c.box.present? }
        new_height = last_block_child&.box&.bottom || 0
        height_diff = parent.box.height - new_height
        parent.box.height = new_height
      end
    end

    new_page
  end

  def run(doc)
    unless doc.pages.length == 1
      raise "Attempting to paginate a document with #{doc.pages.length} pages, it only works with one page for now"
    end
    unless doc.page_height and doc.page_height > 0
      raise 'In order to be paginated, documents need to have a non-zero page_height'
    end

    full_page = doc.pages.first
    unless full_page.children && full_page.children.length > 0 && full_page.children.first.box.height > 0
      return # empty document
    end

    content_height = doc.page_height - doc.page_margin.top - doc.page_margin.bottom
    if doc.header
      content_height -= doc.header.box.height
    end
    if doc.footer
      content_height -= doc.footer.box.height
    end
    pages = []

    page_num = 0
    while full_page && page_num < @max_pages
      page_num += 1
      y = 0
      stack = []
      0.upto @num_levels do |level|
        current_parent = stack.length > 0 ? stack.last : full_page

        span_node = find_spanning_node(current_parent, content_height - y)

        if span_node
          stack << span_node
          if level == @num_levels
            pages << break_page(full_page, stack, content_height)
            break
          else
            y += span_node.box.y
          end
        else # no span node
          if stack.length > 0
            pages << break_page(full_page, stack, content_height)
          else
            pages << full_page
            full_page = nil
          end
          break
        end
      end
    end

    doc.pages = pages

  end

end
