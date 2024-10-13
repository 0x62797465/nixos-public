{ stdenv, fetchFromGitHub }:
{
  aerial-sddm-theme = stdenv.mkDerivation rec {
    pname = "aerial-sddm-theme";
    version = "53f81e3";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/aerial-sddm-theme
    '';
    src = fetchFromGitHub {
      owner = "3ximus";
      repo = "aerial-sddm-theme";
      rev = "92b85ec7d177683f39a2beae40cde3ce9c2b74b0"; # This is wrong but it works, set it and leave it I guess
      sha256 = "10c38q5d6czjlmcazf99ynrpkzppshrh0bx3kq1v4fpdwy367iyh";
    };
  };
}
