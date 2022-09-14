;; This is an operating system configuration generated
;; by the graphical installer.

(use-modules (nongnu packages linux)
             (nongnu system linux-initrd)
	     (gnu packages haskell-apps)
	     (gnu services base)
	     (guix channels)
	     (guix inferior)
	     (srfi srfi-1)
	     (gnu system keyboard)
	     (gnu services desktop)
	     (gnu home services desktop)
	     (gnu services xorg)
	     (gnu services docker)
	     (gnu packages)
	     (gnu bootloader)
	     (gnu bootloader grub)
	     (gnu system file-systems)
	     (my services kmonad)
	     (my services foo))
;; (use-service-modules
;;   cups
;;   desktop
;;   networking
;;   ssh
;;   xorg)

(define herd-path
  "/run/current-system/profile/bin/herd")

(define annepro-udev-rule
  (udev-rule
    "101-annepro.rules"
    (string-append
     "ACTION==\"remove\", SUBSYSTEM==\"input\", "
     "ATTRS{phys}==\"60:57:18:76:8e:fe\", "
     "ATTRS{name}==\"AnnePro2 Keyboard\", "
     "RUN+=\"" herd-path " stop kmonad-daemon\""
     "\n"
     "ACTION==\"add\", SUBSYSTEM==\"input\", "
     "ATTRS{phys}==\"60:57:18:76:8e:fe\", "
     "ATTRS{name}==\"AnnePro2 Keyboard\", "
     "SYMLINK+=\"annepro2\", "
     "RUN+=\"" herd-path " enable kmonad-daemon\""
     "RUN+=\"" herd-path " start kmonad-daemon\"")))
     
(operating-system
  (kernel (let*
      ((channels
        (list (channel
               (name 'nonguix)
               (url "https://gitlab.com/nonguix/nonguix")
               (commit "3480f10982c7e213520b64566f4f2efd63b79be8"))
              (channel
               (name 'guix)
               (url "https://git.savannah.gnu.org/git/guix.git")
               (commit "70f2207152793d74b78b66b04b66fbbdd4d7c620"))))
       (inferior
        (inferior-for-channels channels)))
      (first (lookup-inferior-packages inferior "linux" "5.15.18"))))
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  
  (locale "en_US.utf8")
  (timezone "Europe/Kiev")
  (keyboard-layout
   (keyboard-layout "us,ru" ",phonetic" #:options '("grp:alt_shift_toggle")))
  (host-name "apolo")
  
  (users (cons (user-account
    (name "moon") 
    (group "users")
    (supplementary-groups '("wheel" "audio" "users" "video" "input" "docker"))
    (comment "users"))
	 %base-user-accounts))

  (packages
   (append
    (map specification->package
         '("kmonad" "openbox" "zsh" "awesome" "nss-certs"))
    %base-packages))

  (services
   (modify-services
    (append
     (list
      (kmonad-service "/home/moon/kconf.kbd")
      ;; (service home-redshift-service-type) 
      (service xfce-desktop-service-type)
      (bluetooth-service #:auto-enable? #t)
      (service docker-service-type)
      (set-xorg-configuration
       (xorg-configuration
        (keyboard-layout keyboard-layout))))
     %desktop-services)
      (udev-service-type config =>
        (udev-configuration (inherit config)
			    (rules (cons annepro-udev-rule
					 (cons kmonad (udev-configuration-rules config))))))))
  
  (bootloader
    (bootloader-configuration
      (bootloader grub-bootloader)
      (targets (list "/dev/sda"))
      (keyboard-layout keyboard-layout)))
  (swap-devices
    (list (swap-space
            (target
              (uuid "c4f059e9-4aad-48c7-a048-74331321bee7")))))
  (file-systems
    (cons* (file-system
             (mount-point "/mnt/boot/efi")
             (device (uuid "617C-2988" 'fat32))
             (type "vfat"))
           (file-system
             (mount-point "/")
             (device
               (uuid "538a8301-e011-45a2-822c-c35e39e7bd2a"
                     'ext4))
             (type "ext4"))
           %base-file-systems)))

