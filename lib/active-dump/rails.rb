# --                                                            ; {{{1
#
# File        : active-dump/rails.rb
# Maintainer  : Felix C. Stegerman <flx@obfusk.net>
# Date        : 2013-08-12
#
# Copyright   : Copyright (C) 2013  Felix C. Stegerman
# Licence     : LGPLv3+
#
# --                                                            ; }}}1

require 'rails'

require 'active-dump/rake'

# namespace
module ActiveDump

  # railtie that adds the rake tasks
  class Railtie < ::Rails::Railtie
    rake_tasks { ActiveDump::Rake.define_tasks }
  end

end

# vim: set tw=70 sw=2 sts=2 et fdm=marker :
