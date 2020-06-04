# ViewComponentReflex

ViewComponentReflex allows you to write reflexes right in your view component code.

## Usage

You can add reflexes to your component by adding inheriting from `ViewComponentReflex::Component`.

To add a reflex to your component, use the `reflex` method.

```ruby
    reflex :my_cool_reflex do
      # do stuff
    end
```

This will act as if you created a reflex with the method `my_cool_stuff`. To call this reflex, add `data-reflex="click->MyComponentReflex#my_cool_reflex"`, just like you're
using stimulus reflex.

In addition to calling reflexes, there is a rudimentary state system. You can initialize component-local state with `initialize_state(obj)`, where `obj` is a hash.

You can access state with the `state` helper. See the code below for an example.

If you're using state, include `super()` at the beginning of your initialize method, and add `data-key="<%= key %>"` to any html element using a reflex. This 
lets ViewComponentReflex keep track of which state belongs to which component.


```ruby
    # counter_component.rb
    class CounterComponent < ViewComponentReflex::Component
   
      def initialize
        super()
        initialize_state({
          count: 0
        })
      end
    
      reflex :increment do
        state[:count] = state[:count] + 1
      end
    end
```

```erb
# counter_component.html.erb
<p><%= state[:count] %></p>
<button type="button" data-reflex="click->CounterComponentReflex#increment" data-key="<%= key %>">Click</button>
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
