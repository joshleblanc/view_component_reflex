# ViewComponentReflex

ViewComponentReflex allows you to write reflexes right in your view component code.

## Usage

You can add reflexes to your component by adding inheriting from `ViewComponentReflex::Component`.

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
    <button type="button" data-reflex="click->CounterComponentReflex#increment" data-key="<%= key %>">Click</button>
<% end %>
```

## Collections

In order to reconcile state to components in collections, you can specify a `collection_key` method that returns some
value unique to that component.

```
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

### omitted_from_state
Return an array of instance variables you want to omit from state. Useful if you have an object 
that isn't serializable as an instance variable, like a form.

```
def omitted_from_state
  [:@form]
end
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
