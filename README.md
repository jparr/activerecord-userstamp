# ActiveRecord-Userstamp [![Build Status](https://travis-ci.org/jparr/activerecord-userstamp.svg)](https://travis-ci.org/jparr/activerecord-userstamp)

## Overview

Userstamp extends `ActiveRecord::Base` to add automatic updating of `creator`, `updater`, and
`deleter` attributes. It is based loosely on `ActiveRecord::Timestamp`.

Two class methods (`model_stamper` and `stampable`) are implemented in this gem. The `model_stamper`
method is used in models that are responsible for creating, updating, or deleting other objects.
Typically this would be the `User` model of your application. The `stampable` method is used in
models that are subject to being created, updated, or deleted by stampers.

This gem only supports Ruby 2.2 and Rails 5.0 and above.

## Forkception

This is a fork of:

 - [activerecord-userstamp](https://github.com/lowjoel/activerecord-userstamp)
 - which is a fork of [magiclabs-userstamp](https://github.com/magiclabs/userstamp) gem
 - which is a fork of [Michael Grosser's](https://github.com/grosser)
   [userstamp gem] (https://github.com/grosser/userstamp)
 - which is a fork of the original [userstamp plugin](https://github.com/delynn/userstamp) by
   [delynn](https://github.com/delynn)


## Features
### Soft-deletes
The reason for this is because the original userstamp plugin does not support databases utilising
soft deletes. They are not tested explicitly within this gem, but it is expected to work with the
following gems:

 - [acts_as_paranoid](https://github.com/ActsAsParanoid/acts_as_paranoid)
 - [paranoia](https://github.com/radar/paranoia)

The `stampable` method has been modified to allow additional arguments to be passed to the
creator/updater relations. This allows declarations like:

```ruby
  stampable with_deleted: true
```

to result in a `belongs_to` relation which looks like:

```ruby
  belongs_to :creator, class_name: '::User', foreign_key: :created_by, with_deleted: true
```

Do create a ticket if it is broken, with a pull-request if possible.

### Customisable column names/types
While examining the userstamp gem's network on Github, it was noticed that quite a few forks were
made to allow customisability in the name and type of the column with the database migration.

This gem now supports customised column names. See the [usage](#usage) section on the
configuration options supported.

### Saving before validation
This fork includes changes to perform model stamping before validation. This allows models to
enforce the presence of stamp attributes:

```ruby
  validates :created_by, presence: true
  validates :updated_by, presence: true
```

Furthermore, the `creator` attribute is set only if the value is blank allowing for a manual
override.

## Usage
Assume that we are building a blog application, with User and Post objects. Add the following
to the application's Gemfile:

```ruby
  gem 'activerecord-userstamp'
```

Define an initializer in your Rails application to configure the gem:

```ruby
ActiveRecord::Userstamp.configure do |config|
  # config.default_stamper = 'User'
  # config.creator_attribute = :creator_id
  # config.updater_attribute = :updater_id
  config.deleter_attribute = nil
end
```

By default, `:deleter_attribute` is set to `:deleter_id` for soft deletes. If you are not using
soft deletes, you can set the attribute no `nil`.

Ensure that each model has a set of columns for creators, updaters, and deleters (if applicable.)

```ruby
  class CreateUsers < ActiveRecord::Migration
    def change
      create_table :users do |t|
        ...
        t.userstamps
      end
    end
  end

  class CreatePosts < ActiveRecord::Migration
    def change
      create_table :posts do |t|
        ...
        t.userstamps
      end
    end
  end
```

If you use `protect_from_forgery`, make sure the hooks are prepended:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true # with: anything will do, note `prepend: true`!
end
```

Declare the stamper on the User model:

```ruby
  class User < ActiveRecord::Base
    model_stamper
  end
```

If your stamper is called `User`, that's it; you're done.

## Customisation
The association which is created on each of the `creator_id`, `updater_id`, and `deleter_id` can
be customised. Also, the stamper used by each class can also be customised. For this purpose, the
 `ActiveRecord::Base.stampable` method can be used:

```ruby
  class Post < ActiveRecord::Base
    stampable
  end
```

The `stampable` method allows you to customize the `creator`, `updater`, and `deleter` associations.
It also allows you to specify the name of the stamper for the class being declared. Any additional
arguments are passed to the `belongs_to` declaration.

## Upgrading
### Upgrading from delynn's 1.x/2.x with `compatibility_mode`
The major difference between 1.x and 2.x is the naming of the columns. This version of the gem
allows specifying the name of the column from the gem configuration:

```ruby
ActiveRecord::Userstamp.configure do |config|
  config.creator_attribute = :created_by
  config.updater_attribute = :updated_by
  config.deleter_attribute = :deleted_by
end
```

### Upgrading from delynn's 2.x without `compatibility_mode`
Within migrations, it was possible to declare `t.userstamps` within a table definition. It used
to accept one argument, which declares whether the deleter column should be created. This has
been changed to respect the gem configuration's `deleter_attribute`. If that is `nil`, then no
deleter column would be created.

There is also no need to include the `Userstamp` module in `ApplicationController`.

### Upgrading from insphire's 2.0.1, or magiclabs-userstamp 2.0.2 or 2.1.0

That version of the gem allows every model to declare the name of the column containing the
attribute. That also means that in a large project, every model needs to declare `stampable`,
which is not very DRY.

To use this gem, normalise all database columns to use a consistent set of column names.
Configure the gem to use those names (as above) and remove all `stampable` declarations.

There is no need to include the `Userstamp` module in `ApplicationController`.

## Tests
Run

    $ bundle exec rspec

## Authors
 - [DeLynn Berry](http://delynnberry.com/): The original idea for this plugin came from the Rails
   Wiki article entitled
   [Extending ActiveRecord](http://wiki.rubyonrails.com/rails/pages/ExtendingActiveRecordExample)
 - [Michael Grosser](http://pragmatig.com)
 - [John Dell](http://blog.spovich.com/)
 - [Chris Hilton](https://github.com/chrismhilton)
 - [Thomas von Deyen](https://github.com/tvdeyen)
 - [Joel Low](http://joelsplace.sg)
