# frozen_string_literal: true

require 'consul_watcher/class_helper'

module ConsulWatcher
  class Filters
    include ClassHelper

    def initialize(filter_config)
      populate_variables(filter_config)
    end

    def add_filters(filters_to_add)
      @filters = @filters.deep_merge(filters_to_add)
    end

    def filter?(change)
      @filters.each do |attribute, regexs|
        next unless change.key?(attribute) && !change[attribute].nil?

        match = match?(change[attribute], regexs)
        if match
          @logger.debug("filtered #{attribute} '#{change[attribute]}' against regular expressions #{regexs}")
          return true
        end
      end
      false
    end

    def match?(value, regexs)
      results = regexs.each.collect do |regex|
        value.match?(/#{regex}/)
      end
      results.any?
    end

    def print_filters
      @filters.each do |filter|
        @logger.debug("filter: #{filter}")
      end
    end

    private

    def defaults
      logger = Logger.new(STDOUT)
      logger.level = Logger::DEBUG
      {
        logger: logger,
        filters: {}
      }
    end
  end
end