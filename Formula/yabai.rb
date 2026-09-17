class Yabai < Formula
  desc "Tiling window manager for macOS (macOS 27 / Golden Gate fork)"
  homepage "https://github.com/VenusCrazy/yabai"
  url "https://github.com/VenusCrazy/yabai/archive/refs/tags/v7.1.25-macos27.tar.gz"
  sha256 "66522225c25bba301c81cbd5f00a615e292fd6ad42378232b95dfee8e228792f"
  license "MIT"
  head "https://github.com/VenusCrazy/yabai.git", branch: "master"

  depends_on macos: :big_sur

  def install
    system "make", "-j1", "install"

    identities = Utils.safe_popen_read("security", "find-identity", "-p", "codesigning")
    if identities.include?("yabai-cert")
      system "codesign", "--force", "--sign", "yabai-cert", "#{buildpath}/bin/yabai"
    else
      system "codesign", "--force", "--sign", "-", "#{buildpath}/bin/yabai"
    end

    bin.install "#{buildpath}/bin/yabai"
    (pkgshare/"examples").install "#{buildpath}/examples/yabairc"
    (pkgshare/"examples").install "#{buildpath}/examples/skhdrc"
    man1.install "#{buildpath}/doc/yabai.1"
  end

  def caveats
    <<~EOS
      This is the macOS 27 (Golden Gate) fork of yabai.

      macOS 27 does not auto-load the scripting-addition, so configure it once.

      1. Add a passwordless sudoers rule for --load-sa. Run this with the
         absolute path to yabai (from `command -v yabai`):

           echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 /path/to/yabai | cut -d ' ' -f 1) /path/to/yabai --load-sa"

         then paste the printed line (with the real path) into:

           sudo visudo -f /private/etc/sudoers.d/yabai

      2. Add these as the first two lines of ~/.config/yabai/yabairc,
         replacing BIN with the output of `command -v yabai`:

           yabai -m signal --add event=dock_did_restart action="sudo BIN --load-sa"
           sudo BIN --load-sa

      To have yabai managed by launchd (start automatically at login):

           yabai --start-service

      When running as a launchd service, logs are written to /tmp/yabai_<user>.[out|err].log.

      Full guide: https://github.com/VenusCrazy/yabai/blob/master/doc/BUILD-macOS-27.md
    EOS
  end

  test do
    assert_match "yabai-v", shell_output("#{bin}/yabai --version")
  end
end
