{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  system.autoUpgrade = {
    enable = true;
    allowReboot = false; # Do nixos-rebuild switch --upgrade instead
    channel = "https://channels.nixos.org/nixos-unstable";
  };

  # Bootloader
  boot.kernelPackages = pkgs.linuxPackages_latest; # Things broken on older version for my computer
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.kernelModules = [ "hp-wmi" "kvm-intel"];
  boot.kernelParams = [
    "quiet"           # Prevent people from thinking you're hackerman (does not completely work because nixos stage 1)
    "loglevel=3"      # Make it so that I don't have to see everything my system is doing on startup
    "audit=0"         # idk
    "splash"          # idk
    "nowatchdog"      # Prevent annoying watchdog errors, what does it even do?
    "mitigations=off" # Makes computer noticably faster, why isn't this the default?
  ];
  networking.hostName = "DESKTOP-B0NQMZC"; # Define hostname, chose this one to confuse

  # Enable networking
  networking.networkmanager.enable = true;

  # Set time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Nix storage optimization
  nix.optimise.automatic = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # fonts
  fonts.packages = with pkgs; [
    source-code-pro
    jetbrains-mono
    roboto
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    nerdfonts
  ];


  # Enable hyprland and sddm
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.theme = "aerial-sddm-theme";
  programs.hyprland.enable = true;
  programs.waybar.enable = true;
  programs.xwayland.enable = true;

  # Firmware stuffs
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;
  hardware.enableRedistributableFirmware = true;

  # Enable VMs (and docker)
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.docker.enable = true;

  # Power management
  powerManagement.powertop.enable = true;
  services.thermald.enable = true;

  # enable gvfs for usb support
  services.gvfs.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true; # maybe not lol: CVE-2024-47176, CVE-2024-47076, CVE-2024-47175, CVE-2024-47177

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # Theme
  qt.platformTheme = "gtk2";
  environment.etc = {                 # I will die before I am forced to use home-manager
    "xdg/gtk-2.0".source =  ./gtk-2.0;
    "xdg/gtk-3.0".source =  ./gtk-3.0;
    "xdg/gtk-4.0".source =  ./gtk-4.0;
  };
  environment.variables = {
    "GTK_THEME" = "catppuccin-frappe-blue-standard"; # This worked for a bit, but when a parent app executes 
  };                                                 # something like thunar, the default theme changes

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.h = {
    isNormalUser = true;
    description = "h";
    extraGroups = [ "networkmanager" "wheel" "kvm" "libvirtd" "docker"];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    # Get normal binaries working on nixos
    (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
      pkgs.buildFHSUserEnv (base // {
       name = "fhs";
       targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [pkgs.pkg-config];
       profile = "export FHS=1";
       runScript = "fish";
       extraOutputsToInstall = ["dev"];
    }))

    # Themes
    (callPackage ./aerial.nix {}).aerial-sddm-theme # sddm theme
    libsForQt5.qt5.qtmultimedia       # Needed for sddm theme
    libsForQt5.qt5.qtgraphicaleffects # Also needed for sddm theme
    adwaita-icon-theme                # Mouse theme
    qogir-icon-theme                  # Icon theme
    catppuccin-gtk                    # GTK theme


    # cli utils
    wget        # file downloading
    inetutils   # telnet
    ffmpeg      # video conversion and shit
    tldr        # Ez man pages
    pamixer     # cli volume management (needed for hyprland scripts)
    htop        # System monitoring
    bat         # File reader
    git         # it's git
    file        # it's file
    magika      # file but better
    fastfetch   # Check hardware stats
    xorg.xprop  # check if windows are X11
    p7zip       # archive/extract util
    fish        # shell
    acpi        # used for finding battery
    brightnessctl # brightness utility
    bc          # calculator
    sysstat     # system statistics
    todo        # Todo utility
    vim         # World's best text editor
    pywal       # wallpaper stuff
    swww        # wallpaper stuff

    # system utils
    gnome-disk-utility # Disk management
    sioyek      # PDF reader
    xfce.thunar # File manager
      xfce.thunar-volman # needed for file manager
      xarchiver   # Needed for extraction/archiving in file manager
      file-roller # Needed for extraction/archiving in file manager
      xfce.thunar-archive-plugin # Needed for extraction/archiving in file manager
      gvfs        # USB support for thunar
    alacritty   # Terminal
    foot        # Terminal, secondary
    firefox     # web browser
    brave       # web browser, secondary
    blueman     # Bluetooth frontend
    xed-editor  # World's second best text editor
    zed-editor  # World's third best text editor
    mpv         # video player
    wf-recorder # screen recorder
    qbittorrent # torrent stuff
    obsidian    # note taking app

    # Power stuff
    thermald    # throtelling
    powertop    # power saving
    powerstat   # power statistics

    # WM
    hyprland    # the WM itself
    xdg-desktop-portal-hyprland # Needed for some hyprland stuff to work
    networkmanagerapplet # network manager frontend
    dunst       # notification stuff
    libnotify   # needed for dunst
    swappy      # screenshot util (I have no idea which one does what,
    grim        # screenshot util  I just know that I need all of these
    slurp       # screenshot util  in order to take screenshots on wayland)
    xorg.xhost  # X11 support
    rofi-wayland # Rofi menu
    waybar      # Bar for wayland
    hyprlock    # Waylock replacement
    wl-clipboard # clipboard stuff
    wl-clip-persist # clipboard stuff
    wlogout     # Logout util
    hyprshade   # Red light

    # Compilers/interpeters
    gcc         # C & C++
    go          # Golang
    rustup      # Rust
    python3     # Python

    # Web Hacking
    caido        # Burp Suite at home
    burpsuite    # Burp Suite
    interactsh   # Helps with SSRF finding
    # ngrok      # Interactsh with extra steps, broken
    ffuf         # web fuzzer
    amass        # web recon
    nmap         # Normal port scanner + other stuff
    masscan      # Mass port scanner
    # fscan      # Mass vuln scanner, probably backdoored, leaving out for now
    nuclei       # Web scanner
      nuclei-templates
    responder    # Local network poisoner

    # RE
    virt-manager # VMs for malware analysis
    qemu_full    # Emulators
    ghidra       # NSA decompiler
    avalonia-ilspy # C-Sharp Decompiler
    retdec       # C decompiler
    rizin        # CLI disassembler
      rizinPlugins.rz-ghidra
    cutter       # GUI frontend rizin
      cutterPlugins.rz-ghidra
      cutterPlugins.sigdb
    radare2      # CLI disassembler
    pwntools     # For POC dev
    ida-free     # IDA free
    z3           # z3 solver
    flare-floss  # strings but better
    python3Packages.binwalk # File from file extractor
    volatility3  # Memory extraction framework
    yara         # yara rules
    john         # Hash stuff, useful incase malware is password protected
    wireshark    # Network analysis
    tcpdump      # Network analysis
    hashcat      # Hash cracking
      hashcat-utils # Hashcat utils
    strace      # Debugging
    ltrace      # Debugging
    gdb         # Debugging
    gef         # Debugging
    (pkgs.callPackage ./binja.nix {}) # BinaryNinja support
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
