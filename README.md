# Carthframie

Welcome to **carthframie**! **carthframie** is ruby gem which makes easier to use Carthage dependeny manager for iOS.
After ```carthage update``` use **carthframie**'s ```add_frameworks``` method to add the built frameworks to the project.

|CI  |Status  |
|--|--|
| Master |  [![Build Status](https://travis-ci.org/ngergo100/carthframie.svg?branch=master)](https://travis-ci.org/ngergo100/carthframie)|

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carthframie'
```

And then execute:

    $ bundle update

Or install it yourself as:

    $ gem install carthframie

## Usage

Use add_frameworks method. Provide .xcodeproj file and target name as parameters like below

    $ carthframie add_frameworks Example.xcodeproj Example
    
Please note that you need to run add_frameworks in the project root directory. (Contains '.xcodeproj' and 'Carthage/Build')

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ngergo100/carthframie.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
