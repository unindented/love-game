require 'dotenv/load'
require 'xcodeproj'

project_path, = ARGV

project = Xcodeproj::Project.open(project_path)

supporting_files_group = project.main_group['Supporting Files']

launch_screen_ref = supporting_files_group.files.find { |file| file.name == 'Launch Screen.xib' }
launch_screen_ref.remove_from_project if launch_screen_ref

configs = project.objects.select do |obj|
  obj.isa == 'XCBuildConfiguration' && !obj.build_settings['PRODUCT_BUNDLE_IDENTIFIER'].nil?
end
configs.each do |c|
  c.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = ENV['GAME_BUNDLE_IDENTIFIER']
end

project.save
