# UX, Audio, Battle, dan Inventori

## Perubahan

- **Perbaikan remapping:** panel `ControlsSettings` kini node permanen di `Assets-gameplay/Scenes-gameplay/game_settings.tscn`; input keyboard ditangkap langsung saat tombol fungsi dipilih.
- **Battle Tuyul terpisah:** `Assets-Battle/Scene-Battle/tuyul_battle.tscn` adalah scene turunan yang dapat diedit untuk tampilan khusus Tuyul. Script Tuyul kini membuka scene tersebut.

- Petunjuk `[ENTER] Interaksi / Bicara` tampil ketika pemain berada dalam jangkauan NPC/objek interaktif.
- Percakapan dapat ditutup dengan `Esc`; `Enter` tetap melanjutkan dialog.
- Menu jeda sekarang memiliki **CONTROLS**. Pemain dapat melihat dan mengganti tombol gerak kiri/kanan, lompat, interaksi, inventori, dan menu jeda selama sesi bermain.
- Audio api di main menu tidak lagi autoplay. Ambience angin hanya berjalan bersama scene Player. Langkah memakai bunyi retro pendek dari paket audio proyek saat pemain berjalan; ganti stream `Footsteps` bila asset langkah final tersedia.
- Tuyul sekarang memulai pertarungan turn-based saat menyentuh pemain, menggunakan profil `Tuyul Liar` (55 HP, 7 damage) dan sprite Tuyul. Monster besar memakai profil `Monster Hijau`.
- Ditambahkan pickup reusable untuk `medkit` dan `oxygen`; dua contoh ditempatkan di Area 3. Tekan Enter di dekat item untuk mengambilnya.
- Inventori membatasi Medkit menjadi 5 dan tabung Oxygen menjadi 3. Saat penuh, item tidak hilang dan prompt memberi tahu pemain.

## Uji manual yang disarankan

1. Jalankan game dari main menu: pastikan audio api tidak terdengar.
2. Mulai game dan berjalan: pastikan ambience angin serta bunyi langkah muncul, lalu buka pause dengan Esc dan periksa Controls.
3. Di dekat NPC, periksa hint Enter; mulai percakapan dan tekan Esc untuk menutupnya.
4. Masuk Area 3, sentuh masing-masing Tuyul: battle harus terbuka dengan nama Tuyul Liar; kalahkan lalu kembali untuk memastikan musuh hilang.
5. Ambil dua item di Area 3, buka inventori dengan I, gunakan item, dan coba mengambil item saat kapasitas penuh.
6. Temui monster besar di Area 4: battle tetap berfungsi dan menampilkan Monster Hijau.

## Pemeriksaan teknis

Godot 4.7 headless berhasil memindai dan mendaftarkan script proyek. Proyek lama membawa banyak file metadata macOS `._*.wav`; Godot melaporkan file tersebut bukan WAV saat reimport. Peringatan itu sudah ada pada asset bundle dan tidak berasal dari perubahan ini.
