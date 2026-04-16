# SIGAP Build System (Root Files)

Repositori `sigap-build` ini bertugas khusus untuk menyimpan file-file konfigurasi level *root* atau *global* untuk keseluruhan *workspace* SIGAP, seperti:

- `Makefile` (Sistem build terpadu lokal)
- Dan konfigurasi root lain di masa depan (misal: global `.gitignore`, instruksi `docker-compose.yml`, dll).

## Bagaimana ini bekerja?

Dalam sistem `repo` bawaan Google, Anda tidak dapat secara langsung menempatkan *file* pada *root workspace*. Seluruh *file* harus ditarik dari dalam sebuah repositori.

Repositori ini akan di-clone ke dalam direktori `build/`. Kemudian, konfigurasi pada `manifest.xml` akan menggunakan fungsi `<copyfile>` untuk secara otomatis menyalin *file* yang ada di dalam repositori ini keluar, yaitu ke *root* direktori `sigap/`.

Contoh instruksi di dalam `default.xml` manifest:
```xml
  <project path="build" name="sigap-build">
    <copyfile src="Makefile" dest="Makefile" />
  </project>
```

## Cara Menambahkan File Root Baru

Jika tim pengembang ingin menambahkan konfigurasi root baru untuk seluruh ekosistem:
1. Masukkan file tersebut ke dalam *source code* pada repositori ini (`sigap-build`).
2. *Commit* dan *Push* file ke *branch* utama di GitHub.
3. Edit file manifest (`default.xml`) pada repositori `sigap-manifest`, tambahkan tag `<copyfile src="nama_file" dest="nama_file" />` di dalam blok *project build*.
4. Setiap *developer* hanya perlu melakukan `repo sync` untuk mendapatkan *update* terbaru di root direktori mereka.

---
*Bagian dari Ekosistem Proyek SIGAP*
