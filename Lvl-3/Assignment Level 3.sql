-- persiapan
SHOW DATABASES;
USE HSI_ARN222_17196;
SELECT DATABASE() AS Database_yang_Digunakan;

-- Pre Requisites
-- 1. Buatlah tabel ref_evaluasi sesuai ketentuan.
CREATE TABLE ref_evaluasi (
    kode VARCHAR(2) NOT NULL,
    nama VARCHAR(30) NOT NULL,
    bobot INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    PRIMARY KEY (kode)
);

-- 1B. isi tabel ref_evaluasi
INSERT INTO ref_evaluasi (kode, nama, bobot)
VALUES ('EH', 'Evaluasi Harian', 40),
       ('EP', 'Evaluasi Pekanan', 25),
       ('EA', 'Evaluasi Akhir', 35);

-- Cek DESCRIBE tabel ref_evaluasi
DESCRIBE ref_evaluasi;
-- Cek tabel ref_evaluasi
SELECT * FROM ref_evaluasi;

-- 2. Buatlah tabel nilai_peserta sesuai ketentuan
CREATE TABLE nilai_peserta (
    id INT NOT NULL AUTO_INCREMENT,
    nip VARCHAR(12) NOT NULL,
    jenis_evaluasi VARCHAR(2) NOT NULL,
    mulai_evaluasi TIMESTAMP NOT NULL,
    akhir_evaluasi TIMESTAMP NOT NULL,
    nilai INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    PRIMARY KEY(id),
    CONSTRAINT `check_nilai` CHECK((nilai <= 100) & (nilai >= 0)),
    CONSTRAINT `fk_nilaipeserta_nip`
    FOREIGN KEY (nip) REFERENCES peserta(nip),
    CONSTRAINT `fk_nilaipeserta_jeniseval`
    FOREIGN KEY (jenis_evaluasi) REFERENCES ref_evaluasi(kode)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 2F. Check tabel nilai_peserta dengan limit 10
SELECT * FROM nilai_peserta LIMIT 10;


-- Soal
-- 1A. Membuat tabel kota sesuai ketentuan
CREATE TABLE kota (
    id VARCHAR(3) NOT NULL,
    nama_kota VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    update_at TIMESTAMP,
    PRIMARY KEY (id)
);

INSERT INTO kota (id, nama_kota)
VALUES ('001', 'Jakarta'),
       ('002', 'Bekasi'),
       ('003', 'Depok'),
       ('004', 'Bogor'),
       ('005', 'Tangerang'),
       ('006', 'Aceh'),
       ('007', 'Medan'),
       ('008', 'Pekanbaru'),
       ('009', 'Padang'),
       ('010', 'Bandung');

-- cek tabel kota
SELECT * FROM kota;

-- set foreign key checks to 0
SET FOREIGN_KEY_CHECKS = 0;

-- 1B. Relasi Foreign Key tabel peserta dan kota
ALTER TABLE peserta
ADD CONSTRAINT `fk_kota`
FOREIGN KEY(domisili) REFERENCES kota(id);

-- 1C. tampilkan data nip, nama peserta, tempat lahir, tanggal lahir, dan domisili (saya limit 10)
SELECT p.nip,
       CONCAT(UPPER(LEFT(p.nama_depan, 1)), RIGHT(p.nama_depan, LENGTH(p.nama_depan)-1),
              ' ',
              UPPER(LEFT(p.nama_belakang, 1)), RIGHT(p.nama_belakang, LENGTH(p.nama_belakang)-1)) AS 'Nama',
       p.tempat_lahir,
       DATE_FORMAT(p.tanggal_lahir, "%d %M %Y") AS 'tanggal_lahir',
       k.nama_kota AS domisili
FROM peserta AS p INNER JOIN kota AS k
ON p.domisili = k.id
LIMIT 10;

-- 2A. Alter Table peserta dengan menambahkan kolom angkatan dan grup
ALTER TABLE peserta
ADD COLUMN angkatan VARCHAR(6) NOT NULL AFTER alamat;
ALTER TABLE peserta
ADD COLUMN grup VARCHAR(2) NOT NULL AFTER angkatan;

-- describe tabel peserta
DESCRIBE peserta;

-- 2B. update kolom angkatan dengan nilai 6 digit pertama dari kolom nip
UPDATE peserta
SET angkatan = LEFT(nip, 6),
    update_at = NOW();

-- 2C. update kolom grup dengan nilai digit 8 dan 9 dari kolom nip
UPDATE peserta
SET grup = MID(nip, 8, 2),
    update_at = NOW();

-- cek setelah update
SELECT nip,
       CONCAT(UPPER(LEFT(nama_depan, 1)), RIGHT(nama_depan, LENGTH(nama_depan)-1),
              ' ',
              UPPER(LEFT(nama_belakang, 1)), RIGHT(nama_belakang, LENGTH(nama_belakang)-1)) AS nama,
       angkatan,
       grup
FROM peserta;

-- 3. Dengan menggunakan subquery, tampilkan 5 besar peserta di grup yang nilai rata-ratanya (average Nilai Peserta dari seluruh Peserta pada grup tersebut) paling tinggi. Info yang ditampilkan adalah NIP, Nama Peserta, Umur Peserta, Nilai Peserta, dan Predikat.

-- catatan
-- n_je = nilai per jenis evaluasi
-- tna  = table nilai akhir
-- tp   = table peserta

SELECT tp.nip,
       tp.nama_peserta,
       tp.umur_peserta,
       ROUND(SUM(tna.n_je)/100, 2) AS nilai_akhir,
       (CASE 
        WHEN SUM(tna.n_je)/100 = 100 THEN "Mumtaz Murtafi"
        WHEN SUM(tna.n_je)/100 >=91 THEN "Mumtaz"
        WHEN SUM(tna.n_je)/100 >=76 THEN "Jayyid Jiddan"
        WHEN SUM(tna.n_je)/100 >=61 THEN "Jayyid"
        WHEN SUM(tna.n_je)/100 >=51 THEN "Maqbul"
        ELSE "Rasib"
       END) AS "Predikat"
FROM (
    SELECT nip,
           jenis_evaluasi,
           AVG(np.nilai)*re.bobot AS n_je
    FROM nilai_peserta AS np
    INNER JOIN ref_evaluasi AS re
    ON np.jenis_evaluasi = re.kode
    GROUP BY np.nip, np.jenis_evaluasi ) as tna
INNER JOIN (
    SELECT nip,
           CONCAT(UPPER(LEFT(nama_depan, 1)), RIGHT(nama_depan, LENGTH(nama_depan)-1),
                  ' ', 
                  UPPER(LEFT(nama_belakang, 1)), RIGHT(nama_belakang, LENGTH(nama_belakang)-1))
                  AS nama_peserta,
           YEAR(NOW()) - YEAR(tanggal_lahir) AS umur_peserta
    FROM peserta    
    ) AS tp
ON tna.nip = tp.nip
GROUP BY tna.nip
ORDER BY nilai_akhir DESC
LIMIT 5;
