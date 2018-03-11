require 'dotenv/load'
require 'xcodeproj'

plist_path, = ARGV

plist = Xcodeproj::Plist.read_from_path(plist_path)

# Delete launch screen.
plist.delete('UILaunchStoryboardName')

# Delete type associations.
plist.delete('CFBundleDocumentTypes')
plist.delete('UTExportedTypeDeclarations')

# Overwrite bundle signature.
plist['CFBundleSignature'] = '????'

# Overwrite bundle name.
plist['CFBundleName'] = ENV['GAME_TITLE']
plist['CFBundleDisplayName'] = ENV['GAME_TITLE']

# Overwrite version strings.
plist['CFBundleVersion'] = ENV['GAME_VERSION']
plist['CFBundleShortVersionString'] = ENV['GAME_VERSION']

# Overwrite copyright if present.
if plist.key?('NSHumanReadableCopyright')
  plist['NSHumanReadableCopyright'] = "© #{Date.today.year} #{ENV['GAME_AUTHOR']}"
end

Xcodeproj::Plist.write_to_path(plist, plist_path)
