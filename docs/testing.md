# Testing

There are no unit tests for the QML. Changes are checked by running the plugin for real: on your own desktop, and on clean virtual machines with other distributions and compositors, installed the way the README says.

## Quick checks before a commit

```bash
python3 tools/i18n_check.py --check                       # translations still match the code
python3 -c "import ast,sys; [ast.parse(open(f).read()) for f in sys.argv[1:]]" bin/oboi_*.py
for f in bin/oboi-index bin/oboi-fetch bin/oboi-semantic bin/helper-ready.sh; do sh -n "$f" || exit 1; done   # sh -n checks only its first file
```

To try a change live in plugin mode, symlink your checkout into the plugin folder (`ln -s "$PWD" ~/.config/dms/plugins/skindancer`), then `systemctl --user restart dms`. Quickshell reloads QML files on save in standalone mode (`qs -c oboi` with `~/.config/quickshell/oboi` pointing to the checkout).

## Virtual machines (`tools/vm/`)

The harness runs KVM guests with plain QEMU (no libvirt, no root) on a machine with `/dev/kvm`, usually a different box on the LAN, and drives them over SSH from your workstation.

| File | Purpose |
|---|---|
| `vm.sh` | `up`, `ssh`, `down`, `reset`, `list` for the guests; runs on the KVM host. Guests use cloud images with cloud-init (except `nixos`, see below), `virtio-vga-gl` with `egl-headless` (the host GPU renders, no window), SSH on `127.0.0.1:2201…2206` |
| `images.txt` | Download list of the cloud images (into `$VMDIR/images`) |
| `provision/<guest>.sh` | Installs DMS and a compositor the way the DMS documentation says |
| `provision/session.sh` | Autologin on tty1 into niri, or Hyprland where niri is not installed (the Arch guest) |
| `provision/arch-wlroots.sh` | Adds Sway and labwc to the Arch guest; the compositor at login is then chosen by `~/.session` (`hyprland`, `sway`, `labwc`) |
| `install-plugin.sh` | Installs the plugin as the README says (a clone in `~/.config/dms/plugins/skindancer`) and enables it |
| `test-plugin.sh` | In the guest: versions, a cold index, open the picker, views, settings, help, wallhaven search, apply a wallpaper, DMS journal. Screenshots with `grim`. Exits 1 if any required step fails, and reports whether the prebuilt helper or Python really ran |
| `test-compositor.sh` | In a live session: right-click on the desktop, keyboard input into the search field, arrows, Enter, Esc, with `ydotool` and `wtype` |
| `run-distro.sh` | From the workstation: one full round for a guest (start, provision once, install, test with Python, install the prebuilt helper if `bin/oboi-helper` exists locally, test again, collect results into `build/vm/<guest>/`, stop). It tests the committed `HEAD`, not uncommitted changes. Not for `nixos` |
| `nixos/` | Builds the NixOS guest image (`build.sh`, in a `nixos/nix` container, needs `/dev/kvm`): DMS from its flake, Skindancer from the current checkout as a declarative plugin in the Nix store, the SSH key from `nixos/key.pub` baked in. Copy `nixos/out/nixos-26.05.qcow2` to `$VMDIR/images/` yourself, then run `test-plugin.sh` in the guest with `PLUGIN_DIR=/etc/xdg/quickshell/dms-plugins/skindancer` |

```bash
# on the workstation; the KVM host has this repository at ~/skindancer and the images in ~/skindancer-vm/images
VM_HOST=user@kvm-host VM_REPO=skindancer VMDIR='$HOME/skindancer-vm' WALLS=~/Pictures/Wallpapers \
    tools/vm/run-distro.sh ubuntu2604
```

Guests: `debian13`, `ubuntu2604`, `fedora44`, `tumbleweed` (niri), `arch` (Hyprland; Sway and labwc after `arch-wlroots.sh`), `nixos`.

Things learned the hard way:

- Run one guest at a time on a 12 GB host.
- `/tmp` in a guest is cleared on reboot; upload bundles again after switching compositors.
- From Russia, Cisco's openh264 repositories answer 403: the Fedora and Tumbleweed provisioning disables them. GitHub release downloads may also fail without a VPN.
- Ubuntu installs GDM together with the `dms` package; the session script disables the display manager so autologin works.
- The Debian cloud image boots a kernel without `virtio-gpu`; provisioning installs `linux-image-amd64` and removes the cloud kernel (a reboot follows).
- Smoothness of transitions cannot be judged in a VM (virgl). Test on real hardware for that.
