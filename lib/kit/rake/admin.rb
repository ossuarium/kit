require 'kit/rake/admin/database'
require 'kit/rake/admin/manage'
require 'kit/rake/admin/make'

def make_class_template file_name, class_line
  unless File.exists? file_name
    f = File.new file_name, 'w+'
    f << class_line
    f << "\nend"
    f.close
  end
end
