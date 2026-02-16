require 'crossdoc/tree'
require_relative 'test_helper'

class TestRender < Minitest::Test
  def setup
  end

  def test_render_doc
    doc = CrossDoc::Document.from_file "test/input/doc.json"
    write_doc doc, 'doc'
  end

  def test_render_report
    doc = CrossDoc::Document.from_file "test/input/report.json"
    write_doc doc, 'report', paginate: 6
  end

end
