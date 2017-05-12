#!/usr/bin/env ruby

require 'thor'

class Persp < Thor

  option :delimiter, :banner => 'DELIM', :default => "\t", :aliases => :d
  option :row, :banner => 'ROW', :required => true, :aliases => :r, :type => :numeric
  option :columns, :banner => 'COLUMNS', :required => true, :aliases => :c, :type => :numeric
  option :indices, :banner => 'INDICES', :required => true, :aliases => :i
  desc '', ''
  def default
    delimiter = options[:delimiter].gsub(/\\t/, "\t")
    indices = options[:indices].split(',').map { |e| e.to_i-1 }
    contents = STDIN.readlines.map { |l| l.chomp.split(delimiter) }
    values = contents.each_with_object({}) do |l, h|
      h[l[options[:row]-1]] ||= {}
      h[l[options[:row]-1]][l[options[:columns]-1]] = l.values_at(*indices)
    end
    values_of_row = contents.map { |l| l[options[:row]-1] }.uniq
    values_of_columns = contents.map { |l| l[options[:columns]-1] }.uniq
    result = values_of_row.map do |row_v|
      ([row_v] + values_of_columns.map do |col_v|
        (values[row_v][col_v] || ['']*indices.size) * delimiter
        end) * delimiter
    end
    puts result
  end
end

Persp.start(ARGV.unshift('default'))
