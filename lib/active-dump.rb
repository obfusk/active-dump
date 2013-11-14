# --                                                            ; {{{1
#
# File        : active-dump.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-11-13
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

require 'active_record'
require 'yaml'

# namespace
module ActiveDump

  CFG_DB    = 'config/database.yml'
  CFG_DUMP  = 'config/active-dump.yml'
  DUMP      = 'db/data.yml'

  # --

  # dump to yaml
  def self.dump(c)                                              # {{{1
    data = Hash[ c['models'].map do |m|
      model   = m.constantize
      records = model.all.map(&:attributes)
      [m, records]
    end ]
    File.write c['file'], YAML.dump(data)
  end                                                           # }}}1

  # restore from yaml
  def self.restore(c)                                           # {{{1
    data = YAML.load File.read(c['file'])
    conn = connection
    ActiveRecord::Base.transaction do
      data.each do |m,records|
        model = m.constantize
        table = model.quoted_table_name
        records.each do |record|
          cols = record.keys.map { |k| conn.quote_column_name k }
          vals = record.values.map { |v| conn.quote v }
          insert conn, table, cols, vals
        end
      end
    end
  end                                                           # }}}1

  # --

  # insert data; make sure everything is quoted !!!
  def self.insert(conn, table, cols, vals)
    sql = "INSERT INTO #{table} (#{cols*','}) VALUES (#{vals*','})"
    conn.execute sql
  end

  # --

  # get all existing models' names
  def self.all_models                                           # {{{1
    return @models if @models
    eager_load!
    @models = ActiveRecord::Base.descendants.select do |m|
      (m.to_s != 'ActiveRecord::SchemaMigration') && \
       m.table_exists? && m.exists?
    end .map(&:to_s)
  end                                                           # }}}1

  # configuration: file + models
  def self.config(file, models = nil)                           # {{{1
    nb  = ->(x) { x && !x.blank? }
    ne  = ->(x) { x && !x.empty? }
    c   = File.exists?(CFG_DUMP) ? YAML.load(File.read(CFG_DUMP)) : {}
    c['file']   = file        if nb[file]
    c['models'] = models      if ne[models]
    c['file']   = DUMP        unless nb[c['file']]
    c['models'] = all_models  unless ne[c['models']]
    c
  end                                                           # }}}1

  # ActiveRecord connection
  # @todo use model?!
  def self.connection                                           # {{{1
    return @connection if @connection
    unless ActiveRecord::Base.connected?
      c = YAML.load File.read(CFG_DB)
      ActiveRecord::Base.establish_connection c[env]
    end
    @connection = ActiveRecord::Base.connection
  end                                                           # }}}1

  # eager_load! all rails engines' models (if Rails is defined)
  def self.eager_load!                                          # {{{1
    return false if @eager_load
    Rails::Engine::Railties.engines.each do |e|
      e.eager_load!
    end if defined? Rails
    @eager_load = true
  end                                                           # }}}1

  # like Rails.env; (cached)
  def self.env
    @env ||= ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
