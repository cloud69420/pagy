# encoding: utf-8
# frozen_string_literal: true

require_relative '../../test_helper'
require 'pagy/extras/navs'
require 'pagy/extras/bootstrap'
require 'pagy/extras/bulma'
require 'pagy/extras/foundation'
require 'pagy/extras/materialize'
require 'pagy/extras/semantic'
require 'pagy/extras/trim'

SimpleCov.command_name 'trim' if ENV['RUN_SIMPLECOV'] == 'true'

describe Pagy::Frontend do

  let(:view) { MockView.new }
  let(:pagy_test_id) { 'test-id' }

  describe "#pagy_link_proc" do

    it 'returns trimmed link' do
      [ [1,  '?page=1',               ''],                    # only param
        [1,  '?page=1&b=2',           '?b=2'],                # first param
        [1,  '?a=1&page=1&b=2',       '?a=1&b=2'],            # middle param
        [1,  '?a=1&page=1',           '?a=1'],                # last param

        [1,  '?my_page=1&page=1',     '?my_page=1'],          # skip similar first param
        [1,  '?a=1&my_page=1&page=1', '?a=1&my_page=1'],      # skip similar middle param
        [1,  '?a=1&page=1&my_page=1', '?a=1&my_page=1'],      # skip similar last param

        [11, '?page=11',              '?page=11'],            # don't trim only param
        [11, '?page=11&b=2',          '?page=11&b=2'],        # don't trim first param
        [11, '?a=1&page=11&b=2',      '?a=1&page=11&b=2'],    # don't trim middle param
        [11, '?a=1&page=11',          '?a=1&page=11']         # don't trim last param
      ].each do |args|
        page, generated, trimmed = args
        view = MockView.new("http://example.com:3000/foo#{generated}")
        pagy = Pagy.new(count: 1000, page: page)
        link = view.pagy_link_proc(pagy)
        _(link.call(page)).must_equal("<a href=\"/foo#{trimmed}\"   >#{page}</a>")
      end
    end

  end

  describe "#pagy_nav" do

    it 'renders first page' do
      pagy = Pagy.new(count: 103, page: 1)
      html = view.pagy_nav(pagy)
      _(html).must_equal "<nav class=\"pagy-nav pagination\" role=\"navigation\" aria-label=\"pager\"><span class=\"page prev disabled\">&lsaquo;&nbsp;Prev</span> <span class=\"page active\">1</span> <span class=\"page\"><a href=\"/foo?page=2\"   rel=\"next\" >2</a></span> <span class=\"page\"><a href=\"/foo?page=3\"   >3</a></span> <span class=\"page\"><a href=\"/foo?page=4\"   >4</a></span> <span class=\"page\"><a href=\"/foo?page=5\"   >5</a></span> <span class=\"page\"><a href=\"/foo?page=6\"   >6</a></span> <span class=\"page next\"><a href=\"/foo?page=2\"   rel=\"next\" aria-label=\"next\">Next&nbsp;&rsaquo;</a></span></nav>"
    end

    it 'renders intermediate page' do
      pagy = Pagy.new(count: 103, page: 3)
      html = view.pagy_nav(pagy)
      _(html).must_equal "<nav class=\"pagy-nav pagination\" role=\"navigation\" aria-label=\"pager\"><span class=\"page prev\"><a href=\"/foo?page=2\"   rel=\"prev\" aria-label=\"previous\">&lsaquo;&nbsp;Prev</a></span> <span class=\"page\"><a href=\"/foo\"   >1</a></span> <span class=\"page\"><a href=\"/foo?page=2\"   rel=\"prev\" >2</a></span> <span class=\"page active\">3</span> <span class=\"page\"><a href=\"/foo?page=4\"   rel=\"next\" >4</a></span> <span class=\"page\"><a href=\"/foo?page=5\"   >5</a></span> <span class=\"page\"><a href=\"/foo?page=6\"   >6</a></span> <span class=\"page next\"><a href=\"/foo?page=4\"   rel=\"next\" aria-label=\"next\">Next&nbsp;&rsaquo;</a></span></nav>"
    end

    it 'renders last page' do
      pagy = Pagy.new(count: 103, page: 6)
      html = view.pagy_nav(pagy)
      _(html).must_equal "<nav class=\"pagy-nav pagination\" role=\"navigation\" aria-label=\"pager\"><span class=\"page prev\"><a href=\"/foo?page=5\"   rel=\"prev\" aria-label=\"previous\">&lsaquo;&nbsp;Prev</a></span> <span class=\"page\"><a href=\"/foo\"   >1</a></span> <span class=\"page\"><a href=\"/foo?page=2\"   >2</a></span> <span class=\"page\"><a href=\"/foo?page=3\"   >3</a></span> <span class=\"page\"><a href=\"/foo?page=4\"   >4</a></span> <span class=\"page\"><a href=\"/foo?page=5\"   rel=\"prev\" >5</a></span> <span class=\"page active\">6</span> <span class=\"page next disabled\">Next&nbsp;&rsaquo;</span></nav>"
    end

  end

  describe "#pagy_nav_js" do

    it 'renders first page' do
      pagy = Pagy.new(count: 103, page: 1)
      _(view.pagy_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-nav-js pagination\" role=\"navigation\" aria-label=\"pager\"></nav><script type=\"application/json\" class=\"pagy-json\">[\"nav\",\"test-id\",{\"before\":\"<span class=\\\"page prev disabled\\\">&lsaquo;&nbsp;Prev</span> \",\"link\":\"<span class=\\\"page\\\"><a href=\\\"/foo?page=__pagy_page__\\\"   >__pagy_page__</a></span> \",\"active\":\"<span class=\\\"page active\\\">1</span> \",\"gap\":\"<span class=\\\"page gap\\\">&hellip;</span> \",\"after\":\"<span class=\\\"page next\\\"><a href=\\\"/foo?page=2\\\"   rel=\\\"next\\\" aria-label=\\\"next\\\">Next&nbsp;&rsaquo;</a></span>\"},{\"0\":[\"1\",2,3,4,5,6]},\"page\"]</script>"
      _(view.pagy_bootstrap_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-bootstrap-nav-js\" role=\"navigation\" aria-label=\"pager\"></nav><script type=\"application/json\" class=\"pagy-json\">[\"nav\",\"test-id\",{\"before\":\"<ul class=\\\"pagination\\\"><li class=\\\"page-item prev disabled\\\"><a href=\\\"#\\\" class=\\\"page-link\\\">&lsaquo;&nbsp;Prev</a></li>\",\"link\":\"<li class=\\\"page-item\\\"><a href=\\\"/foo?page=__pagy_page__\\\"  class=\\\"page-link\\\" >__pagy_page__</a></li>\",\"active\":\"<li class=\\\"page-item active\\\"><a href=\\\"/foo?page=__pagy_page__\\\"  class=\\\"page-link\\\" >__pagy_page__</a></li>\",\"gap\":\"<li class=\\\"page-item gap disabled\\\"><a href=\\\"#\\\" class=\\\"page-link\\\">&hellip;</a></li>\",\"after\":\"<li class=\\\"page-item next\\\"><a href=\\\"/foo?page=2\\\"  class=\\\"page-link\\\" rel=\\\"next\\\" aria-label=\\\"next\\\">Next&nbsp;&rsaquo;</a></li></ul>\"},{\"0\":[\"1\",2,3,4,5,6]},\"page\"]</script>"
      _(view.pagy_bulma_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-bulma-nav-js pagination is-centered\" role=\"navigation\" aria-label=\"pagination\"></nav><script type=\"application/json\" class=\"pagy-json\">[\"nav\",\"test-id\",{\"before\":\"<a class=\\\"pagination-previous\\\" disabled>&lsaquo;&nbsp;Prev</a><a href=\\\"/foo?page=2\\\"   rel=\\\"next\\\" class=\\\"pagination-next\\\" aria-label=\\\"next page\\\">Next&nbsp;&rsaquo;</a><ul class=\\\"pagination-list\\\">\",\"link\":\"<li><a href=\\\"/foo?page=__pagy_page__\\\"   class=\\\"pagination-link\\\" aria-label=\\\"goto page __pagy_page__\\\">__pagy_page__</a></li>\",\"active\":\"<li><a href=\\\"/foo?page=__pagy_page__\\\"   class=\\\"pagination-link is-current\\\" aria-current=\\\"page\\\" aria-label=\\\"page __pagy_page__\\\">__pagy_page__</a></li>\",\"gap\":\"<li><span class=\\\"pagination-ellipsis\\\">&hellip;</span></li>\",\"after\":\"</ul>\"},{\"0\":[\"1\",2,3,4,5,6]},\"page\"]</script>"
      _(view.pagy_foundation_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-foundation-nav-js\" role=\"navigation\" aria-label=\"Pagination\"></nav><script type=\"application/json\" class=\"pagy-json\">[\"nav\",\"test-id\",{\"before\":\"<ul class=\\\"pagination\\\"><li class=\\\"prev disabled\\\">&lsaquo;&nbsp;Prev</li>\",\"link\":\"<li><a href=\\\"/foo?page=__pagy_page__\\\"   >__pagy_page__</a></li>\",\"active\":\"<li class=\\\"current\\\">1</li>\",\"gap\":\"<li class=\\\"ellipsis gap\\\" aria-hidden=\\\"true\\\"></li>\",\"after\":\"<li class=\\\"next\\\"><a href=\\\"/foo?page=2\\\"   rel=\\\"next\\\" aria-label=\\\"next\\\">Next&nbsp;&rsaquo;</a></li></ul>\"},{\"0\":[\"1\",2,3,4,5,6]},\"page\"]</script>"
      _(view.pagy_materialize_nav_js(pagy, pagy_test_id)).must_equal "<div id=\"test-id\" class=\"pagy-materialize-nav-js\" role=\"navigation\" aria-label=\"pager\"></div><script type=\"application/json\" class=\"pagy-json\">[\"nav\",\"test-id\",{\"before\":\"<ul class=\\\"pagination\\\"><li class=\\\"prev disabled\\\"><a href=\\\"#\\\"><i class=\\\"material-icons\\\">chevron_left</i></a></li>\",\"link\":\"<li class=\\\"waves-effect\\\"><a href=\\\"/foo?page=__pagy_page__\\\"   >__pagy_page__</a></li>\",\"active\":\"<li class=\\\"active\\\"><a href=\\\"/foo?page=__pagy_page__\\\"   >__pagy_page__</a></li>\",\"gap\":\"<li class=\\\"gap disabled\\\"><a href=\\\"#\\\">&hellip;</a></li>\",\"after\":\"<li class=\\\"waves-effect next\\\"><a href=\\\"/foo?page=2\\\"   rel=\\\"next\\\" aria-label=\\\"next\\\"><i class=\\\"material-icons\\\">chevron_right</i></a></li></ul>\"},{\"0\":[\"1\",2,3,4,5,6]},\"page\"]</script>"
      _(view.pagy_semantic_nav_js(pagy, pagy_test_id)).must_equal "<div id=\"test-id\" class=\"pagy-semantic-nav-js ui pagination menu\" role=\"navigation\" aria-label=\"pager\"></div><script type=\"application/json\" class=\"pagy-json\">[\"nav\",\"test-id\",{\"before\":\"<div class=\\\"item disabled\\\"><i class=\\\"left small chevron icon\\\"></i></div>\",\"link\":\"<a href=\\\"/foo?page=__pagy_page__\\\"  class=\\\"item\\\" >__pagy_page__</a>\",\"active\":\"<a class=\\\"item active\\\">1</a>\",\"gap\":\"<div class=\\\"disabled item\\\">&hellip;</div>\",\"after\":\"<a href=\\\"/foo?page=2\\\"  class=\\\"item\\\" rel=\\\"next\\\" aria-label=\\\"next\\\"><i class=\\\"right small chevron icon\\\"></i></a>\"},{\"0\":[\"1\",2,3,4,5,6]},\"page\"]</script>"
    end

    it 'renders intermediate page' do
      pagy = Pagy.new(count: 103, page: 3)
      _(view.pagy_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-nav-js pagination\" role=\"navigation\" aria-label=\"pager\"></nav><script type=\"application/json\" class=\"pagy-json\">[\"nav\",\"test-id\",{\"before\":\"<span class=\\\"page prev\\\"><a href=\\\"/foo?page=2\\\"   rel=\\\"prev\\\" aria-label=\\\"previous\\\">&lsaquo;&nbsp;Prev</a></span> \",\"link\":\"<span class=\\\"page\\\"><a href=\\\"/foo?page=__pagy_page__\\\"   >__pagy_page__</a></span> \",\"active\":\"<span class=\\\"page active\\\">3</span> \",\"gap\":\"<span class=\\\"page gap\\\">&hellip;</span> \",\"after\":\"<span class=\\\"page next\\\"><a href=\\\"/foo?page=4\\\"   rel=\\\"next\\\" aria-label=\\\"next\\\">Next&nbsp;&rsaquo;</a></span>\"},{\"0\":[1,2,\"3\",4,5,6]},\"page\"]</script>"
    end

    it 'renders last page' do
      pagy = Pagy.new(count: 103, page: 6)
      _(view.pagy_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-nav-js pagination\" role=\"navigation\" aria-label=\"pager\"></nav><script type=\"application/json\" class=\"pagy-json\">[\"nav\",\"test-id\",{\"before\":\"<span class=\\\"page prev\\\"><a href=\\\"/foo?page=5\\\"   rel=\\\"prev\\\" aria-label=\\\"previous\\\">&lsaquo;&nbsp;Prev</a></span> \",\"link\":\"<span class=\\\"page\\\"><a href=\\\"/foo?page=__pagy_page__\\\"   >__pagy_page__</a></span> \",\"active\":\"<span class=\\\"page active\\\">6</span> \",\"gap\":\"<span class=\\\"page gap\\\">&hellip;</span> \",\"after\":\"<span class=\\\"page next disabled\\\">Next&nbsp;&rsaquo;</span>\"},{\"0\":[1,2,3,4,5,\"6\"]},\"page\"]</script>"
    end

  end

  describe "#pagy_combo_nav_js" do

    it 'renders first page' do
      pagy = Pagy.new(count: 103, page: 1)
      _(view.pagy_combo_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-combo-nav-js pagination\" role=\"navigation\" aria-label=\"pager\"><span class=\"page prev disabled\">&lsaquo;&nbsp;Prev</span> <span class=\"pagy-combo-input\" style=\"margin: 0 0.6rem;\">Page <input type=\"number\" min=\"1\" max=\"6\" value=\"1\" style=\"padding: 0; text-align: center; width: 2rem;\"> of 6</span> <span class=\"page next\"><a href=\"/foo?page=2\"   rel=\"next\" aria-label=\"next\">Next&nbsp;&rsaquo;</a></span></nav><script type=\"application/json\" class=\"pagy-json\">[\"combo_nav\",\"test-id\",1,\"<a href=\\\"/foo?page=__pagy_page__\\\"   style=\\\"display: none;\\\"></a>\",\"page\"]</script>"
      _(view.pagy_bootstrap_combo_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-bootstrap-combo-nav-js pagination\" role=\"navigation\" aria-label=\"pager\"><div class=\"btn-group\" role=\"group\"><a class=\"prev btn btn-primary disabled\" href=\"#\">&lsaquo;&nbsp;Prev</a><div class=\"pagy-combo-input btn btn-primary disabled\" style=\"white-space: nowrap;\">Page <input type=\"number\" min=\"1\" max=\"6\" value=\"1\" class=\"text-primary\" style=\"padding: 0; border: none; text-align: center; width: 2rem;\"> of 6</div><a href=\"/foo?page=2\"   rel=\"next\" aria-label=\"next\" class=\"next btn btn-primary\">Next&nbsp;&rsaquo;</a></div></nav><script type=\"application/json\" class=\"pagy-json\">[\"combo_nav\",\"test-id\",1,\"<a href=\\\"/foo?page=__pagy_page__\\\"   style=\\\"display: none;\\\"></a>\",\"page\"]</script>"
      _(view.pagy_bulma_combo_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-bulma-combo-nav-js\" role=\"navigation\" aria-label=\"pagination\"><div class=\"field is-grouped is-grouped-centered\" role=\"group\"><p class=\"control\"><a class=\"button\" disabled>&lsaquo;&nbsp;Prev</a></p><div class=\"pagy-combo-input control level is-mobile\">Page <input class=\"input\" type=\"number\" min=\"1\" max=\"6\" value=\"1\" style=\"padding: 0; text-align: center; width: 2rem; margin:0 0.3rem;\"> of 6</div><p class=\"control\"><a href=\"/foo?page=2\"   rel=\"next\" class=\"button\" aria-label=\"next page\">Next&nbsp;&rsaquo;</a></p></div></nav><script type=\"application/json\" class=\"pagy-json\">[\"combo_nav\",\"test-id\",1,\"<a href=\\\"/foo?page=__pagy_page__\\\"   style=\\\"display: none;\\\"></a>\",\"page\"]</script>"
      _(view.pagy_foundation_combo_nav_js(pagy, pagy_test_id)).must_equal "<nav id=\"test-id\" class=\"pagy-foundation-combo-nav-js\" role=\"navigation\" aria-label=\"Pagination\"><div class=\"input-group\"><a style=\"margin-bottom: 0px;\" class=\"prev button primary disabled\" href=\"#\">&lsaquo;&nbsp;Prev</a><span class=\"input-group-label\">Page <input class=\"input-group-field cell shrink\" type=\"number\" min=\"1\" max=\"6\" value=\"1\" style=\"width: 2rem; padding: 0 0.3rem; margin: 0 0.3rem;\"> of 6</span><a href=\"/foo?page=2\"   rel=\"next\" style=\"margin-bottom: 0px;\" aria-label=\"next\" class=\"next button primary\">Next&nbsp;&rsaquo;</a></div></nav><script type=\"application/json\" class=\"pagy-json\">[\"combo_nav\",\"test-id\",1,\"<a href=\\\"/foo?page=__pagy_page__\\\"   style=\\\"display: none;\\\"></a>\",\"page\"]</script>"
      _(view.pagy_materialize_combo_nav_js(pagy, pagy_test_id)).must_equal "<div id=\"test-id\" class=\"pagy-materialize-combo-nav-js pagination\" role=\"navigation\" aria-label=\"pager\"><div class=\"pagy-compact-chip role=\"group\" style=\"height: 35px; border-radius: 18px; background: #e4e4e4; display: inline-block;\"><ul class=\"pagination\" style=\"margin: 0px;\"><li class=\"prev disabled\" style=\"vertical-align: middle;\"><a href=\"#\"><i class=\"material-icons\">chevron_left</i></a></li><div class=\"pagy-combo-input btn-flat\" style=\"cursor: default; padding: 0px\">Page <input type=\"number\" class=\"browser-default\" min=\"1\" max=\"6\" value=\"1\" style=\"padding: 2px; border: none; border-radius: 2px; text-align: center; width: 2rem;\"> of 6</div><li class=\"waves-effect next\" style=\"vertical-align: middle;\"><a href=\"/foo?page=2\"   rel=\"next\" aria-label=\"next\"><i class=\"material-icons\">chevron_right</i></a></li></ul></div><script type=\"application/json\" class=\"pagy-json\">[\"combo_nav\",\"test-id\",1,\"<a href=\\\"/foo?page=__pagy_page__\\\"   style=\\\"display: none;\\\"></a>\",\"page\"]</script>"
      _(view.pagy_semantic_combo_nav_js(pagy, pagy_test_id)).must_equal "<div id=\"test-id\" class=\"pagy-semantic-combo-nav-js ui compact menu\" role=\"navigation\" aria-label=\"pager\"><div class=\"item disabled\"><i class=\"left small chevron icon\"></i></div><div class=\"pagy-combo-input item\">Page <input type=\"number\" min=\"1\" max=\"6\" value=\"1\" style=\"padding: 0; text-align: center; width: 2rem; margin: 0 0.3rem\"> of 6</div> <a href=\"/foo?page=2\"  class=\"item\" rel=\"next\" aria-label=\"next\"><i class=\"right small chevron icon\"></i></a></div><script type=\"application/json\" class=\"pagy-json\">[\"combo_nav\",\"test-id\",1,\"<a href=\\\"/foo?page=__pagy_page__\\\"  class=\\\"item\\\" style=\\\"display: none;\\\"></a>\",\"page\"]</script>"
    end

    it 'renders intermediate page' do
      pagy = Pagy.new(count: 103, page: 3)
      html = view.pagy_combo_nav_js(pagy, pagy_test_id)
      _(html).must_equal "<nav id=\"test-id\" class=\"pagy-combo-nav-js pagination\" role=\"navigation\" aria-label=\"pager\"><span class=\"page prev\"><a href=\"/foo?page=2\"   rel=\"prev\" aria-label=\"previous\">&lsaquo;&nbsp;Prev</a></span> <span class=\"pagy-combo-input\" style=\"margin: 0 0.6rem;\">Page <input type=\"number\" min=\"1\" max=\"6\" value=\"3\" style=\"padding: 0; text-align: center; width: 2rem;\"> of 6</span> <span class=\"page next\"><a href=\"/foo?page=4\"   rel=\"next\" aria-label=\"next\">Next&nbsp;&rsaquo;</a></span></nav><script type=\"application/json\" class=\"pagy-json\">[\"combo_nav\",\"test-id\",3,\"<a href=\\\"/foo?page=__pagy_page__\\\"   style=\\\"display: none;\\\"></a>\",\"page\"]</script>"
    end

    it 'renders last page' do
      pagy = Pagy.new(count: 103, page: 6)
      html = view.pagy_combo_nav_js(pagy, pagy_test_id)
      _(html).must_equal "<nav id=\"test-id\" class=\"pagy-combo-nav-js pagination\" role=\"navigation\" aria-label=\"pager\"><span class=\"page prev\"><a href=\"/foo?page=5\"   rel=\"prev\" aria-label=\"previous\">&lsaquo;&nbsp;Prev</a></span> <span class=\"pagy-combo-input\" style=\"margin: 0 0.6rem;\">Page <input type=\"number\" min=\"1\" max=\"6\" value=\"6\" style=\"padding: 0; text-align: center; width: 2rem;\"> of 6</span> <span class=\"page next disabled\">Next&nbsp;&rsaquo;</span></nav><script type=\"application/json\" class=\"pagy-json\">[\"combo_nav\",\"test-id\",6,\"<a href=\\\"/foo?page=__pagy_page__\\\"   style=\\\"display: none;\\\"></a>\",\"page\"]</script>"
    end

  end

end
