require 'crossdoc/builder'
require_relative 'test_helper'

class TestBuilder < Minitest::Test
  def setup
  end

  def test_builder
    doc = build_demo_doc

    write_doc doc, 'builder', paginate: 3
  end

  def build_demo_doc
    builder = CrossDoc::Builder.new page_size: 'us-letter', page_orientation: 'portrait', page_margin: '0.5in'

    header_color = '#006688ff'
    body_color = '#222222ff'

    # header
    builder.header do |header|
      header.horizontal_div do |left_header|
        left_header.node 'img', {src: 'https://placehold.co/100x80'} do |logo|
          logo.push_min_height 100
          logo.margin.set_all 8
        end
        left_header.div do |company_info|
          info_font = CrossDoc::Font.default size: 8, color: body_color
          company_info.div do |name_row|
            name_row.font = info_font
            name_row.padding.set_all 4
            name_row.text = 'ACME LLC'
          end
          company_info.div do |phone_row|
            phone_row.font = info_font
            phone_row.padding.set_all 4
            phone_row.text = '952-555-1234'
          end
        end
      end
      header.div do |right_header|
        right_header.node 'h1' do |n|
          n.default_font size: 32, align: :right, color: header_color
          n.text = 'Hello World'
        end
        right_header.node 'h2' do |n|
          n.default_font size: 24, align: :right, color: header_color
          n.text = 'Subheader'
        end
      end
    end

    # footer
    footer_font = CrossDoc::Font.default size: 9, color: '666666', align: 'center'
    footer_padding = CrossDoc::Margin.new.set_all 12
    builder.footer do |footer|
      footer.div padding: footer_padding do |column|
        column.node 'p', font: footer_font do |p|
          p.text = 'This is the document footer'
        end
        column.node 'p', font: footer_font do |p|
          p.text = 'Page {{page_number}} of {{num_pages}}'
        end
      end
      footer.div padding: footer_padding do |column|
        column.node 'p', font: footer_font do |p|
          p.text = 'It will sit at the bottom of every page'
        end
      end
      footer.div padding: footer_padding do |column|
        column.node 'p', font: footer_font do |p|
          p.text = 'It usually contains boring but necessary information'
        end
      end
    end

    builder.page do |page|

      page.horizontal_div do |content|
        content.margin.top = 0
        content.node 'div', {weight: 2} do |left_content|
          left_content.node 'p', {} do |p1|
            p1.border_bottom '0.2px dashed #008888'
            p1.default_font size: 12, color: body_color
            p1.padding.set_all 8
            p1.text = 'Lorem ipsum dolor sit amet, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
          end
          left_content.node 'p', {} do |p2|
            p2.border_bottom '0.2px dotted #008888'
            p2.default_font size: 12, color: body_color
            p2.padding.set_all 8
            p2.text = 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.'
          end
          left_content.node 'p', {} do |p3|
            p3.border_bottom '0.2px solid #008888'
            p3.default_font size: 12, color: body_color
            p3.padding.set_all 8
            p3.text = 'Lorem ipsum dolor sit amet, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
          end
        end
        content.node 'div', {weight: 1} do |right_content|
          right_content.div do |bordered_content|
            bordered_content.border_all '0.2px solid #aaaaaaff'
            bordered_content.padding.set_all 8
            bordered_content.margin.set_all 8
            bordered_content.default_font size: 14, color: body_color
            bordered_content.text = 'This content should have a border around it'
          end
          right_content.div do |bordered_content|
            bordered_content.border_all '0.2px solid #aaaaaaff'
            bordered_content.padding.set_all 8
            bordered_content.margin.set_all 8
            bordered_content.default_font size: 14, color: body_color
            bordered_content.text = 'Verylong textthat messeswith thewrapping'
          end
        end
      end

      th_font = CrossDoc::Font.default size: 12, color: '#ffffffff'
      td_font = CrossDoc::Font.default size: 12, color: '222222'
      cell_padding = CrossDoc::Margin.new.set_all 4
      page.node 'table', {} do |table|
        table.margin.top = 20
        table.margin.bottom = 20
        table.border_all '0.2px solid #aaaaaa'
        table.node 'tr', {block_orientation: :horizontal} do |header_row|
          header_row.background_color header_color
          header_row.node 'th', {weight: 3, font: th_font, padding: cell_padding} do |th|
            th.text = 'Description'
          end
          header_row.node 'th', {weight: 1, font: th_font, padding: cell_padding} do |th|
            th.text = 'Subtotal'
          end
          header_row.node 'th', {weight: 1, font: th_font, padding: cell_padding} do |th|
            th.text = 'Total'
          end
        end
        12.times do
          table.node 'tr', block_orientation: 'horizontal' do |tr|
            subtotal = 10.0 + rand*100.0
            tr.node 'td', weight: 3, font: td_font, padding: cell_padding do |td|
              td.text = "$#{'%.2f' % subtotal}"
            end
            tr.node 'td', weight: 1, font: td_font, padding: cell_padding do |td|
              td.text = "$#{'%.2f' % (subtotal*0.07)}"
            end
            tr.node 'td', weight: 1, font: td_font, padding: cell_padding do |td|
              td.text = "$#{'%.2f' % (subtotal*1.07)}"
            end
          end
        end
      end

      page.node 'p', {} do |p|
        p.default_font size: 12, color: body_color
        p.padding.set_all 8
        p.text = 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.'
      end
    end

    builder.to_doc
  end

  def test_floating_elements
    builder = CrossDoc::Builder.new page_size: 'us-letter', page_orientation: 'portrait', page_margin: '0.5in'

    builder.header do |header|
      header.horizontal_div do |header_content|
        header_content.node 'img', {src: 'https://placehold.co/100x80'} do |logo|
          logo.push_min_height 100
          logo.margin.set_all 8
        end
        header_content.div do |heading|
          heading.weight = 3
          heading.node 'h1' do |h1|
            h1.default_font size: 24, color: '#000000'
            h1.padding.set_all 4
            h1.text = "Header"
          end
        end
      end

      header.floating_div(CrossDoc::Box.new(x: 10, y: 10, width: 400)) do |float|
        float.border_all '1px dashed #0000FF'
        float.background_color '#CCCCCC'
        float.default_font size: 10, color: '#0000FF'
        float.padding.set_all 4
        float.text = 'This is a floating div in the header. It is positioned at 10, 10.'
      end
    end

    builder.page do |page|
      page.div do |content|
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vel tortor vitae nibh bibendum convallis. Phasellus mauris tellus, dapibus hendrerit turpis in, luctus imperdiet felis. Nunc hendrerit quis urna quis pharetra. Sed porttitor, nisi vitae ultrices lacinia, augue nulla efficitur nisi, nec mattis lorem nunc a turpis. Nulla vestibulum cursus tortor, ut porta purus molestie a. Integer convallis justo at mi lacinia, vitae euismod nibh condimentum. Pellentesque ut libero orci. Pellentesque at lacus a nulla auctor venenatis. Sed metus massa, tincidunt at ornare nec, tincidunt sed justo."
        end
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Nam vel consectetur dolor. Vestibulum orci turpis, pellentesque eget lectus ut, aliquam accumsan mi. Duis a arcu nisl. Sed blandit iaculis tellus, eu fringilla magna suscipit at. Interdum et malesuada fames ac ante ipsum primis in faucibus. Ut ac sem vitae lectus bibendum cursus in aliquam urna. Sed sit amet ipsum a ipsum euismod aliquet. Nulla congue blandit magna at gravida. Maecenas mi leo, bibendum et congue eu, consectetur ut metus. Duis semper velit eu accumsan varius. Etiam semper eros a magna convallis, sit amet gravida nisi venenatis. Aenean varius massa id turpis egestas commodo. Mauris et fermentum orci, commodo dapibus ligula."
        end
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Etiam ante dolor, cursus vel nisl eu, rhoncus fermentum purus. Duis eget nisi sed sapien commodo ultrices. Maecenas tincidunt, dui vel rutrum tincidunt, sapien ex mattis tellus, nec ultricies justo turpis id elit. Nulla convallis, erat dictum molestie efficitur, nulla dui cursus ipsum, sed feugiat neque tortor a purus. Mauris vitae sagittis dui, eget convallis orci. Donec sodales cursus augue, venenatis auctor enim suscipit eu. Proin nisl elit, fringilla sed viverra ornare, hendrerit at arcu. Proin eu pretium tellus. Nunc pellentesque eget nulla et sodales. Morbi tincidunt ullamcorper lectus, nec eleifend felis interdum quis. Duis consequat laoreet ante, nec ornare urna dictum vel. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Etiam vel posuere dolor, ut egestas nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In mattis velit quis orci pretium gravida. Morbi iaculis purus ut lacinia auctor."
        end
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Quisque dignissim a dui a feugiat. Quisque convallis porta interdum. Mauris euismod eu lacus sit amet sodales. Vivamus at lectus vulputate, sollicitudin purus efficitur, tempus orci. Donec eget bibendum libero. Etiam dictum finibus nisi sit amet vestibulum. Curabitur nec enim magna. Vestibulum ornare, arcu ut vestibulum dignissim, nisi neque scelerisque ligula, sit amet mollis tortor dui nec tortor. In hac habitasse platea dictumst. Phasellus lobortis nisl augue. Donec placerat aliquet ornare. Nulla eget odio in nulla tempus bibendum eget non lorem. Nam elit dolor, finibus non dui sit amet, aliquet luctus purus. Pellentesque dapibus enim sem, vitae pretium massa semper vel."
        end
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Nam vel consectetur dolor. Vestibulum orci turpis, pellentesque eget lectus ut, aliquam accumsan mi. Duis a arcu nisl. Sed blandit iaculis tellus, eu fringilla magna suscipit at. Interdum et malesuada fames ac ante ipsum primis in faucibus. Ut ac sem vitae lectus bibendum cursus in aliquam urna. Sed sit amet ipsum a ipsum euismod aliquet. Nulla congue blandit magna at gravida. Maecenas mi leo, bibendum et congue eu, consectetur ut metus. Duis semper velit eu accumsan varius. Etiam semper eros a magna convallis, sit amet gravida nisi venenatis. Aenean varius massa id turpis egestas commodo. Mauris et fermentum orci, commodo dapibus ligula."
        end
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Etiam ante dolor, cursus vel nisl eu, rhoncus fermentum purus. Duis eget nisi sed sapien commodo ultrices. Maecenas tincidunt, dui vel rutrum tincidunt, sapien ex mattis tellus, nec ultricies justo turpis id elit. Nulla convallis, erat dictum molestie efficitur, nulla dui cursus ipsum, sed feugiat neque tortor a purus. Mauris vitae sagittis dui, eget convallis orci. Donec sodales cursus augue, venenatis auctor enim suscipit eu. Proin nisl elit, fringilla sed viverra ornare, hendrerit at arcu. Proin eu pretium tellus. Nunc pellentesque eget nulla et sodales. Morbi tincidunt ullamcorper lectus, nec eleifend felis interdum quis. Duis consequat laoreet ante, nec ornare urna dictum vel. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Etiam vel posuere dolor, ut egestas nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In mattis velit quis orci pretium gravida. Morbi iaculis purus ut lacinia auctor."
        end
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Quisque dignissim a dui a feugiat. Quisque convallis porta interdum. Mauris euismod eu lacus sit amet sodales. Vivamus at lectus vulputate, sollicitudin purus efficitur, tempus orci. Donec eget bibendum libero. Etiam dictum finibus nisi sit amet vestibulum. Curabitur nec enim magna. Vestibulum ornare, arcu ut vestibulum dignissim, nisi neque scelerisque ligula, sit amet mollis tortor dui nec tortor. In hac habitasse platea dictumst. Phasellus lobortis nisl augue. Donec placerat aliquet ornare. Nulla eget odio in nulla tempus bibendum eget non lorem. Nam elit dolor, finibus non dui sit amet, aliquet luctus purus. Pellentesque dapibus enim sem, vitae pretium massa semper vel."
        end
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Sed id rutrum justo. Donec leo odio, efficitur nec nulla vel, ullamcorper efficitur nibh. Morbi in vulputate libero, sed egestas odio. Donec pharetra blandit nisi, at rutrum ex vestibulum id. Morbi magna sapien, volutpat non facilisis ac, ultricies ac mauris. Aliquam tincidunt rutrum imperdiet. Etiam ultricies, massa at lacinia laoreet, eros ipsum malesuada erat, sed aliquet justo neque id arcu. Sed eget dignissim purus, ut pretium augue. Etiam sed placerat libero, in tristique tellus. Suspendisse eleifend risus orci. Etiam odio odio, facilisis eu metus eu, tempus feugiat eros. Pellentesque vehicula et sem nec placerat. Suspendisse sapien nisl, pellentesque et ex quis, aliquam luctus mi. Suspendisse ut luctus metus, in cursus magna. In a sem a augue imperdiet tempor sed id tellus."

          p.floating_div(CrossDoc::Box.new(x: 250, y: 20)) do |float|
            float.border_all '1px dashed #0000FF'
            float.background_color '#CCCCCC'
            float.default_font size: 10, color: '#0000FF'
            float.padding.set_all 4
            float.text = 'This is a floating div in the second to last paragraph of the content. It is positioned at 250, 20.'
          end
        end
        content.node 'p' do |p|
          p.default_font size: 12, color: '#000000'
          p.padding.set_all 4
          p.text = "Aliquam erat volutpat. Sed ac metus id nulla suscipit luctus vel sit amet leo. Curabitur id volutpat libero. Cras cursus faucibus nibh maximus convallis. Curabitur congue molestie massa imperdiet ultricies. Phasellus a facilisis neque. Donec efficitur, odio id mollis consequat, lacus lacus mattis quam, quis sagittis ex lacus a odio. Nam finibus lacinia convallis."
        end
      end

      page.floating_div(CrossDoc::Box.new(x: 0, y: 0)) do |float|
        float.border_all '1px dashed #0000FF'
        float.background_color '#CCCCCC'
        float.default_font size: 10, color: '#0000FF'
        float.padding.set_all 4
        float.margin.set_all 5
        float.text = 'This is a floating div on the page. It is positioned at 0, 0, with 5 px margins.'
      end
    end

    doc = builder.to_doc

    write_doc(doc, 'floating', paginate: 3)
  end


  def test_markdown_builder
    doc = build_markdown_doc

    write_doc doc, 'markdown'
  end

  def build_markdown_doc
    builder = CrossDoc::Builder.new page_size: 'us-letter', page_orientation: 'portrait', page_margin: '0.5in'

    builder.page do |page|
      markdown = File.open('test/input/markdown.md') do |file|
        file.read
      end
      page.markdown markdown, {
          H1: {
              font: {color: '#224488', size: 30}
          },
          P: {
              font: {line_height: 30}
          }
      }
    end

    builder.to_doc
  end

end
