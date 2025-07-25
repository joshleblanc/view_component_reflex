# ViewComponentReflex

ViewComponentReflex allows you to write reflexes right in your view component code.

It builds upon [stimulus_reflex](https://github.com/hopsoft/stimulus_reflex) and [view_component](https://github.com/github/view_component)

## Usage

You can add reflexes to your component by inheriting from `ViewComponentReflex::Component`.

This will act as if you created a reflex with the method `my_cool_stuff`. To call this reflex, add `data-reflex="click->MyComponentReflex#my_cool_reflex"`, just like you're
using stimulus reflex.

ViewComponentReflex will maintain your component's instance variables between renders. You need to include `data-key=<%= key %>` on your root element, as well 
as any element that stimulates a reflex. ViewComponent is inherently state-less, so the key is used to reconcile state to its respective component.

### Example
```ruby
# counter_component.rb
class CounterComponent < ViewComponentReflex::Component
  def initialize
    @count = 0
  end

  def increment
    @count += 1
  end
end
```

```erb
# counter_component.html.erb
<%= component_controller do %>
    <p><%= @count %></p>
    <%= reflex_tag :increment, :button, "Click" %>
<% end %>
```

## Collections

In order to reconcile state to components in collections, you can specify a `collection_key` method that returns some
value unique to that component.

```ruby
class TodoComponent < ViewComponentReflex::Component
  def initialize(todo:)
    @todo = todo
  end

  def collection_key
    @todo.id
  end
end
#
<%= render(TodoComponent.with_collection(Todo.all)) %>
```

In case you're rendering a collection of empty models, use a UUID of some sort to address the correct component instance on your page:

```ruby
class TodoComponent < ViewComponentReflex::Component
  def initialize(todo:)
    @todo = todo
  end

  def collection_key
    @todo.id || SecureRandom.hex(16)
  end
end
#
<%= render(TodoComponent.with_collection((0..5).map { Todo.new })) %>
```

## API

### permit_parameter?(initial_param, new_params)
If a new parameter is passed to the component during rendering, it is used instead of what's in state.
If you're storing instances in state, you can use this to properly compare them.

```ruby
def permit_parameter?(initial_param, new_param)
  if new_param.instance_of? MyModel 
    new_param.id == @my_model.id
  else
    super
  end
end
```

### omitted_from_state
Return an array of instance variables you want to omit from state. Only really useful if you're using the session state
adapter, and you have an instance variable that can't be serialized.

```ruby
def omitted_from_state
  [:@form]
end
```

### reflex_tag(reflex, name, content_or_options_with_block = nil, options = nil, escape = true, &block)
This shares the same definition as `content_tag`, except it accepts a reflex as the first parameter.

```erb
<%= reflex_tag :increment, :button, "Click me!" %>
```

Would add a click handler to the `increment` method on your component.

To use a non-click event, specific that with `->` notation

```erb
<%= reflex_tag "mouseenter->increment", :button, "Click me!" %>
```

### reflex_data_attributes(reflex)

This helper will give you the data attributes used in the reflex_tag above if you want to build your own elements.

Build your own tag:

```erb
<%= link_to (image_tag photo.image.url(:medium)), data: reflex_data_attributes(:increment) %>
```

Render a ViewComponent

```erb
<%= render ButtonComponent.new(data: reflex_data_attributes("mouseenter->increment")) %>
```

Make sure that you assign the reflex_data_attributes to the correct element in your component.

### collection_key
If you're rendering a component as a collection with `MyComponent.with_collection(SomeCollection)`, you must define this method to return some unique value for the component.
This is used to reconcile state in the background.

```ruby
def initialize
  @my_model = MyModel.new
end

def collection_key
  @my_model.id
end
```

### stimulate(target, data)
Stimulate another reflex from within your component. This typically requires the key of the component you're stimulating
which can be passed in via parameters.

```ruby
def initialize(parent_key)
  @parent_key = parent_key
end

def stimulate_other
  stimulate("OtherComponent#method", { key: @parent_key })
end
```

### refresh!(selectors)
Refresh a specific element on the page. Using this will implicitly run `prevent_render!`.
If you want to render a specific element, as well as the component, a common pattern would be to pass `selector` as one of the parameters

```
def my_method
  refresh! '#my-special-element', selector
end
```

### selector
Returns the unique selector for this component. Useful to pass to `refresh!` when refreshing custom elements.

### prevent_refresh!
By default, VCR will re-render your component after it executes your method. `prevent_refresh!` prevents this from happening.

```ruby
def my_method
  prevent_refresh!
  @foo = :bar
end # the rendered page will not reflect this change
```

### refresh_all!
Refresh the entire body of the page

```ruby
def do_some_global_action
  prevent_refresh!
  session[:model] = MyModel.new
  refresh_all!
end
```

### stream_to(channel)
Stream to a custom channel, rather than the default stimulus reflex one

```ruby
def do_something
  stream_to MyChannel
  
  @foo = :bar
end
```

### key
This is a key unique to a particular component. It's used to reconcile state between renders, and should be passed as a data attribute whenever a reflex is called

```erb
<button type="button" data-reflex="click->MyComponent#do_something" data-key="<%= key %>">Click me!</button>
```

### component_controller(options = {}, &blk)
This is a view helper to properly connect VCR to the component. It outputs `<div data-controller="my-controller" key=<%= key %></div>`
You *must* wrap your component in this for everything to work properly.

```erb
<%= component_controller do %>
  <p><%= @count %></p
<% end %>
```

### after_state_initialized(parameters_changed)

This is called after the state has been inserted in the component. You can use this to run conditional functions after 
some parameter has superseeded whatever's in state

```
def after_state_initialized(parameters_changed)
  if parameters_changed.include?(:@filter)
    calculate_visible_rows
  end
end
```

### reflex_methods

By default, all public instance methods are available as reflex methods. You can override this to explicitly define which methods should be available as reflexes:

```ruby
class MyComponent < ViewComponentReflex::Component
  def self.reflex_methods
    [:increment, :decrement, :reset]
  end
  
  def increment
    @count += 1
  end
  
  def decrement
    @count -= 1  
  end
  
  def reset
    @count = 0
  end
  
  def private_helper_method
    # This won't be available as a reflex since it's not in reflex_methods
  end
end
```

## Custom reflex base class
Reflexes typically inherit from a base ApplicationReflex. You can define the base class for a view_component_reflex by using the `reflex_base_class` accessor.
The parent class must inherit ViewComponentReflex::Reflex, and will throw an error if it does not.

```ruby
class ApplicationReflex < ViewComponentReflex::Reflex

end


class MyComponent < ViewComponentReflex::Component
  MyComponent.reflex_base_class = ApplicationReflex
end
```

## Per-component state adapters
You can override the default state adapter for a component by using the `state_adapter` helper.

```ruby
class MyComponent < ViewComponentReflex::Component
  state_adapter :dom # or :session, or :memory
end
```

This will also accept a fully qualified constant 

```ruby
class MyComponent < ViewComponentReflex::Component
  state_adapter ViewComponentReflex::StateAdapter::Redis.new(
    redis_opts: {
      url: "redis://localhost:6379/1", driver: :hiredis
    },
    ttl: 3600)
end
```

## Common patterns
A lot of the time, you only need to update specific components when changing instance variables. For example, changing `@loading` might only need
to display a spinner somewhere on the page. You can define setters to implicitly render the appropriate pieces of dom whenever that variable is set

```ruby
def initialize
  @loading = false
end

def loading=(new_value)
  @loading = new_value
  refresh! '#loader'
end

def do_expensive_action
  prevent_refresh! 

  self.loading = true
  execute_it
  self.loading = false
end
```

```erb
<%= component_controller do %>
  <div id="loader"> 
    <% if @loading %>
      <p>Loading...</p>
    <% end %>
  </div>

  <button type="button" data-reflex="click->MyComponent#do_expensive_action" data-key="<%= key %>">Click me!</button>
<% end
```

## State

By default (since version `2.3.2`), view_component_reflex stores component state in session. You can optionally set the state adapter
to use the memory by changing `config.state_adapter` to `ViewComponentReflex::StateAdapter::Memory`.

Optionally, you can also store state right in the dom with `ViewComponentReflex::StateAdapter::Dom`.
Note that the DOM adapter requires the `data-reflex-dataset="children"` property to be set on anything firing the reflex. You can mix it with other options like `data-reflex-dataset="ancestors children"`.
Optionally you can include all datasets in the reflex `data-reflex-dataset="*"` but in large applications you may want to limit the amount of data being transferred only to what is necessary.

When using the `ViewComponentReflex::StateAdapter::Dom` make sure your key does not contain underscores and is limited to max. 80 characters. That's important when you'd be using customized [collection_key](#collections) which increases the length of the key.

## Custom State Adapters

ViewComponentReflex uses session for its state by default. To change this, add
an initializer to `config/initializers/view_component_reflex.rb`.

```ruby
ViewComponentReflex::Engine.configure do |config|
  config.state_adapter = YourAdapter
end
```

## Existing Fast Redis based State Adapter

This adapter uses hmset and hgetall to reduce the number of operations. 
This is the recommended adapter if you are using AnyCable.

```ruby
ViewComponentReflex::Engine.configure do |config|
  config.state_adapter = ViewComponentReflex::StateAdapter::Redis.new(
      redis_opts: {
          url: "redis://localhost:6379/1", driver: :hiredis
      },
      ttl: 3600)
end
```

`YourAdapter` should implement 

```ruby
class YourAdapter
  ##
  # request - a rails request object
  # key - a unique string that identifies the component instance
  def self.state(request, key)
    # Return state for a given key
  end

  ##
  # set_state is used to modify the state.
  #
  # request - a rails request object
  # controller - the current controller
  # key - a unique string that identifies the component
  # new_state - the new state to set
  def self.set_state(request, controller, key, new_state)
    # update the state
  end


  ##
  # store_state is used to replace the state entirely. It only accepts
  # a request object, rather than a reflex because it's called from the component's 
  # side with the component's instance variables.
  #
  # request - a rails request object
  # key - a unique string that identifies the component instance
  # new_state - a hash containing the component state
  def self.store_state(request, key, new_state = {})
    # replace the state
  end
end
```


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'view_component_reflex'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install view_component_reflex
```

# Common problems

## Uninitialized constants \<component\>Reflex
A component needs to be wrapped in `<%= component_controller do %>` in order to properly initialize, otherwise the Reflex class won't get created.

## Session is an empty hash
StimulusReflex 3.3 introduced _selector morphs_, allowing you to render arbitrary strings via `ApplicationController.render`, for example:

```rb
def test_selector
  morph '#some-container', ApplicationController.render(MyComponent.new(some: :param))
end
```

StimulusReflex 3.4 introduced a fix that merges the current `request.env` and provides the CSRF token to fetch the session.

## Help, my instance variables do not persist into the session

These instance variable names are not working and unsafe:

```rb
def unsafe_instance_variables
  [
    :@view_context, :@lookup_context, :@view_renderer, :@view_flow,
    :@virtual_path, :@variant, :@current_template, :@output_buffer, :@key,
    :@helpers, :@controller, :@request, :@tag_builder, :@initialized_state
  ]
end
```
Please use a different name to be able to save them to the session.

## Foo Can't Be Dumped

If you are getting errors that e.g. MatchData, Singleton etc. can't be dumped, ensure that you do not set any instance variables in your components (or any class you inject into them, for that matter) that cannot be marshaled.

This can be easily remedied though, by providing a list of unmarshalable instance variables and overwriting `marshal_dump` and `marshal_load` (from [https://stackoverflow.com/a/32877159/4341756](https://stackoverflow.com/a/32877159/4341756)):

```rb
class MarshalTest
  UNMARSHALED_VARIABLES = [:@foo, :@bar]

  def marshal_dump
    instance_variables.reject{|m| UNMARSHALED_VARIABLES.include? m}.inject({}) do |vars, attr|
      vars[attr] = instance_variable_get(attr)
      vars
    end
  end

  def marshal_load(vars)
    vars.each do |attr, value|
      instance_variable_set(attr, value) unless UNMARSHALED_VARIABLES.include?(attr)
    end
  end
end
```

## Anycable

@sebyx07 provided a solution to use anycable (https://github.com/joshleblanc/view_component_reflex/issues/23#issue-721786338)

Leaving this, might help others:

I tried this with any cable and I had to add this to development.rb
Otherwise @instance_variables were nil after a reflex

```ruby
  config.cache_store = :redis_cache_store, { url: "redis://localhost:6379/1", driver: :hiredis }
  config.session_store :cache_store
```

## Sidecar assets

When using ViewComponent generated sidecar assets, the stimulus controller won't resolve properly.
To resolve this, override the `self.stimulus_controller` method in your component to the correct method. 

For example, if you have a structure of 

```
components/
  example_component/
    example_component_controller.js
    example_component.html.erb
  example_component.rb
```

You would update your `self.stimulus_controller` method to 

```ruby
def self.stimulus_controller
  "example-component--example-component"
end
```

Thanks @omairrazam for this solution

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Caveats

State uses session to maintain state as of right now. It also assumes your component view is written with a file extension of either `.html.erb`, `.html.haml` or `.html.slim`.

## Support me

<a href="https://www.buymeacoffee.com/jleblanc" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="40" ></a>

