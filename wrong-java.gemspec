# -*- encoding: utf-8 -*-
loaded_gemspec = eval(File.read(File.expand_path('../wrong.gemspec', __FILE__)))
#loaded_gemspec.name = "wrong"
loaded_gemspec.platform = "java"
loaded_gemspec.dependencies.delete_if {|item| ["ParseTree", "sourcify", "file-tail"].include? item.name}
loaded_gemspec
