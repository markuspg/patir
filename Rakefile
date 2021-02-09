# -*- ruby -*-
require 'hoe'

require_relative 'lib/zatir/version'

Hoe.spec('Zatir') do |prj|
  developer("Vassilis Rizopoulos", "vassilisrizopoulos@gmail.com")
  license "MIT"
  prj.version = Zatir::Version::STRING
  prj.summary='Zatir (Project Automation Tools in Ruby) provides libraries for use in project automation tools'
  prj.urls=["http://github.com/damphyr/zatir"]
  prj.description=prj.paragraphs_of('README.md',1..4).join("\n\n")
  prj.local_rdoc_dir='doc/rdoc'
  prj.readme_file="README.md"
  prj.extra_deps<<["systemu", "~>2.6"]
end

# vim: syntax=Ruby
