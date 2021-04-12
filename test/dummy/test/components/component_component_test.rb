require_relative "../../../test_helper"

class ComponentComponentTest < ViewComponent::TestCase
  def test_memory_adapter
    ViewComponentReflex::Engine.configure do |config|
      config.state_adapter = ViewComponentReflex::StateAdapter::Memory
    end

    assert_component
  end

  def test_session_adapter
    ViewComponentReflex::Engine.configure do |config|
      config.state_adapter = ViewComponentReflex::StateAdapter::Session
    end

    assert_component
  end

  def test_redis_adapter
    ViewComponentReflex::Engine.configure do |config|
      config.state_adapter = ViewComponentReflex::StateAdapter::Redis.new(
        redis_opts: {
          url: "redis://localhost:6379/1"
        },
        ttl: 3600)
    end

    assert_component
  end

  def assert_component
    assert_equal(
      %(<div data-controller="component" data-key="">\n  <span>Hello!</span>\n</div>),
      render_inline(ComponentComponent.new).to_html
    )
  end
end
