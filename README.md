# Analisis dan Perbaikan Citra

## 1. Deskripsi Program
Aplikasi ini merupakan perangkat lunak pemrosesan citra digital berbasis *Graphical User Interface* (GUI) MATLAB yang dikembangkan untuk memenuhi tugas besar mata kuliah IF4073. Seluruh algoritma pemrosesan citra pada aplikasi ini diimplementasikan secara **manual** menggunakan operasi matriks dasar MATLAB tanpa bergantung pada fungsi utama dari *Image Processing Toolbox* (seperti `imhist`, `histeq`, atau `imfilter`).

Fitur utama aplikasi meliputi:
* **Analisis & Validasi Histogram:** Perhitungan histogram manual untuk citra *Grayscale* dan RGB, visualisasi kurva histogram, serta perhitungan metrik statistik citra (Min, Max, Mean, Standard Deviation, dan Entropy).
* **Transformasi Intensitas (*Intensity Transformation*):** *Contrast Stretching*, *Log Transformation*, dan *Power-Law / Gamma Correction*.
* **Pengolahan Histogram (*Histogram Processing*):** *Histogram Equalization* (dilengkapi proteksi *color shift* berbasis ruang warna HSV) dan *Histogram Matching / Specification*.
* **Penyaringan Spasial (*Spatial Filtering*):** Filter linier (*Mean Filter*, *Gaussian Filter*, *Sharpening / High-Boost*) dan filter non-linier (*Median Filter*, *Min Filter*, *Max Filter*).

---

## 2. Dependensi & Persyaratan Sistem
* **Perangkat Lunak:** MATLAB versi R2026a.
* **Toolbox Tambahan:** Image Processing Toolbox, Deep Learning Toolbox, Simulink, Parallel Computing Toolbox (penulis sebenarnya tidak tahu yang mana, pokoknya ada salah satu yang diperlukan agar fungsi floorDiv bisa dipakai)

---

## 3. Struktur Direktori Proyek
```text
├── dataset/                    # Folder direktori citra uji dan citra referensi
├── src/
│   ├── enhancement/            # Algoritma transformasi intensitas, histeq, histmatch
│   ├── filtering/              # Algoritma filtering spasial (linier & non-linier)
│   ├── histogram/              # Algoritma perhitungan histogram manual
│   └── utils/                  # Skrip perhitungan metrik dan validasi histogram
├── main_gui.m                  # Aplikasi GUI utama MATLAB
└── README.md                   # Dokumentasi proyek
```

## 4. Tata Cara Menjalankan Program & Alur Penggunaan GUI

### Persiapan Direktori Program
1. Buka aplikasi **MATLAB**.
2. Ubah *Current Folder* ke direktori utama dari proyek ini.
3. Muat seluruh direktori dan subfolder proyek ke dalam jalur pencarian MATLAB dengan menjalankan perintah berikut pada **Command Window**:
   ```matlab
   addpath(genpath(pwd))
   
### Langkah-Langkah Operasional GUI
1. **Muat Citra Uji:** Klik tombol **`Muat Citra Uji`** untuk memilih citra masukan dari direktori `dataset/`. Citra, histogram awal, dan metrik statistik citra akan ditampilkan secara otomatis.
2. **Muat Citra Referensi (Opsional):** Klik **`Muat Citra Referensi`** apabila Anda ingin menggunakan metode *Histogram Matching*.
3. **Pilih Kategori & Metode:** Pilih **Kategori Metode** dan **Teknik Spesifik** yang diinginkan melalui menu *drop-down*.
4. **Atur Parameter:** Masukkan parameter terkait (misalnya nilai Gamma atau ukuran Kernel) pada kolom input parameter.
5. **Eksekusi:** Klik tombol hijau **`Jalankan Enhancement`** untuk memproses citra dan melihat perbandingan citra serta histogram terbaru.
6. **Simpan Hasil:** Klik tombol **`Simpan Citra Hasil`** untuk menyimpan citra keluaran ke direktori lokal (`.png` / `.jpg`).
