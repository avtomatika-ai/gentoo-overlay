# Avtomatika AI — Gentoo Ebuild Overlay

Official Portage overlay maintained by **Avtomatika AI**. Provides ebuild packages for AI/ML infrastructure, high-performance inference servers, automation tools, and developer utilities for AI agents.

---

## Authorship and Maintenance

* **Lead Architect & Maintainer:** Dmitrii Gagarin ([@madgagarin](https://github.com/madgagarin))
* **Organization:** [Avtomatika AI](https://github.com/avtomatika-ai)
* **Overlay License:** MIT

---

## Repository Setup

### Method 1: Via `eselect repository` (Recommended)

1. Ensure `app-eselect/eselect-repository` is installed:
   ```bash
   emerge --ask app-eselect/eselect-repository
   ```

2. Add and enable the repository:
   ```bash
   eselect repository add avtomatika-ai git https://github.com/avtomatika-ai/gentoo-overlay.git
   ```

3. Synchronize repository metadata:
   ```bash
   emaint sync -r avtomatika-ai
   ```

### Method 2: Manual Configuration via `repos.conf`

Create `/etc/portage/repos.conf/avtomatika-ai.conf`:

```ini
[avtomatika-ai]
location = /var/db/repos/avtomatika-ai
sync-type = git
sync-uri = https://github.com/avtomatika-ai/gentoo-overlay.git
auto-sync = yes
```

Synchronize repository:
```bash
emaint sync -r avtomatika-ai
```

---

## Repository Removal

### Method 1: Via `eselect repository`

* **Disable the repository** (preserves local files on disk):
  ```bash
  eselect repository disable avtomatika-ai
  ```

* **Remove the repository completely** (removes configuration and deletes local repository files):
  ```bash
  eselect repository remove -d avtomatika-ai
  ```

### Method 2: Manual Removal

1. Remove the repository configuration:
   ```bash
   rm -f /etc/portage/repos.conf/avtomatika-ai.conf
   ```

2. Remove the local repository data:
   ```bash
   rm -rf /var/db/repos/avtomatika-ai
   ```

---

## Available Packages

| Category | Package | Keywords | Description |
| :--- | :--- | :--- | :--- |
| `dev-util` | **`hypa-bin`** | `~amd64` `~arm64` | High-performance context optimization and code indexing CLI for AI harnesses (Claude, Copilot, Codex) |
| `app-laptop` | **`chuwi-linux-tools`** | `~amd64` | Complete hardware support for Chuwi FreeBook 360 & MiniBook X convertibles (dual-sensor tablet mode, OpenRC service, kernel configs & patches) |

---

## Package Installation

### Installing `chuwi-linux-tools` (Chuwi 2-in-1 Hardware Support)

1. Accept keywords:
   ```bash
   echo "app-laptop/chuwi-linux-tools ~amd64" >> /etc/portage/package.accept_keywords/chuwi
   ```

2. Install the package:
   ```bash
   emerge --ask app-laptop/chuwi-linux-tools::avtomatika-ai
   ```

3. **First-Time Installation Step:**
   On a fresh system, configure and re-emerge the kernel once:
   ```bash
   mount /boot && mount /efi

   # Optional: use the tailored ~2-minute Chuwi FreeBook kernel config
   mkdir -p /etc/portage/savedconfig/sys-kernel
   cp /usr/share/chuwi-linux-tools/kernel-configs/kernel-config-chuwi-freebook-i5-1215u \
      /etc/portage/savedconfig/sys-kernel/gentoo-kernel

   # Rebuild kernel (applies dual-sensor patch and sensor configuration)
   emerge --ask sys-kernel/gentoo-kernel
   reboot
   ```

4. Enable and start the OpenRC daemon:
   ```bash
   rc-update add cmxd default
   rc-service cmxd start
   ```

*(All subsequent kernel updates via `@world` will automatically patch, compile in ~2 minutes, and rebuild the driver without any manual intervention!)*

### Installing `hypa-bin`

1. Accept testing keywords if necessary:
   ```bash
   echo "dev-util/hypa-bin ~amd64" >> /etc/portage/package.accept_keywords/hypa
   ```

2. Install the package:
   ```bash
   emerge --ask dev-util/hypa-bin::avtomatika-ai
   ```

---

## Contributing

Pull requests and bug reports are welcome. Before submitting contributions, ensure all ebuilds comply with Gentoo QA standards and pass `pkgcheck`:

```bash
pkgcheck scan
```
