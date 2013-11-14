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
  def self.dump(cfg)                                            # {{{1
    data = Hash[ cfg[:models].map do |m|
      records = m.constantize.all.map(&:attributes)
      printf "dumping model %-30s: %10d record(s)\n",
        m, records.length if cfg[:verbose] or cfg[:dryrun]
      [m, records]
    end ]
    File.write cfg[:file], YAML.dump(data) unless cfg[:dryrun]
  end                                                           # }}}1

  # restore from yaml; optionally delete existing records first
  def self.restore(cfg)                                         # {{{1
    data = YAML.load File.read(cfg[:file])
    conn = connection
    ActiveRecord::Base.transaction do
      data.each do |m,records|
        table = m.constantize.quoted_table_name
        records.each do |record|
          cols = record.keys.map { |k| conn.quote_column_name k }
          vals = record.values.map { |v| conn.quote v }
          delete_record conn, cfg, table, conn.quote(record['id']) \
            if cfg[:delete]
          insert_record conn, cfg, table, cols, vals
        end
      end
    end
  end                                                           # }}}1

  # delete all records
  def self.delete(cfg)                                          # {{{1
    conn = connection
    ActiveRecord::Base.transaction do
      cfg[:models].each do |m|
        sql = "DELETE FROM #{m.constantize.quoted_table_name};"
        execute conn, cfg, sql
      end
    end
  end                                                           # }}}1

  # --

  # execute sql (optionally verbose)
  def self.execute(conn, cfg, sql)
    puts sql if cfg[:verbose] or cfg[:dryrun]
    conn.execute sql unless cfg[:dryrun]
  end

  # delete record w/ id; make sure everything is quoted !!!
  def self.delete_record(conn, cfg, table, id)
    sql = "DELETE FROM #{table} WHERE id = #{id};"
    execute conn, cfg, sql
  end

  # insert data; make sure everything is quoted !!!
  def self.insert_record(conn, cfg, table, cols, vals)
    sql = "INSERT INTO #{table} (#{cols*','}) VALUES (#{vals*','});"
    execute conn, cfg, sql
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

  # configuration
  def self.config(cfg = {})                                     # {{{1
    c1 = File.exists?(CFG_DUMP) ? YAML.load(File.read(CFG_DUMP)) : {}
    c2 = Hash[ c1.map { |k,v| [k.to_sym, v] } ]
    c3 = c2.merge cfg.reject { |k,v| v.nil? }
    c4 = { file: DUMP } .merge c3.reject { |k,v| v.nil? }
    c4[:models] && !c4[:models].empty? ? c4
                                       : c4.merge(models: all_models)
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
