#!/usr/local/bin/ruby -w

# $Id: extconf.rb 43 2007-12-07 12:38:59Z transami $
#
# See the LICENSE file for copyright and distribution information

require 'mkmf'
require 'rubygems'

$preload = nil
$LIBPATH.push(Config::CONFIG['libdir'])

def crash(str)
  print(" extconf failure: %s\n", str)
  exit 1
end

# Directories
dir_config('iconv')
dir_config('zlib')
dir_config('xml2')
dir_config('xslt')
dir_config('exslt')
dir_config('libxml-ruby')

# First get zlib
unless have_library('z', 'inflate') or
       have_library('zlib', 'inflate') or
       have_library('zlib1', 'inflate') or
       have_library('libz', 'inflate')
  crash('need zlib')
else
  $defs.push('-DHAVE_ZLIB_H')
end

unless (have_library('xml2', 'xmlXPtrNewRange') or
        have_library('libxml2', 'xmlXPtrNewRange') or
        find_library('xml2', 'xmlXPtrNewRange', '/opt/lib', '/usr/local/lib', '/usr/lib')) and
       (have_header('libxml/xmlversion.h') or
        find_header('libxml/xmlversion.h',
                    '/opt/include/libxml2',
                    '/usr/local/include/libxml2',
                    '/usr/include/libxml2'))
  crash(<<EOL)
need libxml2.

        Install the library or try one of the following options to extconf.rb:

        --with-xml2-dir=/path/to/libxml2
        --with-xml2-lib=/path/to/libxml2/lib
        --with-xml2-include=/path/to/libxml2/include
EOL
end

unless (have_library('xslt','xsltApplyStylesheet') or
        have_library('libxslt','xsltApplyStylesheet') or
        find_library('xslt', 'xsltApplyStylesheet', '/opt/lib', '/usr/local/lib', '/usr/lib')) and
       (have_header('xslt.h') or
        find_header('xslt.h',
                    '/opt/include/libxslt',
                    '/usr/local/include/libxslt',
                    '/usr/include/libxslt'))
  crash(<<EOL)
need libxslt.

        Install the library or try one of the following options to extconf.rb:

        --with-xslt-dir=/path/to/libxslt
        --with-xslt-lib=/path/to/libxslt/lib
        --with-xslt-include=/path/to/libxslt/include
EOL
end

unless (have_library('exslt','exsltRegisterAll') or
        have_library('libexslt','exsltRegisterAll') or
        find_library('exslt', 'exsltRegisterAll', '/opt/lib', '/usr/local/lib', '/usr/lib')) and
       (have_header('exslt.h') or
        find_header('exslt.h',
                    '/opt/include/libexslt',
                    '/usr/local/include/libexslt',
                    '/usr/include/libexslt'))
  crash(<<EOL)
need libexslt.

        Install the library or try one of the following options to extconf.rb:

        --with-exslt-dir=/path/to/libexslt
        --with-exslt-lib=/path/to/libexslt/lib
        --with-exslt-include=/path/to/libexslt/include
EOL
end

# Figure out where libxml-ruby is installed
gem_specs = Gem.source_index.find_name('libxml-ruby')
if gem_specs.empty?
  crash(<<EOL)
libxml-ruby bindings must be installed
EOL
end

gem_specs = gem_specs.sort_by {|spec| spec.version}.reverse
libxml_ruby_path = gem_specs.first.full_gem_path

$INCFLAGS += " -I#{libxml_ruby_path}/ext"
$LIBPATH.push("#{libxml_ruby_path}/lib")

unless have_header('libxml/ruby_libxml.h') and
       have_header('libxml/ruby_xml_document.h')
  crash(<<EOL)
need headers for libxml-ruby.

        If you downloaded a release, this is a bug - please inform
        libxml-devel@rubyforge.org including the release version and
        download URL you obtained it from.

        If you checked libxslt-ruby out from CVS, you will need to
        obtain the headers from CVS (using the same version tag if
        applicable) and place them in directory 'ext/xml/libxml-ruby'.
EOL
end

unless (have_library('xml_ruby', 'rxml_document_wrap') or
        have_library('libxml_ruby', 'rxml_document_wrap'))
  crash(<<EOL)
  need libxml-ruby
        Install libxml-ruby first.
EOL
end

create_header()
create_makefile("libxslt_ruby")
