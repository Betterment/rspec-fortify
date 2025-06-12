# frozen_string_literal: true

require 'rspec/core'
require 'rspec/fortify/version'
require 'rspec_ext/rspec_ext'

module RSpec
  class Fortify
    def self.setup
      RSpec.configure do |config|
        config.add_setting :clear_lets_on_failure, default: true
        config.add_setting :default_retry_count, default: 1
        config.add_setting :default_sleep_interval, default: 0
        config.add_setting :display_try_failure_messages, default: true
        config.add_setting :exponential_backoff, default: false
        config.add_setting :retry_on_failure, default: default_branch? || pr?
        config.add_setting :retry_on_failure_count, default: 2
        config.add_setting :retry_on_success, default: pr? && changed_specs.size < 30
        config.add_setting :retry_on_success_count, default: 10
        config.add_setting :verbose_retry, default: true

        # retry based on example metadata
        config.add_setting :retry_count_condition, default: ->(_) {}

        # If a list of exceptions is provided and 'retry' > 1, we only retry if
        # the exception that was raised by the example is NOT in that list. Otherwise
        # we ignore the 'retry' value and fail immediately.
        #
        # If no list of exceptions is provided and 'retry' > 1, we always retry.
        config.add_setting :exceptions_to_hard_fail, default: []

        # If a list of exceptions is provided and 'retry' > 1, we only retry if
        # the exception that was raised by the example is in that list. Otherwise
        # we ignore the 'retry' value and fail immediately.
        #
        # If no list of exceptions is provided and 'retry' > 1, we always retry.
        config.add_setting :exceptions_to_retry, default: []

        # Callback between retries
        config.add_setting :retry_callback, default: nil

        config.around :each, &:run_with_retry
      end
    end

    attr_reader :context, :ex

    def initialize(example, opts = {})
      @ex = example
      @ex.metadata.merge!(opts)
      current_example.attempts ||= 0
    end

    def current_example
      @current_example ||= RSpec.current_example
    end

    def retry_count
      if retry_on_success?
        RSpec.configuration.retry_on_success_count
      elsif retry_on_failure?
        RSpec.configuration.retry_on_failure_count
      else
        [
          (
          ENV['RSPEC_FORTIFY_RETRY_COUNT'] ||
              ex.metadata[:retry] ||
              RSpec.configuration.retry_count_condition.call(ex) ||
              RSpec.configuration.default_retry_count
        ).to_i,
          1,
        ].max
      end
    end

    def attempts
      current_example.attempts ||= 0
    end

    def attempts=(val)
      current_example.attempts = val
    end

    def clear_lets
      if ex.metadata[:clear_lets_on_failure].nil?
        RSpec.configuration.clear_lets_on_failure
      else
        ex.metadata[:clear_lets_on_failure]
      end
    end

    def sleep_interval
      if ex.metadata[:exponential_backoff]
        (2**(current_example.attempts - 1)) * ex.metadata[:retry_wait]
      else
        ex.metadata[:retry_wait] ||
          RSpec.configuration.default_sleep_interval
      end
    end

    def exceptions_to_hard_fail
      ex.metadata[:exceptions_to_hard_fail] ||
        RSpec.configuration.exceptions_to_hard_fail
    end

    def exceptions_to_retry
      ex.metadata[:exceptions_to_retry] ||
        RSpec.configuration.exceptions_to_retry
    end

    def verbose_retry?
      RSpec.configuration.verbose_retry?
    end

    def display_try_failure_messages?
      RSpec.configuration.display_try_failure_messages?
    end

    def run # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/CyclomaticComplexity
      loop do
        RSpec.configuration.formatters.each { |f| f.retry(ex) if f.respond_to? :retry } if attempts.positive?

        if verbose_retry? && (log_first_attempt? || attempts.positive?)
          message = "RSpec::Fortify: #{ordinalize(attempts + 1)} try #{ex.location}"
          message = "\n#{message}" if attempts == 1
          RSpec.configuration.reporter.message(message)
        end

        ex.metadata[:retry_attempts] = attempts
        ex.metadata[:retry_exceptions] ||= []

        current_example.clear_exception
        ex.run

        self.attempts += 1

        break unless should_retry?

        ex.metadata[:retry_exceptions] << ex.exception if ex.exception

        break if attempts >= retry_count

        if exceptions_to_hard_fail.any? && ex.exception && exception_exists_in?(exceptions_to_hard_fail, ex.exception)
          break
        end

        break if exceptions_to_retry.any? && ex.exception && !exception_exists_in?(exceptions_to_retry, ex.exception)

        if verbose_retry? && display_try_failure_messages? && retry_on_failure? && (attempts != retry_count)
          exception_strings =
            if ex.exception.is_a?(::RSpec::Core::MultipleExceptionError::InterfaceTag)
              ex.exception.all_exceptions.map(&:to_s)
            else
              [ex.exception.to_s]
            end

          try_message = "\n#{ordinalize(attempts)} Try error in #{ex.location}:\n#{exception_strings.join "\n"}\n"
          RSpec.configuration.reporter.message(try_message)
        end

        ex.example_group_instance.clear_lets if clear_lets

        if RSpec.configuration.retry_callback
          ex.ex_group_instance.instance_exec(ex, &RSpec.configuration.retry_callback)
        end

        sleep sleep_interval if sleep_interval.to_f.positive?
      end
    end

    private

    # borrowed from ActiveSupport::Inflector
    def ordinalize(number)
      if (11..13).cover?(number.to_i % 100)
        "#{number}th"
      else
        case number.to_i % 10
        when 1 then "#{number}st"
        when 2 then "#{number}nd"
        when 3 then "#{number}rd"
        else "#{number}th"
        end
      end
    end

    def exception_exists_in?(list, exception)
      list.any? do |exception_klass|
        exception.is_a?(exception_klass) || exception_klass === exception # rubocop:disable Style/CaseEquality
      end
    end

    def log_first_attempt?
      cast_to_boolean(ENV.fetch('RSPEC_FORTIFY_LOG_FIRST_ATTEMPT', 'false'))
    end

    def retry_on_failure?
      RSpec.configuration.retry_on_failure
    end

    def retry_on_success?
      RSpec.configuration.retry_on_success && current_example_changed?
    end

    def current_example_changed?
      changed_specs.include?(ex.file_path.sub(%r{^\./}, ''))
    end

    def current_attempt_failed?
      !ex.exception.nil?
    end

    def current_attempt_succeeded?
      ex.exception.nil?
    end

    def should_retry?
      if retry_on_success?
        current_attempt_succeeded?
      elsif retry_on_failure?
        current_attempt_failed?
      end
    end
  end
end

def cast_to_boolean(value) # rubocop:disable Naming/PredicateMethod
  if value.nil? || %w(false f 0 no n).include?(value.to_s.downcase) # rubocop:disable Style/IfWithBooleanLiteralBranches
    false
  else
    true
  end
end

def ci?
  cast_to_boolean(ENV.fetch('CI', 'false'))
end

def pr?
  ci? && cast_to_boolean(ENV.fetch('CIRCLE_PULL_REQUEST', 'false'))
end

def default_branch?
  ci? && !pr?
end

def default_branch
  ENV.fetch('RSPEC_FORTIFY_DEFAULT_BRANCH', 'main')
end

def changed_specs
  ENV.fetch('CHANGED_SPECS', nil)&.split(',') ||
    `git diff --merge-base origin/#{default_branch} --name-only --relative --diff-filter=AM -- '*_spec.rb'`.chomp.split("\n") || []
end

RSpec::Fortify.setup
