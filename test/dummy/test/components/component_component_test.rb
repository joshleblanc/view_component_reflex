require_relative "../../../test_helper"

class ComponentComponentTest < ViewComponent::TestCase
  def test_memory_adapter
    ViewComponentReflex::Engine.configure do |config|
      config.state_adapter = ViewComponentReflex::StateAdapter::Memory
    end
    assert_equal(
      %(<div data-controller="component" data-key="">\n  <span>Hello!</span>\n</div>),
      render_inline(ComponentComponent.new).to_html
    )
  end

  def test_session_adapter
    ViewComponentReflex::Engine.configure do |config|
      config.state_adapter = ViewComponentReflex::StateAdapter::Session
    end
    assert_equal(
      %(<div data-controller="component" data-key="">\n  <span>Hello!</span>\n</div>),
      render_inline(ComponentComponent.new).to_html
    )
  end
end
