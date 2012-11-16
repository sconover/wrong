# -*- encoding: utf-8 -*-
loaded_gemspec = eval(File.read(File.expand_path('../wrong.gemspec', __FILE__)))
loaded_gemspec.platform = "java"
loaded_gemspec
