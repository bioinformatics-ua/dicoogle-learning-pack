source "https://rubygems.org"

require 'json'
require 'open-uri'

gem "jekyll-theme-slate"

# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
versions = JSON.parse(open('https://pages.github.com/versions.json').read)
gem "github-pages", versions['github-pages'], group: :jekyll_plugins

# If you have any plugins, put them here!
group :jekyll_plugins do
   gem "jekyll-github-metadata", "2.5.1"
#   gem "jekyll-feed", "~> 0.6"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

