require 'dotenv/load'
require 'nokogiri'

doc_path, = ARGV

doc = Nokogiri::XML(File.open(doc_path)) do |config|
  config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS
end

# Remove unnecessary nodes.
doc.xpath('//manifest/application/service').remove
doc.xpath('//manifest/application/activity[@android:name="org.love2d.android.DownloadActivity"]').remove
doc.xpath('//manifest/application/activity[@android:name="org.love2d.android.GameActivity"]/intent-filter[position()>1]').remove
doc.xpath('//comment()').remove

# Change package in manifest.
manifest = doc.at_xpath('//manifest')
manifest['package'] = ENV['GAME_BUNDLE_IDENTIFIER']

# Rename application.
application = manifest.at_xpath('//manifest/application')
application['android:label'] = ENV['GAME_TITLE']

# Rename activity.
activity = manifest.at_xpath('//manifest/application/activity')
activity['android:label'] = ENV['GAME_TITLE']

File.open(doc_path, 'w') { |file| file << doc }
