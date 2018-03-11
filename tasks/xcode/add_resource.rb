require 'dotenv/load'
require 'xcodeproj'

project_path, resource_path = ARGV

project = Xcodeproj::Project.open(project_path)

resources_group = project.main_group['Resources']

resource_pathname = Pathname.new(File.expand_path(resource_path))
resource_ref = resources_group.files.find { |file| file.real_path == resource_pathname }
resource_ref ||= resources_group.new_file(resource_path)

project.targets.each do |target|
  unless target.resources_build_phase.files_references.include?(resource_ref)
    target.add_resources([resource_ref])
  end
end

project.save
