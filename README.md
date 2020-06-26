# ViewComponentReflex

ViewComponentReflex allows you to write reflexes right in your view component code.

## Usage

You can add reflexes to your component by adding inheriting from `ViewComponentReflex::Component`.

This will act as if you created a reflex with the method `my_cool_stuff`. To call this reflex, add `data-reflex="click->MyComponentReflex#my_cool_reflex"`, just like you're
using stimulus reflex.

ViewComponentReflex will maintain your component's instance variables between renders. You need to include `data-key=<%= key %>` on your root element, as well 
as any element that stimulates a reflex. ViewComponent is inherently state-less, so the key is used to reconcile state to its respective component.

### example
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
<p><%= @count %></p>
<%= reflex_tag :increment, :button, "Click" %>
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
Return an array of instance variables you want to omit from state. Useful if you have an object 
that isn't serializable as an instance variable, like a form.

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

To use a non-click event, specific that with `->` notiation

```erb
<%= reflex_tag "mouseenter->increment", :button, "Click me!" %>
```

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

### prevent_refresh!
By default, VCR will re-render your component after it executes your method. `revent_refresh!` prevents this from happening.

```ruby
def my_method
  prevent_refresh!
  @foo = Lbar
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

### key
This is a key unique to a particular component. It's used to reconcile state between renders, and should be passed as a data attribute whenever a reflex is called

```erb
<button type="button" data-reflex="click->MyComponent#do_something" data-key="<%= key %>">Click me!</button>
```

### component_controller(opts_or_tag = :div, opts = {}, &blk)

The rendered componentis automatically wrapped in a div to properly connect VCR to the component. If you want more control, you can use this helper in your view.

```erb
<%= component_controller :p, class: "fancy_count" do %>
  <%= @count %>
<% end %>
<p>I won't be touched by updates</p>
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
<div id="loader">
  <% if @loading %>
    <p>Loading...</p>
  <% end %>
</div>

<button type="button" data-reflex="click->MyComponent#do_expensive_action" data-key="<%= key %>">Click me!</button>
<% end
```

## Custom State Adapters

ViewComponentReflex uses session for its state by default. To change this, add
an initializer to `config/initializers/view_component_reflex.rb`.

```ruby
ViewComponentReflex.configure do |config|
  config.state_adapter = YourAdapter
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

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Caveats

State uses session to maintain state as of right now. It also assumes your component view is written with the file extension `.html.erb`
