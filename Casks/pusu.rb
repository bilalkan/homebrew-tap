cask "pusu" do
  version "1.0.0"
  sha256 "b1f629c2f5bb45570f1af6c17302324c74a5e0f2e436994f77dd890a604933c4"

  url "https://github.com/bilalkan/pusu/releases/download/v#{version}/Pusu-#{version}.zip"
  name "Pusu"
  desc "Menu bar app that keeps the system awake"
  homepage "https://github.com/bilalkan/pusu"

  depends_on macos: :ventura

  app "Pusu.app"
  binary "#{appdir}/Pusu.app/Contents/MacOS/Pusu", target: "pusu"

  # Pusu henüz Apple tarafından notarize edilmiyor; Applications'a taşınmadan önce
  # karantina işareti kaldırılır ki ilk açılışta Gatekeeper engellemesin.
  preflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "Pusu.app"], chdir: "."
  end

  # Yardımcı durdurulurken SleepDisabled'ı kendi eski değerine döndürür.
  uninstall launchctl: "local.kan.pusu.helper",
            quit:      "local.kan.pusu",
            delete:    [
              "/Library/LaunchDaemons/local.kan.pusu.helper.plist",
              "/Library/PrivilegedHelperTools/local.kan.pusu.helper",
              "/var/db/local.kan.pusu.helper.state",
              "/var/log/local.kan.pusu.helper.log",
              "/var/run/local.kan.pusu.helper.sock",
            ]

  zap trash: [
    "~/Library/Application Support/Pusu",
    "~/Library/LaunchAgents/local.kan.pusu.login.plist",
    "~/Library/Preferences/local.kan.pusu.plist",
  ]

  caveats <<~EOS
    Pusu is not notarized by Apple. The cask removes the quarantine flag so it opens normally.
    Lid mode needs administrator rights; install the optional helper from Settings › System.
  EOS
end
