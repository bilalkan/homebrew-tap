cask "pusu" do
  version "1.0.1"
  sha256 "b806cfd1cbc847ef5a662b4eca46aa5ebfa54bc11a07a398e16394862c008e52"

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

  # Yardımcı durdurulurken SleepDisabled'ı kendi eski değerine döndürür. Yardımcı zaten
  # durmuşsa önce kayıtlı eski değer (yalnızca 0/1) buradan geri yüklenir.
  uninstall_preflight_steps do
    run "/bin/sh",
        args:         [
          "-c",
          "S=/var/db/local.kan.pusu.helper.state; [ -f $S ] || exit 0; V=$(/bin/cat $S); " \
          "case $V in 0|1) /usr/bin/pmset -a disablesleep $V;; esac",
        ],
        sudo:         true,
        must_succeed: false
  end

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
    If you use lid mode without the helper, turn it off in Pusu before uninstalling;
    otherwise run `sudo pmset -a disablesleep 0` afterwards.
  EOS
end
