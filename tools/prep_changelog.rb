# frozen_string_literal: true

require_relative '../lib/story_branch/git_wrapper'

def grab_and_print_log(from, to)
  all_log = StoryBranch::GitWrapper.command("log #{from}..#{to}")

  matches = all_log.scan(/CHANGELOG\n(.*?)--- 8< ---/m).flatten
  matches.map!(&:strip)

  File.open("release-#{from}-#{to}.md", 'w') do |output|
    output << "# RELEASE NOTES\n\n"
    matches.each do |m|
      output << "#{m}\n"
    end
  end
end

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def print_all_logs
  all_tags = StoryBranch::GitWrapper.command_lines('tag --list')
  cleanup_tags = all_tags.map do |t|
    { cleanup_tag: t.delete('v'), tag: t }
  end
  cleanup_tags.sort_by! { |ctags| ctags[:cleanup_tag] }
  puts cleanup_tags

  cleanup_tags.each_with_index do |tag, idx|
    next if idx + 1 >= cleanup_tags.length

    from = tag[:tag]
    to = cleanup_tags[idx + 1][:tag]
    grab_and_print_log(from, to)
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize

all_logs = ARGV[0] == 'all'
if all_logs
  print_all_logs
else
  from = ARGV[0] || 'v0.7.0'
  to = ARGV[1] || 'HEAD'
  grab_and_print_log(from, to)
end
