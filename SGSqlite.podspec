
Pod::Spec.new do |s|

  s.name         = "SGSqlite"
  s.version      = "1.0.0"
  s.summary      = "A simple object oriented sqlite3."
  s.description  = "A simple encapsulation of an object oriented database for sqlite3."

  s.homepage     = "https://github.com/install-b/SGSqlite"
  s.license      = "MIT"
  s.author       = { "ShangenZhang" => "645256685@qq.com" }

  s.platform     = :os
  s.platform     = :ios

  s.source       = { :git => "https://github.com/install-b/SGSqlite.git", :tag => s.version }

  s.source_files  = "Classes/**/*.{h,m}"
  s.public_header_files = "Classes/**/*.h"

  s.framework  = "Foundation"
  s.library   = "sqlite3"

  s.requires_arc = true

end
