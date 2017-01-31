# --                                                            ; {{{1
#
# File        : active-dump.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2014-08-12
#
# Copyright   : Copyright (C) 2014  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'active_record'
require 'erb'
require 'yaml'

# namespace
module ActiveDump

  CFG_DB    = 'config/database.yml'
  CFG_DUMP  = 'config/active-dump.yml'
  FOLDER    = 'db/data/'

  # --

  # dump to yaml
  def self.dump(cfg)                                            # {{{1
    data = cfg[:models].each do |m|
      records = m.constantize.all.map(&:attributes)
      data = [m, records]

      if cfg[:verbose] or cfg[:dryrun]
        printf(
          "dumping model %-30s: %10d record(s)\n",
          m, records.length
        )
      end

      unless cfg[:dryrun]
        file_name = "#{m.parameterize}.yaml"
        file_path = File.join(cfg[:folder], file_name)
        IO.write(file_path, YAML.dump(data))
      end
    end
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

  # fix postgresql sequences
  def self.fix_seqs(cfg)                                        # {{{1
    conn = connection
    ActiveRecord::Base.transaction do
      cfg[:models].each do |m|
        mod = m.constantize
        seq = conn.quote_table_name mod.sequence_name
        max = mod.all.max_by(&:id)
        n   = (max ? max.id : 0) + 1;
        sql = "ALTER SEQUENCE #{seq} RESTART WITH #{n};"
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
    c4 = { folder: FOLDER } .merge c3.reject { |k,v| v.nil? }
    c4[:models] && !c4[:models].empty? ? c4
                                       : c4.merge(models: all_models)
  end                                                           # }}}1

  # ActiveRecord connection
  # @todo use model?!
  def self.connection                                           # {{{1
    return @connection if @connection
    unless (ActiveRecord::Base.connection rescue nil)
      c = YAML.load ERB.new(File.read(CFG_DB)).result
      ActiveRecord::Base.establish_connection c[env]
    end
    @connection = ActiveRecord::Base.connection
  end                                                           # }}}1

  # eager_load! all rails engines' models (if Rails is defined)
  def self.eager_load!                                          # {{{1
    return false if @eager_load
    if defined? ::Rails
      ::Rails::Engine.subclasses.each do |e|
        e.eager_load!
      end
      ::Rails.application.eager_load!
    end
    @eager_load = true
  end                                                           # }}}1

  # like Rails.env; (cached)
  def self.env
    @env ||= ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
