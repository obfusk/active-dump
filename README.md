[]: {{{1

    File        : README.md
    Maintainer  : Felix C. Stegerman <flx@obfusk.net>
    Date        : 2013-11-13

    Copyright   : Copyright (C) 2013  Felix C. Stegerman
    Version     : v0.0.1

[]: }}}1

[![Gem Version](https://badge.fury.io/rb/active-dump.png)](http://badge.fury.io/rb/active-dump)

## Description
[]: {{{1

  active-dump - dump and restore activerecord from/to yaml

  active-dump provides 2 rake tasks that allow you to dump and restore
  activerecord data from/to yaml:

  * `rake db:data:dump` creates a yaml dump
  * `rake db:data:restore` restores a yaml dump

#

  NB: active-dump does not take migrations (or validations etc.) into
  account -- it dumps and restores raw data from the ActiveRecord
  models -- so make sure your migrations are in sync.

  When using rails, add this to your Gemfile:

```ruby
gem 'active-dump', require: 'active-dump/rails'
```

[]: {{{2

  You can use these environment variables to configure active-dump:

  * `RAILS_ENV`: the environment
  * `FILE`: the file to dump to/restore from (defaults to
    `db/data.yml`)
  * `MODELS`: the models to dump (defaults to all models)

#

  Configuration files:

  * `config/active-dump.yml`: the default file and models
  * `config/database.yml`: database connection

[]: }}}2

[]: }}}1

## Examples
[]: {{{1

    $ rake db:data:dump MODELS=Foo,Bar
    $ RAILS_ENV=production rake db:data:load

`config/active-dump.yml`:

```yaml
file: db/dump.yml
models:
  - Cms::Block
  - Cms::Categorization
  - Cms::Category
  - Cms::File
  - Cms::Layout
  - Cms::Page
  - Cms::Revision
  - Cms::Site
  - Cms::Snippet
```

[]: }}}1

## Specs & Docs

    $ rake spec   # TODO
    $ rake docs

## TODO

  * specs/docs?
  * use model's database connection?!
  * ...

## License

  GPLv2 [1] or EPLv1 [2].

## References
[]: {{{1

  [1] GNU General Public License, version 2
  --- http://www.opensource.org/licenses/GPL-2.0

  [2] Eclipse Public License, version 1
  --- http://www.opensource.org/licenses/EPL-1.0

[]: }}}1

[]: ! ( vim: set tw=70 sw=2 sts=2 et fdm=marker : )
