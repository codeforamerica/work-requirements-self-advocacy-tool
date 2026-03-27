Grover.configure do |config|
  chrome_paths = [
    ENV["PUPPETEER_EXECUTABLE_PATH"],
    ENV["GOOGLE_CHROME_BIN"],
    ENV["GOOGLE_CHROME_SHIM"],
    "/usr/bin/chromium",
    "/app/.chrome-for-testing/chrome-linux64/chrome"
  ]

  chrome_path = chrome_paths.find { |path| path.present? && File.exist?(path) }

  if chrome_path.present?
    config.options = {
      executable_path: chrome_path,
      no_sandbox: true
    }
  end
end
