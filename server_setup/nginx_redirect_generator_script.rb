class RedirectsFileFormatter
  def self.format_from_page(page)
    page += (page[-1] == '/') ? '*' : '/*'
  end

  def self.format_to_url(url)
    url += (url[-1] == '/') ? '' : '/'
  end
end

puts "Redirects file should be one redirect per line, not including host names, from/to paths separated by whitespace e.g.: "
puts "/images/captaincook/flash_events/birthday?d=1		/sydney-harbour-cruises/"
puts "/images/captaincook/flash_events/wedding?d=1		/"
puts "Enter path to redirects file: "
path = STDIN.gets.chomp

redirects = File.open("#{path}").read
redirects.each_line do |redirect|
  from_url, to_url = redirect.split(/\s+/)
  from_page, from_params = from_url.split('?')

  from_page = RedirectsFileFormatter.format_from_page(from_page)
  to_url = RedirectsFileFormatter.format_to_url(to_url)

  if from_params
    puts "if ($args ~ #{from_params}) { rewrite ^#{from_page}$ #{to_url}? redirect; }"
  else
    puts "rewrite ^#{from_page}$ #{to_url} redirect;"
  end
end