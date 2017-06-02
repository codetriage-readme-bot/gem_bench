module GemBench
  class StrictVersionRequirement
    attr_reader :gemfile_path
    attr_reader :gems
    attr_reader :starters
    attr_reader :benchers
    attr_reader :verbose

    def initialize(options = {})
      @gemfile_path = "#{Dir.pwd}/Gemfile"
      file = File.open(gemfile_path)
      # Get all lines as an array
      all_lines = file.readlines
      @gems = []
      all_lines.each_with_index do |line, index|
        # will return nil if the line is not a gem line
        gem = StrictVersionGem.from_line(all_lines, line, index)
        @gems << gem if gem
      end

      @starters, @benchers = @gems.partition {|x| x.valid }
      # Remove all the commented || blank lines
      @verbose = options[:verbose]
      self.print if self.verbose
    end

    def valid?
      gems.detect {|x| !x.valid? }.nil?
    end

    def print
      puts <<-EOS
There are #{starters.length} gems that have valid strict version constraints.
Of those:
  #{starters.count {|x| x.is_type?(:contraint) }} use normal constraints like '~> 1.2.3'.
  #{starters.count {|x| x.is_type?(:git_ref) }} use git ref constraints.
  #{starters.count {|x| x.is_type?(:git_tag) }} use git tag constraints.
There are #{benchers.length} gems that do not have strict version constraints.
Of those:
  #{benchers.count {|x| x.is_type?(:git_branch) }} use git branch constraints.
  #{benchers.count {|x| x.is_type?(:git) }} use some other for of git constraint considered not strict enough.
  #{benchers.count {|x| x.is_type?(:unknown) }} gems seem to not have any constraint at all.

The gems that need to be improved are:
  #{benchers.map(&:to_s).join("\n")}
EOS
    end
  end
end
