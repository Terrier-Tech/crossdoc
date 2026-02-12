require 'minitest/autorun'
require 'crossdoc/paginator'
require 'crossdoc/pdf_render'

module TestHelper

  # Renders the given crossdoc doc as a pdf with the given name in test/output
  # @param doc [CrossDoc::Document]
  # @param name [String]
  # @param paginate [Numeric, nil] if provided, paginates the doc with the given depth
  # @param show_overlays [Boolean] if true, show element outline overlays in the resulting PDF
  def write_doc(doc, name, paginate: nil, show_overlays: false)
    if paginate
      CrossDoc::Paginator.new(num_levels: paginate).run doc
    end

    t = Time.now
    renderer = CrossDoc::PdfRenderer.new doc

    renderer.register_font_family 'HeaderFont', {
        normal: "#{Dir.pwd}/demo/fonts/Quicksand-Regular.ttf",
        bold: "#{Dir.pwd}/demo/fonts/Quicksand-Bold.ttf",
        italic: "#{Dir.pwd}/demo/fonts/Quicksand-Regular.ttf",
        bold_italic: "#{Dir.pwd}/demo/fonts/Quicksand-Bold.ttf",
        leading_factor: 0
    }

    renderer.register_font_family 'BodyFont', {
        normal: "#{Dir.pwd}/demo/fonts/Quicksand-Regular.ttf",
        bold: "#{Dir.pwd}/demo/fonts/Quicksand-Bold.ttf",
        italic: "#{Dir.pwd}/demo/fonts/Quicksand-Regular.ttf",
        bold_italic: "#{Dir.pwd}/demo/fonts/Quicksand-Bold.ttf",
        leading_factor: 0.4
    }

    if show_overlays
      renderer.show_overlays = true
    end

    File.open("test/output/#{name}.json", 'wt') do |f|
      f.write JSON.pretty_generate(doc.to_raw)
    end

    # renderer.add_horizontal_guide 3.5.inches
    # renderer.add_box_guide CrossDoc::Box.new(x: 0.875.inches, y: 2.5.inches, width: 3.inches, height: 1.125.inches)
    renderer.to_pdf "test/output/#{name}.pdf"
    dt = Time.now - t
    puts "Rendered #{name} PDF in #{dt} seconds"
  end

end

class Minitest::Test
  include TestHelper
end
