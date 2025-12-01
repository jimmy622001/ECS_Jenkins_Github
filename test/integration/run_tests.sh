#!/bin/bash
set -e

# This script runs integration tests against a deployed environment
# Usage: APP_URL="https://yourdomain.com" ./run_tests.sh

# Create results directory if it doesn't exist
mkdir -p results

# Ensure APP_URL is set
if [ -z "$APP_URL" ]; then
    echo "Error: APP_URL environment variable must be set"
    exit 1
fi

echo "Running integration tests against: $APP_URL"

# Basic health check test
echo "Running health check test..."
HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/health")
if [ "$HEALTH_STATUS" -eq 200 ]; then
    echo "Health check passed: $HEALTH_STATUS"
    echo '<?xml version="1.0" encoding="UTF-8"?>
    <testsuites>
      <testsuite name="health" tests="1" failures="0" errors="0" skipped="0">
        <testcase classname="HealthCheck" name="Application health endpoint" time="0.1"></testcase>
      </testsuite>
    </testsuites>' > results/health-check.xml
else
    echo "Health check failed with status: $HEALTH_STATUS"
    echo '<?xml version="1.0" encoding="UTF-8"?>
    <testsuites>
      <testsuite name="health" tests="1" failures="1" errors="0" skipped="0">
        <testcase classname="HealthCheck" name="Application health endpoint" time="0.1">
          <failure message="Health check failed" type="AssertionError">Health check returned status '$HEALTH_STATUS' instead of 200</failure>
        </testcase>
      </testsuite>
    </testsuites>' > results/health-check.xml
    exit 1
fi

# Security headers test
echo "Testing security headers..."
HEADERS=$(curl -s -I "$APP_URL" | grep -E '(^X-|Content-Security-Policy:|Strict-Transport-Security:)' || echo "No security headers found")

if echo "$HEADERS" | grep -q "X-Content-Type-Options: nosniff"; then
    echo "X-Content-Type-Options header is correctly set"
    HEADER_TEST_RESULT="pass"
else
    echo "X-Content-Type-Options header is missing"
    HEADER_TEST_RESULT="fail"
fi

if [ "$HEADER_TEST_RESULT" = "pass" ]; then
    echo '<?xml version="1.0" encoding="UTF-8"?>
    <testsuites>
      <testsuite name="security" tests="1" failures="0" errors="0" skipped="0">
        <testcase classname="SecurityHeaders" name="Security headers check" time="0.1"></testcase>
      </testsuite>
    </testsuites>' > results/security-headers.xml
else
    echo '<?xml version="1.0" encoding="UTF-8"?>
    <testsuites>
      <testsuite name="security" tests="1" failures="1" errors="0" skipped="0">
        <testcase classname="SecurityHeaders" name="Security headers check" time="0.1">
          <failure message="Missing security headers" type="AssertionError">Required security headers are missing</failure>
        </testcase>
      </testsuite>
    </testsuites>' > results/security-headers.xml
    exit 1
fi

# Test for specific application functionality
# Add more application-specific tests here

echo "All integration tests passed!"
exit 0