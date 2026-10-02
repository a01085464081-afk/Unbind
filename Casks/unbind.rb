cask "unbind" do
  version "1.2.0"
  sha256 "96bb9d687833ef4933943c5460e40fc2ec975c8d24f2d619c5c936377327bdd5"

  url "https://github.com/syc-labs/Unbind/releases/download/v#{version}/Unbind.zip"
  name "Unbind"
  desc "Menu bar app that watches ports and frees them"
  homepage "https://github.com/syc-labs/Unbind"

  depends_on macos: :tahoe

  app "Unbind.app"

  zap trash: "~/Library/Preferences/local.unbind.plist"

  caveats <<~EOS
    Unbind is not notarized. If macOS blocks it on first launch, run:
      xattr -dr com.apple.quarantine /Applications/Unbind.app
  EOS
end
