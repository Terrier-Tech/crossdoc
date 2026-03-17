require 'crossdoc/tree'
require 'crossdoc/paginator'
require 'minitest/autorun'

class TestPaginator < Minitest::Test
  def setup
    @paginator = CrossDoc::Paginator.new(max_pages: 10)
    @builder = CrossDoc::Builder.new(page_margin: '1.0in')
  end

  def test_overflow
    @builder.page do |page|
      page.div do |content|
        content.node 'p' do |paragraph|
          # This paragraph should be so large that it overflows onto the next page.
          # Since the paragraph is unsplittable, it shoould be entirely moved onto the next page.
          paragraph.default_font size: 72, color: '#000000'
          paragraph.padding.set_all 4
          paragraph.text = <<-EOF.squish
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel tortor
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
      end
    end
    doc = @builder.to_doc.tap(&@paginator.method(:run))

    # Paginator should split the image onto only one new page.
    assert_equal(2, doc.pages.length)
  end
end
