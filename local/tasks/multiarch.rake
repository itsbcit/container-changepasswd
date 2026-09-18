# frozen_string_literal: true

desc 'Build and push multi-platform images'
task multiarch: :template do
  platforms = ENV.fetch('PLATFORMS', 'linux/amd64,linux/arm64')
                 .split(',')
                 .map(&:strip)
                 .reject(&:empty?)
  builder = ENV.fetch('BUILDX_BUILDER', 'changepasswd-multiarch')

  abort 'PLATFORMS must contain at least one platform' if platforms.empty?
  abort 'Docker Buildx is required' unless system('docker', 'buildx', 'version', out: File::NULL, err: File::NULL)

  unless system('docker', 'buildx', 'inspect', builder, out: File::NULL, err: File::NULL)
    sh 'docker', 'buildx', 'create', '--name', builder, '--driver', 'docker-container'
  end
  sh 'docker', 'buildx', 'inspect', builder, '--bootstrap'

  registries = $images
               .select { |image| image.build_image? && image.push_image? }
               .flat_map(&:registries)
               .map do |registry|
                 registry_url = registry['url'] || registry[:url]
                 registry_url.to_s.empty? ? 'docker.io' : registry_url
               end
               .uniq

  registries.each { |registry| sh 'docker', 'login', registry }

  puts "*** Building and pushing images for #{platforms.join(', ')} ***".green

  $images.each do |image|
    next unless image.build_image? && image.push_image?

    destination_tags = image.registries.flat_map do |registry|
      registry_url = (registry['url'] || registry[:url]).to_s
      registry_url = '' if registry_url == 'docker.io'
      org_name = registry['org_name'] || registry[:org_name]
      repository = image.parts_join('/', registry_url, org_name.to_s, image.image_name)

      image.tags.map { |tag| "#{repository}:#{tag}" }
    end.uniq

    abort "No destination tags configured for #{image.image_name}" if destination_tags.empty?

    puts "Image: #{destination_tags.join(', ')}".pink

    command = [
      'docker', 'buildx', 'build',
      '--builder', builder,
      '--platform', platforms.join(','),
      '--file', image.dockerfile
    ]
    destination_tags.each { |tag| command.concat(['--tag', tag]) }
    command.concat(['--push', '.'])

    sh(*command)
  end
end
