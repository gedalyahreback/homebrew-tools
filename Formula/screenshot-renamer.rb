class ScreenshotRenamer < Formula
  desc "Watches ~/Screenshots and renames new screenshots via a native macOS dialog"
  homepage "https://github.com/gedalyahreback/screenshot-renamer"
  url "https://github.com/gedalyahreback/screenshot-renamer/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "7bc94234c73184ddb32ecc2c0a98bec6faceaa7d96216e2423df3915e153b044"
  license "MIT"

  depends_on "python@3.12"
  depends_on :macos

  def install
    # Install scripts and assets into libexec
    libexec.install "rename_screenshot.py", "menubar.py", "settings_app.py", "requirements.txt"
    (libexec/"assets").install "assets/logo.png"

    # Create virtualenv and install dependencies
    venv = virtualenv_create(libexec/"venv", "python3.12")
    venv.pip_install resources

    # Watcher wrapper
    (bin/"screenshot-renamer").write <<~SH
      #!/bin/sh
      set -a
      [ -f "$HOME/.screenshot-renamer-env" ] && . "$HOME/.screenshot-renamer-env"
      set +a
      exec "#{libexec}/venv/bin/python3" "#{libexec}/rename_screenshot.py" "$@"
    SH

    # Menu bar wrapper
    (bin/"screenshot-renamer-menubar").write <<~SH
      #!/bin/sh
      exec "#{libexec}/venv/bin/python3" "#{libexec}/menubar.py" "$@"
    SH

    # LaunchAgent plist
    plist_path = etc/"screenshot-renamer/com.user.screenshot-renamer.plist"
    (etc/"screenshot-renamer").mkpath
    plist_path.write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
          "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>com.user.screenshot-renamer</string>
          <key>ProgramArguments</key>
          <array>
              <string>#{bin}/screenshot-renamer</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <true/>
          <key>StandardOutPath</key>
          <string>/tmp/screenshot-renamer.log</string>
          <key>StandardErrorPath</key>
          <string>/tmp/screenshot-renamer.log</string>
      </dict>
      </plist>
    XML
  end

  def caveats
    <<~EOS
      To complete setup, store your OpenAI API key:

        echo 'OPENAI_API_KEY=sk-...' > ~/.screenshot-renamer-env
        chmod 600 ~/.screenshot-renamer-env

      Then load the background watcher:

        cp #{etc}/screenshot-renamer/com.user.screenshot-renamer.plist ~/Library/LaunchAgents/
        launchctl load ~/Library/LaunchAgents/com.user.screenshot-renamer.plist
    EOS
  end

  test do
    system "#{bin}/screenshot-renamer", "--help"
  end
end
