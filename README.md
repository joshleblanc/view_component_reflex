# ViewComponentReflex

ViewComponentReflex allows you to write reflexes right in your view component code.

## Usage

You can add reflexes to your component by adding inheriting from `ViewComponentReflex::Component`.

To add a reflex to your component, use the `reflex` method.

```ruby
    reflex :my_cool_reflex do
      # do stuff
      refresh!
    end
```

This will act as if you created a reflex with the method `my_cool_stuff`. To call this reflex, add `data-reflex="click->MyComponentReflex#my_cool_reflex"`, just like you're
using stimulus reflex.

#####note: A reflex will not automatically re-render the component upon its completion. A component will re-render whenever the `set_state` or `refresh!` method is called.

In addition to calling reflexes, there is a rudimentary state system. You can initialize component-local state with `initialize_state(obj)`, where `obj` is a hash.

You can access state with the `state` helper. See the code below for an example. Calling `set_state` will set the state, 
and also re-render your component.

If you're using state add `data-key="<%= key %>"` to any html element using a reflex. This 
lets ViewComponentReflex keep track of which state belongs to which component.


```ruby
    # counter_component.rb
    class CounterComponent < ViewComponentReflex::Component
   
      def initialize
        initialize_state({
          count: 0
        })
      end
    
      reflex :increment do
        set_state(count: state[:count] + 1)
      end
    end
```

```erb
# counter_component.html.erb
<div data-controller="counter">
    <p><%= state[:count] %></p>
    <button type="button" data-reflex="click->CounterComponentReflex#increment" data-key="<%= key %>">Click</button>
</div>
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
  # reflex - The reflex instance that's trying to set the state
  # key - a unique string that identifies the component
  # new_state - the new state to set
  def self.set_state(reflex, key, new_state)
  end


  ##
  # request - a rails request object
  # key - a unique string that identifies the component instance
  # new_state - a hash containing the component state
  def self.store_state(request, key, new_state = {})
    # store the state 
    # this will be called twice, once with key, once with key_initial
    # key_initial contains the initial, unmodified state.
    # it should be used in reconcile_state to decide whether or not
    # to re-initialize the state
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
