Jekyll::Hooks.register :site, :after_init do |site|
  if ENV['CF_PAGES_BRANCH']
    branch = ENV['CF_PAGES_BRANCH']
    if branch == 'main' || branch == 'master'
      site.config['url'] = site.config['_cf_url']
    else
      # PR preview or topic branch - use CF_PAGES_URL
      site.config['url'] = ENV['CF_PAGES_URL']
      site.config['baseurl'] = ''
    end
  end
end
