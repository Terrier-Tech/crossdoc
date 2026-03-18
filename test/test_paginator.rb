require 'crossdoc/builder'
require_relative 'test_helper'

class TestPaginator < Minitest::Test
  def setup
    @builder = CrossDoc::Builder.new(page_margin: '1.0in')
  end

  def test_overflow
    @builder.page do |page|
      page.div do |content|
        content.node 'p' do |paragraph|
          paragraph.default_font size: 12, color: '#000000'
          paragraph.padding.set_all 4
          paragraph.text = 'Paragraph 1'
        end
        content.node 'p' do |paragraph|
          paragraph.default_font size: 12, color: '#000000'
          paragraph.padding.set_all 4
          paragraph.text = 'Paragraph 2'
        end
        content.node 'p' do |paragraph|
          # This paragraph should be so large that it overflows onto the next page.
          # Since the paragraph is unsplittable, it should be entirely moved onto the next page.
          paragraph.default_font size: 72, color: '#000000'
          paragraph.padding.set_all 4
          paragraph.text = <<-EOF.squish
          Paragraph 3 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel tortor
          vitae nibh bibendum convallis. Phasellus mauris tellus, dapibus hendrerit
          turpis in, luctus imperdiet felis. Nunc hendrerit quis urna quis
          pharetra. Sed porttitor, nisi vitae ultrices lacinia, augue nulla
          efficitur nisi, nec mattis lorem nunc a turpis. Nulla vestibulum cursus
          tortor, ut porta purus molestie a. Integer convallis justo at mi lacinia,
          vitae euismod nibh condimentum. Pellentesque ut libero orci. Pellentesque
          at lacus a nulla auctor venenatis. Sed metus massa, tincidunt at ornare
          nec, tincidunt sed justo.
          EOF
        end
        content.node 'p' do |paragraph|
          paragraph.default_font size: 12, color: '#000000'
          paragraph.padding.set_all 4
          paragraph.text = 'Paragraph 4'
        end
      end
    end

    doc = @builder.to_doc
    write_doc doc, 'pagination', paginate: 3

    # Paginator should split the document into 3 pages:
    # 1. paragraphs 1 & 2
    # 2. paragraph 3
    # 3. paragraph 4
    assert_equal(3, doc.pages.length)
  end
end
