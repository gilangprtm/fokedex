Rencana Kerja Aplikasi Pokedex

1. Setup Proyek & Konfigurasi Dasar
   1.1 Instalasi Flutter (jika belum ada)
   1.2 Buat proyek Flutter baru
   1.3 Tambahkan dependensi utama (provider, dio, dll.)
   1.4 Buat struktur folder yang rapi

2. Konfigurasi API & Model Data
   2.1 Pelajari struktur data dari PokeAPI
   2.2 Identifikasi endpoint yang dibutuhkan untuk setiap fitur
   2.3 Buat service untuk mengambil data dari API
   2.4 Buat model data untuk setiap fitur:
   Model Pokemon
   Model Tipe Pokémon
   Model Evolusi
   Model Abilities
   Model Habitat
   Model Move & Machine
   Model Item & Berry

3. Implementasi State Management dengan Provider
   3.1 Buat PokemonProvider untuk daftar Pokémon
   3.2 Buat DetailPokemonProvider untuk informasi Pokémon
   3.3 Buat TypeProvider untuk menangani tipe Pokémon
   3.4 Buat AbilityProvider untuk menangani abilities Pokémon
   3.5 Buat EvolutionProvider untuk menampilkan rantai evolusi
   3.6 Buat LocationProvider untuk menampilkan lokasi Pokémon
   3.7 Buat MoveProvider untuk menangani serangan Pokémon
   3.8 Buat ItemProvider untuk menangani item & berry

4. UI & Navigasi Antar Halaman
   4.1. Halaman Beranda (Home Screen)
   4.1.1 Tampilkan daftar Pokémon dalam bentuk grid
   4.1.2 Implementasi pagination (infinite scroll)
   4.1.3 Tambahkan fitur pencarian Pokémon
   4.1.4 Filter Pokémon berdasarkan tipe
   4.2. Halaman Detail Pokémon
   4.2.1 Tampilkan informasi dasar (gambar, tinggi, berat, statistik)
   4.2.2 Tampilkan daftar abilities
   4.2.3 Tampilkan daftar move (serangan Pokémon)
   4.2.4 Tampilkan evolusi Pokémon
   4.3. Halaman Tipe Pokémon
   4.3.1 Tampilkan daftar semua tipe Pokémon
   4.3.2 Tampilkan daftar Pokémon berdasarkan tipe
   4.4. Halaman Evolusi Pokémon
   4.4.1 Tampilkan rantai evolusi Pokémon
   4.4.2 Implementasi tampilan visual untuk evolusi
   4.5. Halaman Lokasi Pokémon
   4.5.1 Tampilkan lokasi Pokémon di game
   4.5.2 Tambahkan fitur pencarian lokasi berdasarkan Pokémon
   4.6. Halaman Item & Berry
   4.6.1 Tampilkan daftar item & efeknya
   4.6.2 Tampilkan daftar berry & efeknya terhadap Pokémon
   4.7. Halaman Move & Machine
   4.7.1 Tampilkan daftar serangan Pokémon
   4.7.2 Filter serangan berdasarkan tipe

5. UX & UI Enhancement
   5.1 Gunakan tema Pokedex agar lebih menarik
   5.2 Tambahkan animasi transisi antar halaman
   5.3 Gunakan lazy loading untuk gambar Pokémon
   5.4 Implementasi dark mode untuk pengguna

6. Optimalisasi & Testing
   6.1 Uji coba fitur utama (fetch data, navigasi, tampilan)
   6.2 Optimalkan performance (caching, image optimization, dll.)
   6.3 Perbaiki bug dan lakukan error handling
   6.4 Pastikan aplikasi responsif di smartphone & tablet
