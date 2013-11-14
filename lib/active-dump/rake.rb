# --                                                            ; {{{1
#
# File        : active-dump/rake.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-11-13
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : GPLv2 or EPLv1
#
# --                                                            ; }}}1

require 'rake/dsl_definition'

require 'active-dump'

# namespace
module ActiveDump

  # rake tasks
  module Rake
    extend ::Rake::DSL

    # define rake tasks
    def self.define_tasks                                       # {{{1
      namespace :db do
        namespace :data do
          desc 'Dump data'
          task :dump => :environment do
            ActiveDump.dump cfg_from_env
          end

          desc 'Restore data'
          task :restore => :environment do
            ActiveDump.restore cfg_from_env
          end

          desc 'Delete data'
          task :delete => :environment do
            ActiveDump.delete cfg_from_env
          end
        end
      end
    end                                                         # }}}1

    # get config from ENV
    def self.cfg_from_env                                       # {{{1
      f = ENV['FILE']   ; f2 = f && f.blank? ? nil : f
      m = ENV['MODELS'] ; ms = m && m.split(',')
      d = (ENV['DELETE'] ||'') =~ /yes|true/i
      v = (ENV['VERBOSE']||'') =~ /yes|true/i
      n = (ENV['DRYRUN'] ||'') =~ /yes|true/i
      ActiveDump.config file: f2, models: ms, delete: d, verbose: v,
        dryrun: n
    end                                                         # }}}1
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
