#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark"
require "net/http"
require "uri"

BASE_URL = ENV.fetch("LOAD_TEST_URL", "http://localhost:3000")
CONCURRENCY = ENV.fetch("LOAD_TEST_CONCURRENCY", "10").to_i
REQUESTS_PER_WORKER = ENV.fetch("LOAD_TEST_REQUESTS", "20").to_i
PATHS = ENV.fetch("LOAD_TEST_PATHS", "/api/v1/health,/api/v1/categories").split(",").map(&:strip)

class LoadResult
  attr_reader :successes, :failures, :latencies

  def initialize
    @successes = 0
    @failures = 0
    @latencies = []
    @mutex = Mutex.new
  end

  def record(success:, latency:)
    @mutex.synchronize do
      if success
        @successes += 1
      else
        @failures += 1
      end
      @latencies << latency
    end
  end

  def p95_latency
    sorted = @latencies.sort
    return 0 if sorted.empty?

    index = ((sorted.length * 0.95).ceil - 1).clamp(0, sorted.length - 1)
    sorted[index]
  end
end

def request_once(path)
  uri = URI.join(BASE_URL, path)
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  response = Net::HTTP.get_response(uri)
  latency = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round(2)
  [response.is_a?(Net::HTTPSuccess), latency]
rescue StandardError
  latency = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round(2)
  [false, latency]
end

result = LoadResult.new
workers = []

puts "Load smoke test"
puts "  base_url: #{BASE_URL}"
puts "  concurrency: #{CONCURRENCY}"
puts "  requests_per_worker: #{REQUESTS_PER_WORKER}"
puts "  paths: #{PATHS.join(', ')}"

elapsed = Benchmark.realtime do
  CONCURRENCY.times do
    workers << Thread.new do
      REQUESTS_PER_WORKER.times do
        path = PATHS.sample
        success, latency = request_once(path)
        result.record(success: success, latency: latency)
      end
    end
  end

  workers.each(&:join)
end

total = result.successes + result.failures
success_rate = total.zero? ? 0 : (result.successes.to_f / total * 100).round(2)

puts
puts "Results"
puts "  total_requests: #{total}"
puts "  successes: #{result.successes}"
puts "  failures: #{result.failures}"
puts "  success_rate: #{success_rate}%"
puts "  elapsed_seconds: #{elapsed.round(2)}"
puts "  requests_per_second: #{(total / elapsed).round(2)}"
puts "  p95_latency_ms: #{result.p95_latency}"

min_success_rate = ENV.fetch("LOAD_TEST_MIN_SUCCESS_RATE", "95").to_f
max_p95_ms = ENV.fetch("LOAD_TEST_MAX_P95_MS", "500").to_f

if success_rate < min_success_rate
  warn "FAIL: success rate #{success_rate}% is below #{min_success_rate}%"
  exit 1
end

if result.p95_latency > max_p95_ms
  warn "FAIL: p95 latency #{result.p95_latency}ms exceeds #{max_p95_ms}ms"
  exit 1
end

puts "PASS"
