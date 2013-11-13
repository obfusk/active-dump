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
    def self.define_tasks
      namespace :db do
        namespace :data do
          desc 'dump $MODELS to $FILE'
          task :dump => :environment do
            m = ENV['MODELS']
            c = ActiveDump.config ENV['FILE'], (m && m.split ',')
            ActiveDump.dump c
          end

          desc 'restore from $FILE'
          task :restore => :environment do
            c = ActiveDump.config ENV['FILE']
            ActiveDump.restore c
          end
        end
      end
    end

  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
