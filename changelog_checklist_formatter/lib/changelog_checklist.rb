class ChangelogChecklist
  def initialize(version_series)
    @version_series = version_series
  end

  def to_table
    get_changelog.split(/^\*/)
                 .map { |s| s.gsub('**', '*').gsub(/\n$/, '') }
                 .map { |s| s.strip || s }
                 .map { |s| "|#{s}| |\n" }.join('')
  end

  private

  def get_changelog
    segments = version_segments
    numbers = version_numbers(segments)
    entries = version_chunks(segments)
    formatted_changelog = numbers.zip(entries).flatten.compact
    formatted_changelog.join("\n\n\n")
  end

  def version_segments
    segments =
      read_changelog
      .split(/## QuickTravel /) # Array of Every version
      .select { |string| string.start_with? @version_series } # Find correct version at start of line

    if segments.empty?
      raise ArgumentError, "Cannot find version(s) for #{version_series}. " \
        'Please verify it exists and exactly follows changelog format including spacing'
    end

    segments
  end

  def read_changelog
    File.read(ENV.fetch('CHANGELOG_PATH', 'CHANGELOG.md'))
  end

  def version_numbers(version_segments)
    numbers = version_segments.map { |version_segment|
      version_segment
        .split('##') # Splits into version and body
        .first
        .strip
    }
    numbers
  end

  def version_chunks(version_segments)
    entries = version_segments.map { |version_segment|
      version_segment
        .split('##') # Splits into version and body
        .last
        .strip
    }
    entries
  end
end
